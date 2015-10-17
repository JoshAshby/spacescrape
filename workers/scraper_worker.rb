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
    ScraperWorker.perform_in (timeout + jitter), @url
  end

  def perform url
    $logger.debug "Planning on scrapping #{ url }"

    hashless_url = url.split('#', 2).first
    uri = URI hashless_url

    scraper = Scraper.new url: hashless_url
    scrape = scraper.scrape

    return cancel! if scrape == :abort
    return requeue! if scrape == :retry

    Webpage.create url: hashless_url do |model|
      model.sha_hash = Digest::SHA256.new << hashless_url
      model.title = scrape.title
      model.domain = uri.host
    end
  end
end
