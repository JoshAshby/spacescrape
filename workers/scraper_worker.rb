require 'sidekiq'

class ScraperWorker
  include Sidekiq::Worker

  def self.cancel! jid
    Sidekiq.redis{ |c| c.setex "cancelled-#{jid}", 86400, 1 }
  end

  def cancelled?
    @cancel ||= Sidekiq.redis{ |c| c.exists "cancelled-#{jid}" }
  end

  def cancel!
    @cancel = true
  end

  def timeout
    @timeout ||= Setting.find{ name =~ 'play_nice_timeout' }.value.to_i
  end

  def requeue!
    cancel!

    jitter_threshold = Setting.find{ name =~ 'jitter_threshold' }.value.to_i

    jitter = SecureRandom.random_number jitter_threshold
    interval = timeout + jitter

    $logger.debug "Requeueing #{ @mid } for #{ interval }"

    ScraperWorker.perform_in interval, @mid
  end

  def perform mid
    @mid = mid
    @webpage = Webpage.find id: @mid
    return cancel! unless @webpage

    $logger.debug "Planning on scrapping #{ @mid }"

    scraper = Scraper.new url: @webpage.url
    scrape = scraper.scrape

    return cancel!  if scrape == :abort
    return requeue! if scrape == :retry

    webpage.update title: scrape.title
    webpage.page = scrape.body
  end
end
