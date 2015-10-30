require 'rubygems'
require 'bundler/setup'

require 'awesome_print'
require 'byebug'

require 'sinatra'

module SpaceScrape
  module_function
  def root
    @@root ||= Pathname.new File.dirname(__FILE__)
  end

  def environment
    Sinatra::Base.environment
  end

  # Shamelessly stolen, then cleaned up a bit, from the [Rails project](https://github.com/rails/rails/blob/0450642c27af3af35b449208b21695fd55c30f90/railties/lib/rails/application.rb#L218-L231)
  def config_for name
    yaml = SpaceScrape.root.join 'config', "#{ name }.yml"

    unless yaml.exist?
      raise "Could not load configuration. No such file - #{ yaml }"
    end

    erb = ERB.new(yaml.read).result
    erbd_yaml = YAML.load erb

    erbd_yaml[SpaceScrape.environment.to_s] || {}
  rescue Psych::SyntaxError => e
    raise "YAML syntax error occurred while parsing #{ yaml }. " \
      "Please note that YAML must be consistently indented using spaces. Tabs are not allowed. " \
      "Error: #{ e.message }"
  end
end

# Make sure we have a directory for logs and the cache so things don't complain
%w| cache logs |.each do |dirname|
  FileUtils.mkdir_p SpaceScrape.root.join(dirname)
end

# Require all of our code... This allows us to avoid having to do a lot of
# require_relatives all over the place, leaving us to only require the external
# gems that we need. Obviously this has a lot of flaws but meh, Works For Me™
%w| lib/monkey_patches config/initializers app lib |.each do |dir|
  directory = SpaceScrape.root.join dir, '**/*.rb'
  Dir[directory].sort.each do |file|
    next if File.directory? file

    require_relative file
  end
end

# config.ru takes care of firing up the sinatra server, so now all we have to
# do is sit back and relax
