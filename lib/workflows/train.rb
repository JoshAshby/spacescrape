module Workflows
  class Train < Base
    def initialize
      subscribe to: 'doc:load',      with: Loader
      subscribe to: 'doc:loaded' ,   with: NaiveBayesTrainer
      subscribe to: 'doc:trained',   with: TrainerSaver
    end

    def process(webpage:)
      publish to: 'doc:load', data: { webpage: webpage }
    end
  end
end
