module Workers
  class ScrapeWorker < BaseSneaker
    from_queue 'spacescrape.scrape', env: nil

    def perform(url:)
      scraper = Workflows::Scrape.new

      scraper.subscribe to: 'request:links' do |bus, links|
        links.each do |link|
          self.class.enqueue({ url: link }.to_json)
        end
      end

      scraper.subscribe to: 'request:reschedule' do |bus, timeout|
        return ack! if Redis.current.exists "rescheduled:#{ url }"

        SpaceScrape.logger.debug "Requeueing sneaker for #{ url }"

        Redis.current.set "rescheduled:#{ url }", true
        RescheduleWorker.perform_in timeout, url
        return ack!
      end

      SpaceScrape.logger.debug "workflow: #{ scraper }"
      scraper.subscribe to: 'request:cancel' do |bus|
        return reject!
      end

      SpaceScrape.logger.debug "workflow: #{ scraper }"
      scraper.process url: url

      scraper.subscribe to: 'doc:stored' do |bus, payload|
        Workers::ExtractWorker.perform_async webpage_id: payload.webpage.id
      end

      ack!
    rescue Sequel::PoolTimeout, Sequel::DatabaseError => e
      SpaceScrape.logger.warn "Encountered a problem with the database while working on the DB"
      SpaceScrape.logger.warn e

      requeue!
    end
  end
end
