module Workflows
  class Analyze < Base
    def initialize
      subscribe to: 'doc:extract',   with: Extractor
      subscribe to: 'doc:extracted', with: Analyzer
    end

    def process(url:)
      model = Webpage.find url: url

      publish to: 'doc:extract', data: model

      package
    end
  end
end
