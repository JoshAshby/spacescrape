require 'typhoeus'
require 'typhoeus/adapters/faraday'

require 'faraday'
require 'faraday_middleware'

class Fetcher
  def initialize user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:40.0) Gecko/20100101 Firefox/40.1'
    @user_agent = user_agent

    @conn = Faraday.new headers: {
      'Accept-Language' => 'en',
      'User-Agent' => @user_agent,
      'Accept' => 'text/html; charset=utf-8'
    } do |builder|
      builder.use Faraday::Response::Logger,          SpaceScrape.logger
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
  end

  protected

  def timeout
    @timeout ||= Setting.find{ name =~ 'play_nice_timeout' }.value.to_i
  end

  def go_to_timeout!
    SpaceScrape.logger.debug "Going into a #{ timeout }s long timeout for domain #{ @model.uri.host }"
    Redis.current.setex Redis::Helpers.key(@model.uri.host, :nice), timeout, Time.now.utc.iso8601
  end
end
