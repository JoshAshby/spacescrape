require 'typhoeus'
require 'typhoeus/adapters/faraday'

require 'faraday'
require 'faraday_middleware'

require 'robotstxt'

class Fetcher
  attr_accessor :webpage

  def initialize
    @user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:40.0) Gecko/20100101 Firefox/40.1'
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
    @webpage = env

    $logger.debug "Fetching url for #{ @webpage }"

    bus.publish to: 'doc:cached', data: @webpage.cache if @webpage.cached?

    if in_timeout?
      bus.stop!
      bus.publish to: 'request:retry', data: timeout
      return
    end

    if blacklisted? || maxed_out? || !allowed?
      bus.stop!
      bus.publish to: 'request:cancel'
      return
    end

    go_to_timeout!

    # TODO: handle errors
    res = @conn.get @webpage.url

    @webpage.cache = res.body
    bus.publish to: 'doc:fetched', data: res.body
  end

  protected

  def get_robots
    res = @conn.get @webpage.uri + '/robots.txt'
    Robotstxt.parse res.body, @user_agent
  end

  def allowed?
    get_robots.allowed? @webpage.url
  end

  def timeout
    @timeout ||= Setting.find{ name =~ 'play_nice_timeout' }.value.to_i
  end

  def in_timeout?
    $logger.debug "Checking timeout for #{ @webpage.uri.host }"
    key = Redis.current.get Redis::Helpers.key(@webpage.host, :nice)
    return true if key
  end

  def go_to_timeout!
    $logger.debug "Going into timeout for domain #{ @webpage.uri.host }"
    Redis.current.setex Redis::Helpers.key(@webpage.uri.host, :nice), timeout, Time.now.utc.iso8601
  end

  def maxed_out?
    max = Setting.find{ name =~ 'max_scrapes' }.value.to_i
    count = Webpage.count
    $logger.debug "Count is #{ count } with max #{ max } while checking #{ @webpage.url }"
    return count >= max
  end

  def blacklisted?
    $logger.debug "Checking blacklist for #{ @webpage.url }"
    return Blacklist.where do |a|
      a.like(a.lower(@webpage.url), a.pattern) |  a.like(a.lower(@webpage.uri.host), a.pattern)
    end.any?
  end
end
