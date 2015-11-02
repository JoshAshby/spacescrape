module Workflows
  class Scrape
    class Cacher
      def call bus, uri
        model = Webpage.find url: uri.to_s
        return unless model

        cache_age = Time.now - model.last_hit_at
        return if cache_age > 2.628e+6

        bus.publish to: 'request:links', data: model.links
        bus.publish to: 'doc:cached', data: uri
        bus.stop!
      end
    end
  end
end
