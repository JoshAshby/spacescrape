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

  def requeue! timeout
    timeout = 60 unless timeout
    cancel!

    jitter_threshold = Setting.find{ name =~ 'play_nice_jitter_threshold' }.value.to_i

    jitter = SecureRandom.random_number jitter_threshold
    interval = timeout + jitter

    $logger.debug "Requeueing #{ @id } for #{ interval }s from now"

    ScraperWorker.perform_in interval, @id
  end

  def perform id
    return requeue! unless $lock_manager.lock "model:webpage:#{ id }", 2000
    @id, @webpage = id, Webpage.find(id: id)
    return cancel! unless @webpage

    pipeline = Scraper.pipeline

    pipeline.subscribe to: /^doc:(fetched|cached)$/ do |bus, env|
      $lock_manager.unlock "model:webpage:#{ id }"
    end

    pipeline.subscribe to: 'request:links' do |bus, links|
      links.shuffle[0..1].each do |link|
        link_webpage = Webpage.find_or_new url: link
        next unless link_webpage.new?

        link_webpage.save
        self.class.perform_async link_webpage.id
      end
    end

    pipeline.subscribe to: 'request:cancel' do |bus|
      $logger.debug "Canceling job #{ jid }"
      cancel!
    end

    pipeline.subscribe to: 'request:retry' do |bus, timeout|
      $logger.debug "Requeueing job #{ jid }"
      requeue! timeout
    end

    $logger.debug "Processing #{ @id } through pipeline..."

    $logger.debug pipeline.publish(to: 'doc:prefetch', data: @webpage)

    $logger.debug "All done with #{ @id }"
  end
end
