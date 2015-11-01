require 'forwardable'

module Workflows
  class Base
    extend Forwardable

    def_delegators :pubsub, :publish, :subscribe
    def_delegators :stack, :use

    def pubsub
      @pubsub ||= Pipelines::Pubsub.new
    end

    def stack
      @stack ||= Pipelines::Stack.new
    end

    def process *args
      fail NotImplementedError
    end
  end
end
