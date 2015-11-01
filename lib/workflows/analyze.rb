module Workflows
  class Analyze < Base
    def initialize
      subscribe to: 'doc:parse',     with: Parser
      subscribe to: 'doc:parsed',    with: Extractor
      subscribe to: 'doc:extracted', with: Analyzer
    end

    def process(url:)
      package = OpenStruct.new url: url

      publish to: 'doc:parse', data: package

      package
    end
  end
end
