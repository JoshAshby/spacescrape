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
    @page = Webpage.find_or_new url: url do |model|
      model.sha_hash = Digest::SHA256.new << url
    end

    case @page.scraper.play_nice?
    when :reschedule
      return requeue!
    when :cancel
      return cancel!
    end

    scrape = @page.scrape
    return unless scrape

    @page.analyze
  end
end
