module Workflows
  class Extract
    class Load
      def call bus, payload
        payload.webpage = Webpage.find id: payload.webpage_id
        return bus.stop! unless payload.webpage

        payload.uri  = URI.parse payload.webpage.url
        payload.body = SpaceScrape.cache.get "body:#{ payload.uri.to_s }"

        bus.publish to: 'doc:loaded', data: payload
      end
    end
  end
end
