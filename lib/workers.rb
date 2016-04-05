module Workers
  class BaseSneaker
    include Sneakers::Worker

    class << self
      attr_accessor :routing_key

      def perform_async *args, **opts
        exchange = SpaceScrape.bunny.create_channel.direct 'spacescrape.workers'

        data = JSON.dump({ args: args, opts: opts })

        exchange.publish data, routing_key: @routing_key, content_type: 'application/json'
      end

      def work_from *args, **opts
        parts = Array(args).flatten
        @queue_name  = parts.unshift('spacescrape').join '.'

        @queue_opts  = {
          env: nil,
          exchange: 'spacescrape.workers',
          exchange_type: :direct,
          queue_options: {
            durable: false,
            auto_delete: false
          },
          exchange_options: {
            durable: false,
            auto_delete: false
          }
        }.merge(opts)

        @routing_key = parts.join '.'
      end
    end

    def perform *args
      fail NotImplementedError
    end

    def work msg
      data = JSON.parse msg

      args = data['args']
      opts = data['opts'].symbolize_keys unless data['opts'] == {}

      perform(*args, **opts)
    end
  end
end
