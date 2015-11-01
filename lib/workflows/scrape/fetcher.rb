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

      def call bus, env
        @model = env[:model]

        go_to_timeout!

        SpaceScrape.logger.debug "Fetching url for #{ @model.uri }"

        # TODO: handle errors
        res = @conn.get @model.uri.to_s

        bus.publish to: 'doc:fetched', data: env.merge({ body: res.body })
      rescue FaradayMiddleware::RedirectLimitReached, Faraday::TimeoutError, URI::InvalidURIError
        SpaceScrape.logger.error "Problem in fetcher for #{ @model.url }"
      end

      protected

      def get_timeout
        out = Setting.find{ name =~ 'play_nice_timeout' }.value.to_i
        jitter = Setting.find{ name =~ 'play_nice_jitter_threshold' }.value.to_i

        out + SecureRandom.random_number(jitter)
      end

      def go_to_timeout!
        timeout = get_timeout
        SpaceScrape.logger.debug "Going into a #{ timeout }s long timeout for domain #{ @model.uri.host }"
        Redis.current.setex Redis::Helpers.key(@model.uri.host, :nice), timeout, Time.now.utc.iso8601
      end
    end
  end
end
