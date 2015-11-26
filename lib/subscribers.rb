module Subscribers
  class Async
    include Sneakers::Worker

    class << self
      attr_accessor :namespace

      def subscribe(to:, **opts)
        @namespace  = Array(to).flatten.join '.'
        @queue_name = "spacescrape.pubsub.#{ @namespace }"
        @queue_opts = { env: nil, durable: false, exchange: 'spacescrape.pubsub', exchange_type: :topic }.merge(opts)
      end
    end

    def work_with_params msg, delivery_info, metadata
      data = JSON.parse msg

      data_args = data['args']
      data_opts = data['opts'].symbolize_keys unless data['opts'] == {}

      func = delivery_info[:routing_key].gsub("#{ self.class.namespace.to_s }.", '')

      send(func.to_sym, *data_args, **data_opts)

      ack!
    ensure
      ack!
    end
  end

  module_function
  def publish *args, to:, **opts
    exchange = SpaceScrape.bunny.create_channel.topic 'spacescrape.pubsub'

    data = JSON.dump({ args: args, opts: opts })

    exchange.publish data, routing_key: to, content_type: 'application/json'
  end
end
