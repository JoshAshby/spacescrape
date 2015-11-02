module Workflows
  class Scrape
    class Storer
      def call bus, env
        SpaceScrape.logger.debug "caching #{ env[:uri].to_s }"

        Webpage.update_or_create url: env[:uri].to_s do |m|
          m.links = env[:links]
          m.last_hit_at = Time.now.utc
        end

        SpaceScrape.cache.set "body:#{env[:uri].to_s}", env[:body]
      end
    end
  end
end
