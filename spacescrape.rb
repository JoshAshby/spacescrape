require 'rubygems'
require 'bundler/setup'

require 'awesome_print'
require 'byebug'

require 'redis'
require 'redis-namespace'

require 'sqlite3'
require 'sequel'

require 'sidekiq/api'

require 'sinatra/base'
require 'haml'

$current_dir = File.dirname(__FILE__)

%w| crawler_cache logs |.each do |dirname|
  dir = File.join $current_dir, dirname
  FileUtils.mkdir_p dir
end

$logger = Logger.new File.join($current_dir, 'logs', 'server.log')
$logger.level = Logger::DEBUG

$redis_conn = -> { Redis::Namespace.new 'spacescrape', redis: Redis.new }
# Redis stuff
Redis.current = $redis_conn.call

Sidekiq.configure_server do |config|
  config.redis =  ConnectionPool.new size: 15, &$redis_conn
end

Sidekiq.configure_client do |config|
  config.redis =  ConnectionPool.new size: 15, &$redis_conn
end

# Setup our SQL database for things
DB = Sequel.connect 'sqlite://db/app.sqlite3'
Sequel::Model.db = DB
Sequel::Model.plugin :update_or_create
Sequel::Model.plugin :timestamps

# Autorun all of our migrations, just to be safe
Sequel.extension :migration
Sequel::Migrator.run DB, File.join($current_dir, 'db', 'migrations')

# Require all of our code... This allows us to avoid having to do a lot of
# require_relatives all over the place, leaving us to only require the external
# gems that we need. Obviously this has a lot of flaws but meh, Works For Me™
%w| sinatra workers models lib db |.each do |dir|
  directory = File.join($current_dir, dir, '**/*.rb')
  Dir[directory].each do |file|
    next if File.directory? file

    require_relative file
  end
end

# Load up our seed data too
load_seeds

# config.ru takes care of firing up the sinatra server, so now all we have to
# do is sit back an relax

at_exit do
  $logger.close
end
