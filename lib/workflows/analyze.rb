module Workflows
  class Analyze
    attr_accessor :pipeline

    def pipeline
      @pipeline ||= Pipelines::Pubsub.new do |pubsub|
        pubsub.subscribe to: 'doc:parse',     with: Steps::Parser
        pubsub.subscribe to: 'doc:parsed',    with: Steps::Extractor
        pubsub.subscribe to: 'doc:extracted', with: Steps::Analyzer
      end
    end

    def process url
      pipeline.publish to: 'doc:parse', data: package
    end
  end
end
