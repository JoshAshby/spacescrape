require './spacescrape'

task :reanalyze do
  puts "Walking crawler_cache..."
  Dir['crawler_cache/**/*'].each do |file|
    next if File.directory? file

    puts "\t reanalyzing #{file}"
    Analyzer.new File.read(file)
  end
end
