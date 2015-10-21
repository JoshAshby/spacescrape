require 'rake/clean'

require 'benchmark'

CLEAN << 'db/app.sqlite3'
CLEAN << 'cache/'

task :environment do
  require_relative './spacescrape'
  require_relative './db/seeds'
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

    Seeds.load_seeds
  end

  desc "Migrate and seed"
  task reset: [ :environment, :migrate, :seed ]
end
