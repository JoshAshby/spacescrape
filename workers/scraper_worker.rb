require 'redis'
require 'sidekiq'

class ScraperWorker
  include Sidekiq::Worker

  def play_nice_with url
    host = URI(url).host
    key = Redis.current.get Redis::Helpers.key(host, :nice)

    fail StandardError, "Attempted to be mean to #{ host }!" if key

    Redis.current.setex Redis::Helpers.key(host, :nice), 1, Time.now.utc
  end

  def perform url
    play_nice_with url
    Scraper.new url
  end
end
