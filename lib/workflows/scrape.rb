module Workflows
  class Scrape
    attr_accessor :pipeline

    def pipeline
      @pipeline ||= Pipelines::Pubsub.new do |pubsub|
        pubsub.subscribe to: 'doc:fetch',              with: Steps::Cacher
        pubsub.subscribe to: 'doc:fetch',              with: Steps::Timeouter
        pubsub.subscribe to: 'doc:fetch',              with: Steps::Blacklister
        pubsub.subscribe to: 'doc:fetch',              with: Steps::Roboter
        pubsub.subscribe to: 'doc:fetch',              with: Steps::Fetcher

        pubsub.subscribe to: /^doc:(fetched|cached)$/, with: Steps::Storer
      end
    end

    def process url
      pipeline.publish to: 'doc:fetch', data: package
    end
  end
end
