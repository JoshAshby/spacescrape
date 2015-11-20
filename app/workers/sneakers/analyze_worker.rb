module Workers
  class AnalyzeWorker < BaseSneaker
    work_from :pipeline, :analyze

    def perform(webpage_id:)
      analyzer = Workflows::Analyze.new

      analyzer.process webpage_id: webpage_id

      ack!
    end
  end
end
