require './spacescrape'
require 'sidekiq/web'

run Rack::URLMap.new('/' => Controllers::ApplicationController, '/sidekiq' => Sidekiq::Web)
