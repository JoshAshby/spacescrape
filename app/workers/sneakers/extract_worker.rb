module Workers
  class ExtractWorker < BaseSneaker
    work_from :pipeline, :extract

    def perform(webpage_id:)
      extractor = Workflows::Extract.new

      extractor.process webpage_id: webpage_id

      ack!
    end
  end
end
