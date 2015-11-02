module Workers
  class ScrapeWorker
    include Sneakers::Worker
    from_queue 'analyze'

    def work msg
      data = JSON.parse msg

      analyzer = Workflows::Analyze.new

      analyzer.process url: data[:url]

      ack!
    end
  end
end
