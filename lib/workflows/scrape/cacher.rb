module Workflows
  class Scrape
    class Cacher
      def call bus, payload
        payload.model = Models::Webpage.find url: payload.uri.to_s
        return unless payload.model

        cache_age = Time.now - payload.model.last_hit_at
        return if cache_age > 2.628e+6 # About a months worth of seconds...

        payload.body = SpaceScrape.cache.get "body:#{ payload.uri.to_s }"

        bus.publish to: 'request:links', data: payload.model.links
        bus.publish to: 'doc:cached',    data: payload
        bus.stop!
      end
    end
  end
end
