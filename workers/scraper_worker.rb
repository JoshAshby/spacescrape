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

  def requeue! timeout=nil
    timeout = 60 unless timeout
    cancel!

    jitter_threshold = Setting.find{ name =~ 'play_nice_jitter_threshold' }.value.to_i

    jitter = SecureRandom.random_number jitter_threshold
    interval = timeout + jitter

    SpaceScrape.logger.debug "Requeueing #{ @id } for #{ interval }s from now"

    ScraperWorker.perform_in interval, @id
  end

  def perform id
    lock = SpaceScrape.lock_manager.lock "model:webpage:#{ id }", 2000
    return requeue! unless lock

    @id, @webpage = id, Webpage.find(id: id)
    return cancel! unless @webpage
    # return cancel! if @webpage.cached?

    scraper = Scraper.new

    scraper.pipeline.subscribe to: /^doc:(fetched|cached)$/ do |bus, env|
      SpaceScrape.lock_manager.unlock lock
    end

    # scraper.pipeline.subscribe to: 'request:links' do |bus, links|
    #   links.shuffle.each do |link|
    #     link_webpage = Webpage.find_or_new url: link
    #     next unless link_webpage.new?
    #     next unless link_webpage.valid?

    #     link_webpage.save
    #     self.class.perform_async link_webpage.id
    #   end
    # end

    scraper.pipeline.subscribe to: 'request:cancel' do |bus|
      SpaceScrape.logger.debug "Canceling job #{ jid }"
      cancel!
    end

    scraper.pipeline.subscribe to: 'request:retry' do |bus, timeout|
      SpaceScrape.logger.debug "Requeueing job #{ jid }"
      requeue! timeout
    end

    SpaceScrape.logger.debug "Processing #{ @id } through pipeline..."

    subs = scraper.process @webpage
    SpaceScrape.logger.debug subs
    SpaceScrape.logger.error "NO SUBSCRIBERS RECIEVED MESSAGE" unless subs

    SpaceScrape.logger.debug "All done with #{ @id }"

  rescue Sequel::PoolTimeout, Sequel::DatabaseError => e
    SpaceScrape.logger.warn "Encountered a problem with the database while working on the DB"
    SpaceScrape.logger.warn e

    requeue!
  end
end
