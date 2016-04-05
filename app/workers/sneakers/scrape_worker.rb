module Workers
  class ScrapeWorker < BaseSneaker
    work_from :pipeline, :scrape

    def perform(url:)
      scraper = Workflows::Scrape.new

      # scraper.subscribe to: 'request:links' do |bus, links|
      #   debugger
      #   links.each do |link|
      #     self.class.perform_async url: link
      #   end
      # end

      scraper.subscribe to: 'request:reschedule' do |bus, timeout|
        return ack! if Redis.current.exists "rescheduled:#{ url }"

        Redis.current.set "rescheduled:#{ url }", true
        Workers::RescheduleWorker.perform_in timeout, url
        return ack!
      end

      scraper.subscribe to: 'request:cancel' do |bus, payload|
        return reject!
      end

      scraper.subscribe to: 'doc:stored' do |bus, payload|
        Workers::ExtractWorker.perform_async webpage_id: payload.webpage.id
      end

      scraper.process url: url

      ack!
    rescue Sequel::PoolTimeout, Sequel::DatabaseError => e
      SpaceScrape.logger.warn "Encountered a problem with the database while working on the DB"
      SpaceScrape.logger.warn e

      requeue!
    end
  end
end
