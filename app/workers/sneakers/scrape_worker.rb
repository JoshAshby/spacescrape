module Workers
  class ScrapeWorker
    include Sneakers::Worker
    from_queue 'scrape'

    def work msg
      data = JSON.parse msg
      scraper = Workflows::Scrape.new

      scraper.subscribe to: 'request:links' do |bus, links|
        links.each do |link|
          self.class.enqueue({ url: link }.to_json)
        end
      end

      scraper.subscribe to: 'request:reschedule' do |bus, timeout|
        return ack! if Redis.current.exists "rescheduled:#{ data['url'] }"

        SpaceScrape.logger.debug "Requeueing sneaker for #{ data['url'] }"

        Redis.current.set "rescheduled:#{ data['url'] }", true
        RescheduleWorker.perform_in timeout, data['url']
        return ack!
      end

      SpaceScrape.logger.debug "workflow: #{ scraper }"
      scraper.subscribe to: 'request:cancel' do |bus|
        return reject!
      end

      SpaceScrape.logger.debug "workflow: #{ scraper }"
      scraper.process url: data['url']

      scraper.subscribe to: 'doc:stored' do |bus, payload|
        Workers::ExtractWorker.enqueue({ webpage_id: payload.webpage.id }.to_json)
      end

      ack!
    rescue Sequel::PoolTimeout, Sequel::DatabaseError => e
      SpaceScrape.logger.warn "Encountered a problem with the database while working on the DB"
      SpaceScrape.logger.warn e

      requeue!
    end
  end
end
