require 'typhoeus'
require 'typhoeus/adapters/faraday'

require 'faraday'
require 'faraday_middleware'

module Workflows
  class Scrape
    class Fetcher
      def initialize conn: nil, user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:40.0) Gecko/20100101 Firefox/40.1'
        @user_agent = user_agent

        @conn = conn || Faraday.new(headers: {
          'Accept-Language' => 'en',
          'User-Agent' => @user_agent,
          'Accept' => 'text/html; charset=utf-8'
        }) do |builder|
          # builder.use Faraday::Response::Logger,          SpaceScrape.logger
          builder.use FaradayMiddleware::FollowRedirects, limit: 3

          builder.adapter :typhoeus
        end
      end

      def call bus, payload
        SpaceScrape.logger.debug "Fetching url for #{ payload.uri.to_s }"

        # TODO: handle errors
        payload.res = @conn.get payload.uri.to_s
        payload.body = payload.res.body

        bus.publish to: 'doc:fetched', data: payload
      rescue FaradayMiddleware::RedirectLimitReached, Faraday::TimeoutError, URI::InvalidURIError
        SpaceScrape.logger.error "Problem in fetcher for #{ payload.uri.to_s }"
      end
    end
  end
end
