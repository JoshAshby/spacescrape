require 'rubygems'
require 'bundler/setup'

require 'awesome_print'
require 'byebug'

$current_dir = File.dirname(__FILE__)

# Make sure we have a directory for logs and the cache so things don't complain
%w| crawler_cache logs |.each do |dirname|
  FileUtils.mkdir_p File.join($current_dir, dirname)
end

# Require all of our code... This allows us to avoid having to do a lot of
# require_relatives all over the place, leaving us to only require the external
# gems that we need. Obviously this has a lot of flaws but meh, Works For Me™
%w| initializers sinatra workers models lib |.each do |dir|
  directory = File.join($current_dir, dir, '**/*.rb')
  Dir[directory].sort.each do |file|
    next if File.directory? file

    require_relative file
  end
end

# config.ru takes care of firing up the sinatra server, so now all we have to
# do is sit back and relax

at_exit do
  $logger.close
end
