module Workers
  class AnalyzeWorker < BaseSneaker
    from_queue 'spacescrape.analyze', env: nil

    def perform(webpage_id:)
      analyzer = Workflows::Analyze.new

      analyzer.process webpage_id: webpage_id

      ack!
    end
  end
end
