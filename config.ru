require './spacescrape'
require 'sidekiq/web'

run Rack::URLMap.new('/' => ApplicationController, '/sidekiq' => Sidekiq::Web)
