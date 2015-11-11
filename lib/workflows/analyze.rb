module Workflows
  class Analyze < Base
    def initialize
      subscribe to: 'doc:load',      with: Loader
      subscribe to: 'doc:loaded' ,   with: Extractor
      subscribe to: 'doc:extracted', with: Analyzer
    end

    def process(webpage:)
      publish to: 'doc:load', data: { webpage: webpage }
    end
  end
end
