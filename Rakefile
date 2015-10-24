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

  desc "Truncate and reseed seed"
  task reset: :environment do
    DB.tables.each{ |table| DB[table].truncate }
    Rake::Task['db:seed'].execute
  end
end

Rake::TestTask.new do |t|
  t.pattern = "test/**/*test.rb"
end

task default: :test

desc 'Generates a coverage report'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['test'].execute
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb', 'sinatra/**/*.rb', 'workers/**/*.rb', 'models/**/*.rb', 'initializers/**/*.rb', 'spacescrape.rb', 'README.md']
  # t.stats_options = ['--list-undoc']
end
