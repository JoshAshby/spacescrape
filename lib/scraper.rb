module Scraper
  module_function
  def pipeline
    PubsubPipeline.new do |pubsub|
      pubsub.subscribe to: 'doc:start' do |bus, url|
        webpage = Webpage.find_or_create url: url
        bus.publish to: 'doc:fetch', data: { model: webpage }
      end

      pubsub.subscribe to: 'doc:fetch',              with: Cacher
      pubsub.subscribe to: 'doc:fetch',              with: Timeouter
      pubsub.subscribe to: 'doc:fetch',              with: Blacklister
      pubsub.subscribe to: 'doc:fetch',              with: Roboter
      pubsub.subscribe to: 'doc:fetch',              with: Fetcher

      pubsub.subscribe to: /^doc:(fetched|cached)$/, with: Parser
      pubsub.subscribe to: 'doc:parsed',             with: Storer

      # pubsub.subscribe to: 'doc:parsed',             with: Extractor
      # pubsub.subscribe to: 'doc:extracted',          with: Analyzer
    end
  end

  def process url
    pipeline.publish to: 'doc:start', data: url
  end

  def process_async url
    webpage = Webpage.find_or_create url: url
    ScraperWorker.perform_async webpage.id
  end
end
