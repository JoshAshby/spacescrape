module Workflows
  class Scrape
    class Storer
      def call bus, payload
        if payload.body.blank?
          return bus.stop!
        end

        payload.webpage = Models::Webpage.update_or_create url: payload.uri.to_s do |m|
          m.links = payload.links
          m.last_hit_at = Time.now.utc
        end

        SpaceScrape.cache.set "body:#{ payload.uri.to_s }", payload.body

        bus.publish to: 'doc:stored', data: payload
      end
    end
  end
end
