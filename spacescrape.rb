require 'rubygems'
require 'bundler/setup'

require 'awesome_print'
require 'byebug'

require 'yaml'
require 'logger'

require 'sqlite3'
require 'sequel'

require 'sidekiq/api'

require 'sinatra/base'
require 'haml'

$current_dir = File.dirname(__FILE__)

%w| crawler_cache logs |.each do |dirname|
  dir = File.join $current_dir, dirname
  Dir.mkdir dir unless Dir.exist? dir
end

$logger = Logger.new File.join($current_dir, 'logs', 'server.log')
$logger.level = Logger::DEBUG

Redis.current = Redis.new
DB = Sequel.connect 'sqlite://db/app.sqlite3'

Sequel.extension :migration
Sequel::Migrator.run DB, File.join($current_dir, 'db', 'migrations')

# Require all of our code... This allows us to avoid having to do a lot of
# require_relatives all over the place, leaving us to only require the external
# gems that we need. Obviously this has a lot of flaws but meh, Works For Me™
%w| workers models lib db |.each do |dir|
  directory = File.join($current_dir, dir, '*.rb')
  Dir[directory].each do |file|
    require_relative file
  end
end

load_seeds

class MainApp < Sinatra::Base
  get '/' do
    @scrapes = Scrape.all

    haml :index
  end

  post '/' do
    ScraperWorker.perform_async params['url'] if params['url']
    redirect to('/')
  end
end

at_exit do
  $logger.close
end
