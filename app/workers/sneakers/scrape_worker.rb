module Workers
  class ScrapeWorker
    include Sneakers::Worker
    from_queue 'scrape'

    def work url
      scraper = Workflows::Scrape.new

      # scraper.subscribe to: 'request:retry' do |bus, timeout|
      #   SpaceScrape.logger.debug "Requeueing sneaker for #{ url }"
      #   return reschedule! timeout
      # end

      scraper.subscribe to: 'request:cancel' do |bus, timeout|
        return reject!
      end

      scraper.process url

      publish url, to_queue: 'analyze'

      ack!
    end
  end
end
