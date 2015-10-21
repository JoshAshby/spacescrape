require 'typhoeus'
require 'typhoeus/adapters/faraday'

require 'faraday'
require 'faraday_middleware'

require 'robotstxt'

class Fetcher
  def initialize user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:40.0) Gecko/20100101 Firefox/40.1'
    @user_agent = user_agent

    @conn = Faraday.new headers: {
      'Accept-Language' => 'en',
      'User-Agent' => @user_agent,
      'Accept' => 'text/html; charset=utf-8'
    } do |builder|
      builder.use Faraday::Response::Logger,          $logger
      builder.use FaradayMiddleware::FollowRedirects, limit: 3

      builder.adapter :typhoeus
    end
  end

  def call bus, env
    @model = env[:model]

    unless allowed?
      $logger.debug "#{ @model.uri } isn't allowed"
      bus.publish to: 'request:cancel'
      return
    end

    go_to_timeout!

    $logger.debug "Fetching url for #{ @model.uri }"

    # TODO: handle errors
    res = @conn.get @model.uri.to_s

    bus.publish to: 'doc:fetched', data: env.merge({ body: res.body })
  end

  protected

  def get_robots
    res = @conn.get @model.uri + '/robots.txt'
    Robotstxt.parse res.body, @user_agent
  end

  def allowed?
    get_robots.allowed? @model.uri.to_s
  end

  def timeout
    @timeout ||= Setting.find{ name =~ 'play_nice_timeout' }.value.to_i
  end

  def go_to_timeout!
    $logger.debug "Going into a #{ timeout }s long timeout for domain #{ @model.uri.host }"
    Redis.current.setex Redis::Helpers.key(@model.uri.host, :nice), timeout, Time.now.utc.iso8601
  end
end
