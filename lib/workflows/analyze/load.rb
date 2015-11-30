module Workflows
  class Analyze
    class Load
      def call bus, payload
        payload.webpage = Models::Webpage.find id: payload.webpage_id
        return bus.stop! unless payload.webpage

        payload.uri = URI.parse payload.webpage.url
        payload.content = SpaceScrape.cache.get "content:#{ payload.uri.to_s }"

        bus.publish to: 'doc:loaded', data: payload
      end
    end
  end
end
