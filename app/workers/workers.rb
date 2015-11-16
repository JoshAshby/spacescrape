module Workers
  class BaseSneaker
    include Sneakers::Worker

    class << self
      def perform_async *args, **opts
        exchange = SpaceScrape.bunny.create_channel.direct "spacescrape.pipeline"

        data = JSON.dump({ args: args, opts: opts })

        exchange.publish data, routing_key: @queue_name.gsub('spacescrape.', ''), content_type: 'application/json'
      end
    end

    def perform *args
      fail NotImplementedError
    end

    def work msg
      data = JSON.parse msg

      args = data['args']
      opts = data['opts'].symbolize_keys unless data['opts'] == {}

      perform *args, **opts
    end
  end
end
