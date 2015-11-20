module Workers
  class TrainWorker < BaseSneaker
    work_from :pipeline, :train

    def perform(webpage_id:, topic_id:)
      trainer = Workflows::Train.new

      trainer.process webpage_id: webpage_id, topic_id: topic_id

      ack!
    end
  end
end
