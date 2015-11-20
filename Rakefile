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

    pipeline_exchange = ch.direct 'spacescrape.pipeline'
    ch.queue('spacescrape.scrape').bind pipeline_exchange, routing_key: 'scrape'
    ch.queue('spacescrape.extract').bind pipeline_exchange, routing_key: 'extract'
    ch.queue('spacescrape.train').bind pipeline_exchange, routing_key: 'train'
    ch.queue('spacescrape.analyze').bind pipeline_exchange, routing_key: 'analyze'
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
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb', 'sinatra/**/*.rb', 'workers/**/*.rb', 'models/**/*.rb', 'initializers/**/*.rb', 'spacescrape.rb']
  t.options = [ '-', 'README.md' ]
  # t.stats_options = ['--list-undoc']
end
