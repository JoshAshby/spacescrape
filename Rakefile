require './spacescrape'

require 'benchmark'

task :reanalyze do
  puts "Walking crawler_cache..."
  total_seconds = Benchmark.realtime do
    Dir['crawler_cache/**/*'].each do |file|
      next if File.directory? file

      print "\t reanalyzing #{file}..."
      seconds = Benchmark.realtime do
        a = Analyzer.new File.read(file)
        a.analyze
      end

      puts " took #{ seconds }"
    end
  end

  puts "Took a total of #{ total_seconds } seconds"
end

task :cleanup do
  `rm -rf crawler_cache/ db/app.sqlite3`
  Redis.current.flushall
end
