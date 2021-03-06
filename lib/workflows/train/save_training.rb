module Workflows
  class Train
    class SaveTraining
      def call bus, payload
        Training.create topic: payload.topic, webpage: payload.webpage

        bus.publish to: 'doc:stored', data: payload
      end
    end
  end
end
