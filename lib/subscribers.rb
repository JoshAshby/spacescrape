module PubSub
  class AsyncSubscriber
    include Sneakers::Worker

    class << self
      attr_accessor :namespace

      def subscribe(to:, **opts)
        @namespace  = to
        @queue_name = "spacescrape.pubsub.#{ @namespace }"
        @queue_opts = { env: nil, durable: false }.merge(opts)
      end
    end

    def work msg
      data = JSON.parse msg

      args = data['args']
      opts = data['opts'].symbolize_keys unless data['opts'] == {}

      debugger
    end
  end

  module_function
  def publish *args, to:, **opts, &block
    exchange = SpaceScrape.bunny.create_channel.direct 'spacescrape.pubsub'

    data = JSON.dump({ args: args, opts: opts })

    exchange.publish data, routing_key: to, content_type: 'application/json'
  end
end

module Subscribers
  class Pipeline < PubSub::AsyncSubscriber
    subscribe to: :pipeline

    def scraped *args
      debugger
    end
  end
end
