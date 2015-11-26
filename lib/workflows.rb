module Workflows
  class Base
    include Concerns::PubSub

    def initialize
      setup_class_subscribers!
    end

    def process *args
      fail NotImplementedError
    end
  end
end
