require 'rake/clean'
require 'rake/testtask'

require 'yard'

CLEAN << 'coverage/'
CLEAN << 'doc/'

CLOBBER << 'cache/'

task :environment do
  require_relative './spacescrape'
end

namespace :redis do
  desc "Flushes the current redis instance, to clean away all keys"
  task flush: :environment do
    puts "Flushing redis"

    Redis.current.flushall
  end
end

namespace :db do
  desc "Runs the Sequel migrations"
  task migrate: :environment do
    puts "Running migrations"

    Sequel.extension :migration
    Sequel::Migrator.run DB, SpaceScrape.root.join('db', 'migrations')
  end

  desc "Seeds the database with the nescessary starting data"
  task seed: :environment do
    puts "Loading seed data"

    require_relative './db/seeds'
    Seeds.load_seeds
  end

  desc "Reset, migrate and reseed seed"
  task reset: :environment do
    puts "Droping existing tables"
    DB.run 'drop schema if exists public cascade'
    DB.run 'create schema public;'
    Rake::Task['db:migrate'].execute
    Rake::Task['db:seed'].execute
  end
end

namespace :rabbitmq do
  desc 'Setup rabbitmq routing'
  task setup: :environment do
    ch = SpaceScrape.bunny.create_channel

    workers_exchange = ch.direct 'spacescrape.workers'
    Workers.constants.each do |c|
      const = Workers.const_get c

      next unless const.ancestors.include? Sneakers::Worker
      next unless const.queue_name
      ch.queue( const.queue_name ).bind workers_exchange, routing_key: const.routing_key
    end

    pubsub_exchange = ch.topic 'spacescrape.pubsub'
    Subscribers.constants.each do |c|
      const = Subscribers.const_get c

      next unless const.ancestors.include? Sneakers::Worker
      next unless const.queue_name
      ch.queue( const.queue_name ).bind pubsub_exchange, routing_key: "#{ const.namespace }.#", auto_delete: true
    end
  end
end

Rake::TestTask.new do |t|
  t.pattern = "test/**/*test.rb"
end

task default: :test

namespace :test do
  desc 'Generates a coverage report'
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task['test'].execute
  end

  desc "Generates missing test files"
  task :generate do
    Dir[ 'lib/**/*.rb', 'app/**/*.rb' ].map do |f|
      Pathname.new('test') + f.gsub('.rb', '_test.rb')
    end.each do |filename|
      unless File.exist? filename
        puts "Creating #{ filename }"
        FileUtils.mkdir_p filename.dirname unless File.directory? filename.dirname
        FileUtils.touch filename
      end
    end
  end
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb', 'app/**/*.rb', 'initializers/**/*.rb', 'spacescrape.rb']
  t.options = [ '-', 'README.md' ]
  # t.stats_options = ['--list-undoc']
end
