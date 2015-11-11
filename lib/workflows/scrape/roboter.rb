require 'typhoeus'
require 'typhoeus/adapters/faraday'

require 'faraday'
require 'faraday_middleware'

require 'robotstxt'

module Workflows
  class Scrape
    class Roboter
      def initialize conn: nil, user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:40.0) Gecko/20100101 Firefox/40.1'
        @user_agent = user_agent

        @conn = conn || Faraday.new(headers: {
          'Accept-Language' => 'en',
          'User-Agent' => @user_agent,
          'Accept' => 'text/plain; charset=utf-8'
        }) do |builder|
          # builder.use Faraday::Response::Logger, SpaceScrape.logger

          builder.adapter :typhoeus
        end
      end

      def call bus, payload
        return if allowed? payload.uri

        SpaceScrape.logger.debug "#{ payload.uri.to_s } isn't allowed"
        bus.publish to: 'request:cancel', data: payload.uri
        bus.stop!
      end

      protected

      def allowed? uri
        cache_name = "robots:#{ uri.host }"

        if SpaceScrape.cache.cached? cache_name
          raw = SpaceScrape.cache.get cache_name
          parser = Marshal.load raw
        else
          res = @conn.get uri + '/robots.txt'
          parser = Robotstxt.parse res.body, @user_agent

          raw = Marshal.dump parser
          SpaceScrape.cache.set cache_name, raw
        end

        parser.allowed? uri.to_s
      rescue Faraday::TimeoutError, URI::InvalidURIError
        SpaceScrape.logger.error "Problem in fetcher for #{ uri.to_s }"
        false
      end
    end
  end
end
