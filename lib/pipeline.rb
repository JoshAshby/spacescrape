class Pipeline
  def initialize
    @stack = []
    yield self
  end

  def process env={}
    @stack.inject(-> (env) { env }) { |app, comp| comp.call app }.call env
  end

  def use klass, *args, &block
    @stack.unshift -> (app) { klass.new app, *args, &block }
  end
end

class Fetcher
  def initialize app
    @app = app
  end

  def call env
    puts "Fetcher before hit, #{ env }"
    @app.call env
    puts "Fetcher after hit, #{ env }"
  end
end

class Parser
  def initialize app
    @app = app
  end

  def call env
    puts "Parser before hit, #{ env }"
    @app.call env
    puts "Parser after hit, #{ env }"
  end
end

class Extractor
  def initialize app
    @app = app
  end

  def call env
    puts "Extractor before hit, #{ env }"
    @app.call env
    puts "Extractor after hit, #{ env }"
  end
end

class Analyzer
  def initialize app
    @app = app
  end

  def call env
    puts "Analyzer before hit, #{ env }"
    @app.call env
    puts "Analyzer after hit, #{ env }"
  end
end

Pipeline.new do |pipeline|
  pipeline.use Fetcher
  pipeline.use Parser
  pipeline.use Extractor
  pipeline.use Analyzer
end.process url: 'google.com'
