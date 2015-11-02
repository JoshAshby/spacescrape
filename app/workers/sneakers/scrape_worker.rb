module Workers
  class ScrapeWorker
    include Sneakers::Worker
    from_queue 'scrape'

    def reschedule_timeout timeout: 60
      jitter_threshold = Setting.find({ name: 'play_nice_jitter_threshold' }).value.to_i

      jitter = SecureRandom.random_number jitter_threshold
      timeout + jitter
    end

    def work msg
      data = JSON.parse msg

      SpaceScrape.logger.debug "Starting up worker for #{ data['url'] }"

      scraper = Workflows::Scrape.new

      SpaceScrape.logger.debug "workflow: #{ scraper }"

      scraper.subscribe to: 'request:links' do |bus, links|
        SpaceScrape.logger.debug "got links for #{ data['url'] }"
        links.each do |link|
          self.class.enqueue({ url: link }.to_json)
        end
      end

      SpaceScrape.logger.debug "workflow: #{ scraper }"
      scraper.subscribe to: 'request:reschedule' do |bus, env|
        return ack! if Redis.current.exists "rescheduled:#{ data['url'] }"

        SpaceScrape.logger.debug "Requeueing sneaker for #{ data['url'] }"

        Redis.current.set "rescheduled:#{ data['url'] }", true
        RescheduleWorker.perform_in env[:timeout], data['url']

        return ack!
      end

      SpaceScrape.logger.debug "workflow: #{ scraper }"
      scraper.subscribe to: 'request:cancel' do |bus, timeout|
        SpaceScrape.logger.debug "canceling request for #{ data['url'] }"
        return reject!
      end

      SpaceScrape.logger.debug "workflow: #{ scraper }"
      scraper.process url: data['url']

      SpaceScrape.logger.debug "Finished with #{ data['url'] }"
      ack!
    rescue Sequel::PoolTimeout, Sequel::DatabaseError => e
      SpaceScrape.logger.warn "Encountered a problem with the database while working on the DB"
      SpaceScrape.logger.warn e

      requeue!
    end
  end
end
