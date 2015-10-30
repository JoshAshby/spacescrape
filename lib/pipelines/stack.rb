module Pipelines
  # Gives a rack middleware style stack builder
  # @example
  #   class Fetcher
  #     def initialize app
  #       @app = app
  #     end
  #
  #     def call env
  #       @app.call env
  #     end
  #   end
  class Stack
    attr_accessor :stack

    def initialize
      @stack = []

      yield self if block_given?
    end

    def process env={}
      @stack.inject(-> (env) { env }) { |app, comp| comp.call app }.call env
    end

    def use klass, *args, &block
      @stack.unshift -> (app) { klass.new app, *args, &block }
    end
  end
end
