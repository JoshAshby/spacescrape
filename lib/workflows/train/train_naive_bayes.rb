module Workflows
  class Train
    class TrainNaiveBayes
      def call bus, payload
        learner = NaiveBayes.new name: 'space'

        learner.add   topic: payload.topic.key
        learner.train topic: payload.topic.key, doc: payload.content
        learner.save!

        bus.publish to: 'doc:trained', data: payload
      end
    end
  end
end
