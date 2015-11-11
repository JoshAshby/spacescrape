module Workflows
  class Analyze
    class AnalyzeContent
      def call bus, payload
        classifier = NaiveBayes.new name: 'space'

        payload.topics = classifier.classify doc: payload.content

        bus.publish to: 'doc:analyzed', data: payload
      end
    end
  end
end
