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
    cancel!

    jitter_threshold = Setting.find{ name =~ 'play_nice_jitter_threshold' }.value.to_i

    jitter = SecureRandom.random_number jitter_threshold
    interval = timeout + jitter

    $logger.debug "Requeueing #{ @id } for #{ interval }s from now"

    ScraperWorker.perform_in interval, @id
  end

  def perform id
    @id, @webpage = id, Webpage.find(id: id)
    return cancel! unless @webpage

    $logger.debug "Processing #{ @id } through pipeline..."

    pipeline = PubsubPipeline.new do |pubsub|
      pubsub.subscribe to: 'doc:fetch',              with: Fetcher
      pubsub.subscribe to: /^doc:(fetched|cached)$/, with: Parser
      pubsub.subscribe to: 'doc:parsed',             with: Extractor
      pubsub.subscribe to: 'doc:extracted',          with: Analyzer

      pubsub.subscribe to: 'doc:analyzed' do |bus, res|
        $logger.debug "Finished #{ @id } in job #{ jid } with: #{ res }"
      end

      pubsub.subscribe to: 'request:links' do |bus, links|
        $logger.debug "Parsing links for #{ @id }"

        links.each do |link|
          link_webpage = Webpage.find_or_new url: link
          next unless link_webpage.new?

          link_webpage.save
          self.class.perform_async link_webpage.id
        end
      end

      pubsub.subscribe to: 'request:cancel' do |bus, env|
        $logger.debug "Canceling job #{ jid } for #{ @id }"
        bus.stop!
        cancel!
      end

      pubsub.subscribe to: 'request:retry' do |bus, timeout|
        $logger.debug "Requeueing job #{ jid } for #{ @id }"
        bus.stop!
        requeue! timeout
      end
    end

    pipeline.publish to: 'doc:fetch', data: @webpage

    $logger.debug "All done with #{ @id }"
  end
end
