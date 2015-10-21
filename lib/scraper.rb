module Scraper
  module_function
  def pipeline
    PubsubPipeline.new do |pubsub|
      pubsub.subscribe to: 'doc:async' do |bus, url|
        webpage = Webpage.find_or_create url: url
        ScraperWorker.perform_async webpage.id
      end

      pubsub.subscribe to: 'doc:sync' do |bus, url|
        webpage = Webpage.find_or_create url: url
        bus.publish to: 'doc:prefetch', data: webpage
      end

      pubsub.subscribe to: 'doc:prefetch' do |bus, model|
        next unless model.cached?

        bus.publish to: 'doc:cached', data: { model: model, body: model.cache }
        bus.stop!
      end

      pubsub.subscribe to: 'doc:prefetch' do |bus, model|
        next unless Redis.current.get Redis::Helpers.key(model.uri.host, :nice)

        bus.publish to: 'request:retry'
        bus.stop!
      end

      pubsub.subscribe to: 'doc:prefetch' do |bus, model|
        next unless Webpage.count >= Setting.find{ name =~ 'max_scrapes' }.value.to_i

        bus.publish to: 'request:cancel'
        bus.stop!
      end

      pubsub.subscribe to: 'doc:prefetch' do |bus, model|
        next unless Blacklist.where do |a|
          a.like(a.lower(model.url), a.pattern) |  a.like(a.lower(model.uri.host), a.pattern)
        end.any?

        bus.publish to: 'request:cancel'
        bus.stop!
      end

      pubsub.subscribe to: 'doc:prefetch' do |bus, model|
        bus.publish to: 'doc:fetch', data: { model: model }
      end

      pubsub.subscribe to: 'doc:fetch',              with: Roboter
      pubsub.subscribe to: 'doc:fetch',              with: Fetcher
      pubsub.subscribe to: /^doc:(fetched|cached)$/, with: Parser
      pubsub.subscribe to: 'doc:parsed',             with: Extractor
      pubsub.subscribe to: 'doc:extracted',          with: Analyzer

      pubsub.subscribe to: 'doc:parsed' do |bus, env|
        SpaceScrape.logger.debug "caching #{ env[:model] }"

        env[:model].update title: env[:nokogiri].title
        env[:model].save
        env[:model].cache = env[:body]
      end
    end
  end
end
