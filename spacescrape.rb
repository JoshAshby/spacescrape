require 'rubygems'
require 'bundler/setup'

require'active_support/all'

require 'sinatra'
require 'tilt/erb'
require 'yaml'

require 'require_all'

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
  rescue YAML::SyntaxError => e
    raise "YAML syntax error occurred while parsing #{ yaml }. " \
      "Please note that YAML must be consistently indented using spaces. Tabs are not allowed. " \
      "Error: #{ e.message }"
  end
end

require_all %w| lib/monkey_patches config/initializers lib app |

# config.ru takes care of firing up the sinatra server, so now all we have to
# do is sit back and relax
