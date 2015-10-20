class StackPipeline
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
