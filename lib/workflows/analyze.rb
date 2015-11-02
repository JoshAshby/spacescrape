module Workflows
  class Analyze < Base
    def initialize
      subscribe to: 'doc:fetch',     with: Fetcher
      subscribe to: 'doc:fetched',   with: Extractor
      subscribe to: 'doc:extracted', with: Analyzer
    end

    def process(url:)
      publish to: 'doc:fetch', data: url
    end
  end
end
