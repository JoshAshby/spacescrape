require './spacescrape'

require 'benchmark'

task :reanalyze do
  puts "Walking crawler_cache..."
  total_seconds = Benchmark.realtime do
    Dir['crawler_cache/**/*'].each do |file|
      next if File.directory? file

      print "\t reanalyzing #{file}..."
      seconds = Benchmark.realtime do
        Analyzer.new File.read(file)
      end

      puts " took #{ seconds }"
    end
  end

  puts "Took a total of #{ total_seconds } seconds"
end
