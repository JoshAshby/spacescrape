require 'faraday'
require 'robotstxt'

class Fetcher
  attr_accessor :webpage

  def initialize
    @user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:40.0) Gecko/20100101 Firefox/40.1'
    @con = Faraday.new headers: { 'Accept-Language' => 'en', 'User-Agent' => @user_agent } do |faraday|
      builder.request   :html

      builder.response  :html, content_type: /\b(html)$/

      builder.adapter   :typhoeus
    end
  end

  def call bus, env
    @webpage = env
    bus.publish to: 'doc:fetched', data: fetch!
  end

  def fetch!
    return cache if cached?
    remote
  end

  protected

  def cached?
    @webpage.cached?
  end

  def cache
    @webpage.cache
  end

  def remote
    # TODO
    @con.get @webpage.url
    ""
  end

  def robots_allowed?
    get_robots.allowed? @webpage.url
  end

  def get_robots
    res = Faraday.get URI(@webpage.host).join('/robots.txt')
    Robotstxt.parse res.body, @user_agent
  end

  def timeout
    @timeout ||= Setting.find{ name =~ 'play_nice_timeout' }.value.to_i
  end

  def in_timeout?
    $logger.debug "Checking timeout for #{ @webpage.host }"
    key = Redis.current.get Redis::Helpers.key(@webpage.host, :nice)
    return true if key
  end

  def go_to_timeout!
    $logger.debug "Going into timeout for domain #{ @webpage.host }"
    Redis.current.setex Redis::Helpers.key(@webpage.host, :nice), timeout, Time.now.utc.iso8601
  end

  def maxed_out?
    max = Setting.find{ name =~ 'max_scrapes' }.value.to_i
    count = Webpage.count
    $logger.debug "Count is #{ count } with max #{ max } while checking #{ @webpage.url }"
    return count >= max
  end

  def blacklisted?
    $logger.debug "Checking blacklist for #{ @webpage.url }"
    return Blacklist.where do
      like(lower(@webpage.url), pattern) |  like(lower(@webpage.url), pattern)
    end.any?
  end
end
