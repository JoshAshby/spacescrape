module Workers
  class TrainWorker < BaseSneaker
    from_queue 'spacescrape.train', env: nil

    def perform(webpage_id:, topic_id:)
      trainer = Workflows::Train.new

      trainer.process webpage_id: webpage_id, topic_id: topic_id

      ack!
    end
  end
end
