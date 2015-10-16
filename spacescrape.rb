require 'rubygems'
require 'bundler/setup'

require 'awesome_print'
require 'byebug'

require 'yaml'

require 'sqlite3'
require 'sequel'

require 'sidekiq/api'

require 'sinatra/base'
require 'haml'

require 'sidekiq/testing'
Sidekiq::Testing.inline!

Redis.current = Redis.new
DB = Sequel.connect 'sqlite://db/app.sqlite3'

Sequel.extension :migration
Sequel::Migrator.run DB, File.join(File.dirname(__FILE__), 'db', 'migrations')

# Require all of our code... This allows us to avoid having to do a lot of
# require_relatives all over the place, leaving us to only require the external
# gems that we need. Obviously this has a lot of flaws but meh, Works For Me™
%w| workers models lib db |.each do |dir|
  directory = File.join(File.dirname(__FILE__), dir, '*.rb')
  Dir[directory].each do |file|
    require_relative file
  end
end

crawler_cache = File.join(File.dirname(__FILE__), 'crawler_cache')
Dir.mkdir crawler_cache unless Dir.exist? crawler_cache

load_seeds

class MainApp < Sinatra::Base
  get '/' do
    haml :index
  end

  post '/' do
    ScraperWorker.perform_async params['url'] if params['url']
    redirect to('/')
  end
end
