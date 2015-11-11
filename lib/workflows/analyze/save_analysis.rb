module Workflows
  class Analyze
    class SaveAnalysis
      def call bus, payload
        ap [ payload.uri.to_s, payload.topics ]

        bus.publish to: 'doc:stored', data: payload
      end
    end
  end
end
