module Workflows
  class Train
    class Load
      def call bus, payload
        payload.webpage = Webpage.find id: payload.webpage_id
        payload.topic   = Topic.find   id: payload.topic_id
        return bus.stop! unless payload.webpage || payload.topic

        payload.uri     = URI.parse payload.webpage.url
        payload.content = SpaceScrape.cache.get "content:#{ payload.uri.to_s }"

        bus.publish to: 'doc:loaded', data: payload
      end
    end
  end
end
