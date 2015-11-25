module Workflows
  class Analyze < Base
    def initialize
      subscribe to: 'doc:load',     with: Load
      subscribe to: 'doc:loaded',   with: AnalyzeContent
      subscribe to: 'doc:analyzed', with: SaveAnalysis
    end

    def process(webpage_id:)
      payload = OpenStruct.new webpage_id: webpage_id

      publish to: 'doc:load', data: payload
    end
  end
end
