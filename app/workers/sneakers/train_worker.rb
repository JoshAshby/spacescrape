module Workers
  class TrainWorker
    include Sneakers::Worker
    from_queue 'train'

    def work msg
      data = JSON.parse msg
      trainer = Workflows::Train.new

      trainer.process webpage_id: data['webpage_id'], topic_id: data['topic_id']

      ack!
    end
  end
end
