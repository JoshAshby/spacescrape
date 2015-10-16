#\ -p 4567

require './spacescrape'

require 'sidekiq/web'

run Rack::URLMap.new('/' => MainApp, '/sidekiq' => Sidekiq::Web)
