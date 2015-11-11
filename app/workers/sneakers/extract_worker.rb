module Workers
  class ExtractWorker
    include Sneakers::Worker
    from_queue 'extract'

    def work msg
      data = JSON.parse msg
      extractor = Workflows::Extract.new

      extractor.process webpage_id: data['webpage_id']

      ack!
    end
  end
end
