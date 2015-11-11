module Workflows
  class Extract
    class StoreContent
      def call bus, payload
        SpaceScrape.cache.set "content:#{ payload.uri.to_s }", payload.content

        bus.publish to: 'doc:stored', data: payload
      end
    end
  end
end
