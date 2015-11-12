module Workers
  class ExtractWorker < BaseSneaker
    from_queue 'spacescrape.extract', env: nil

    def perform(webpage_id:)
      extractor = Workflows::Extract.new

      extractor.process webpage_id: webpage_id

      ack!
    end
  end
end
