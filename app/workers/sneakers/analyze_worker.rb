module Workers
  class ScrapeWorker
    include Sneakers::Worker
    from_queue 'scrape'

    def work url
      analyzer = Workflows::Analyze.new

      analyzer.process url

      ack!
    end
  end
end
