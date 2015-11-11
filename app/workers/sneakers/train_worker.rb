module Workers
  class TrainWorker
    include Sneakers::Worker
    from_queue 'train'

    def work msg
      data = JSON.parse msg
      trainer = Workflows::Train.new

      trainer.process webpage: data['webpage']

      ack!
    end
  end
end
