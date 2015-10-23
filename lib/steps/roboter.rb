require 'typhoeus'
require 'typhoeus/adapters/faraday'

require 'faraday'
require 'faraday_middleware'

require 'robotstxt'

class Roboter
  def initialize user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:40.0) Gecko/20100101 Firefox/40.1'
    @user_agent = user_agent

    @conn = Faraday.new headers: {
      'Accept-Language' => 'en',
      'User-Agent' => @user_agent,
      'Accept' => 'text/plain; charset=utf-8'
    } do |builder|
      # builder.use Faraday::Response::Logger, SpaceScrape.logger

      builder.adapter :typhoeus
    end
  end

  def call bus, env
    @model = env[:model]

    return if allowed?

    SpaceScrape.logger.debug "#{ @model.uri } isn't allowed"
    bus.publish to: 'request:cancel', data: env
    bus.stop!
  end

  protected

  def allowed?
    cache_name = "parser:#{ @model.uri.host }"

    if SpaceScrape.cache.cached? cache_name
      raw = SpaceScrape.cache.get cache_name
      parser = Marshal.load raw
    else
      res = @conn.get @model.uri + '/robots.txt'
      parser = Robotstxt.parse res.body, @user_agent

      raw = Marshal.dump parser
      SpaceScrape.cache.set cache_name, raw
    end

    parser.allowed? @model.url
  rescue Faraday::TimeoutError, URI::InvalidURIError
    SpaceScrape.logger.error "Problem in fetcher for #{ @model.url }"
    false
  end
end
