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
      builder.use Faraday::Response::Logger, SpaceScrape.logger

      builder.adapter :typhoeus
    end
  end

  def call bus, env
    @model = env[:model]

    return unless allowed?

    SpaceScrape.logger.debug "#{ @model.uri } isn't allowed"
    bus.publish to: 'request:cancel'
  end

  protected

  def get_robots
    cache_name = "parser:#{ @model.uri.host }"

    if SpaceScrape.cache.cached? cache_name
      raw = SpaceScrape.cache.get cache_name
      parser = Marshal.load raw
      return parser
    end

    res = @conn.get @model.uri + '/robots.txt'
    parser = Robotstxt.parse res.body, @user_agent

    raw = Marshal.dump parser
    SpaceScrape.cache.set cache_name, raw

    parser
  end

  def allowed?
    get_robots.allowed? @model.uri.to_s
  end
end
