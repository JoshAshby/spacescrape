require 'sinatra/base'
require 'sidekiq/web'

require 'haml'
require 'tilt/haml'

require 'erb'
require 'tilt/erb'

class ApplicationController < Sinatra::Base
  set :views, -> { SpaceScrape.root.join 'app/views' }
end
