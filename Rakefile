require 'rake/clean'

require 'benchmark'

CLEAN << 'db/app.sqlite3'
CLEAN << 'crawler_cache/'

task :environment do
  require_relative './spacescrape'
  require_relative './db/seeds'
end

desc "Walks through the cache and runs the analyzer on all files"
task reanalyze: :environment do
  # TODO: Make this use the new pipeline and everything
  puts "Walking crawler_cache..."
  total_seconds = Benchmark.realtime do
    Dir['crawler_cache/**/*'].each do |file|
      next if File.directory? file

      print "\t reanalyzing #{file}..."
      seconds = Benchmark.realtime do
        a = Analyzer.new html: File.read(file)
        a.analyze
      end

      puts " took #{ seconds }"
    end
  end

  puts "Took a total of #{ total_seconds } seconds"
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
    Sequel::Migrator.run DB, File.join($current_dir, 'db', 'migrations')
  end

  desc "Seeds the database with the nescessary starting data"
  task seed: :environment do
    puts "Loading seed data"

    Seeds.load_seeds
  end

  desc "Migrate and seed"
  task reset: [ :environment, :migrate, :seed ]
end
