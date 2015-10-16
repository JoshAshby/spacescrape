require 'redis'
require 'sidekiq'

class ScraperWorker
  include Sidekiq::Worker

  def self.cancel! jid
    Sidekiq.redis{ |c| c.setex "cancelled-#{jid}", 86400, 1 }
  end

  def cancelled?
    Sidekiq.redis{ |c| c.exists "cancelled-#{jid}" }
  end

  def cancel!
    Sidekiq.redis{ |c| c.setex "cancelled-#{jid}", 86400, 1 }
  end

  def timeout
    @timeout ||= Setting.find{ name =~ 'play_nice_timeout' }.value.to_i
  end

  def requeue
    cancel!

    jitter = SecureRandom.random_number 10
    ScraperWorker.perform_in (timeout + jitter), @url
  end

  def host
    @host ||= URI(@url).host
  end

  def play_nice_with
    key = Redis.current.get Redis::Helpers.key(host, :nice)

    return requeue if key

    Redis.current.setex Redis::Helpers.key(host, :nice), timeout, Time.now.utc
  end

  def check_if_done
    hostname = host
    doc = Scrape.find{ domain =~ hostname }

    cancel! if doc
  end

  def perform url
    @url = url
    check_if_done
    play_nice_with

    return if cancelled?

    Scraper.new @url
  end
end
