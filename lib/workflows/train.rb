module Workflows
  class Train < Base
    subscribe to: 'doc:load',      with: Load
    subscribe to: 'doc:loaded' ,   with: TrainNaiveBayes
    subscribe to: 'doc:trained',   with: SaveTraining

    def process(webpage_id:, topic_id:)
      payload = OpenStruct.new webpage_id: webpage_id, topic_id: topic_id

      publish to: 'doc:load', data: payload
    end
  end
end
