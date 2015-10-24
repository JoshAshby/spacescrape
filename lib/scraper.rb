class Scraper
  attr_accessor :pipeline

  def pipeline
    @pipeline ||= PubsubPipeline.new do |pubsub|
      pubsub.subscribe to: 'doc:start' do |bus, url|
        webpage = Webpage.find_or_create url: url
        bus.publish to: 'doc:fetch', data: { model: webpage }
      end

      pubsub.subscribe to: 'doc:fetch',              with: Cacher
      pubsub.subscribe to: 'doc:fetch',              with: Timeouter
      pubsub.subscribe to: 'doc:fetch',              with: Blacklister
      pubsub.subscribe to: 'doc:fetch',              with: Roboter
      pubsub.subscribe to: 'doc:fetch' do |bus, env|
        max = Setting.find(name: 'max_scrapes').value.to_i
        if Webpage.where{ title !~ nil }.count >= max
          bus.publish to: 'request:cancel'
          bus.stop!
        end
      end
      pubsub.subscribe to: 'doc:fetch',              with: Fetcher

      pubsub.subscribe to: /^doc:(fetched|cached)$/, with: Parser
      pubsub.subscribe to: 'doc:parsed',             with: Storer

      pubsub.subscribe to: 'doc:parsed',             with: Extractor
      pubsub.subscribe to: 'doc:extracted',          with: Analyzer
    end
  end

  def process url
    if url.kind_of? Webpage
      return pipeline.publish to: 'doc:fetch', data: { model: url }
    end

    pipeline.publish to: 'doc:start', data: url
  end

  def self.process_async url
    webpage = Webpage.find_or_create url: url
    ScraperWorker.perform_async webpage.id
  end
end
