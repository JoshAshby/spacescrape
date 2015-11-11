module Workers
  class AnalyzeWorker
    include Sneakers::Worker
    from_queue 'analyze'

    def work msg
      data = JSON.parse msg
      analyzer = Workflows::Analyze.new

      analyzer.process webpage_id: data['webpage_id']

      ack!
    end
  end
end
