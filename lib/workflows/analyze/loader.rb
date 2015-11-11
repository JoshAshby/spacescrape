module Workflows
  class Analyze
    class Loader
      def call bus, env
        model = Webpage.find id: env[:webpage]
        return bus.stop! unless model

        body = SpaceScrape.cache.get "body:#{ url }"

        bus.publish to: 'doc:loaded', data: { url: url, model: model, body: body }
      end
    end
  end
end
