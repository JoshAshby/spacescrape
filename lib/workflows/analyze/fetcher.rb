module Workflows
  class Analyze
    class Fetcher
      def call bus, url
        model = Webpage.find url: url
        body = SpaceScrape.cache.get "body:#{ url }"

        bus.publish to: 'doc:fetched', data: { url: url, model: model, body: body }
      end
    end
  end
end
