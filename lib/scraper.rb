require 'mechanize'

class Scraper
  attr_accessor :url, :page

  def initialize url: nil, page: nil
    @url, @page = url, page
  end

  def agent
    unless @agent
      @agent = Mechanize.new
      @agent.user_agent_alias = 'Mac Mozilla'
    end

    @agent
  end

  def host
    @host ||= URI(url).host
  end

  def url
    unless @url
      @uri = URI @page.url
      @url = [ @uri.scheme, '://', @uri.host, @uri.path, @uri.query ].join
    end

    @url
  end

  def page
    @page ||= Webpage.find_or_new url: url do |model|
      model.sha_hash = Digest::SHA256.new << url
    end
  end

  def timeout
    @timeout ||= Setting.find{ name =~ 'play_nice_timeout' }.value.to_i
  end

  def in_timeout?
    key = Redis.current.get Redis::Helpers.key(host, :nice)
    return true if key
  end

  def go_to_timeout!
    Redis.current.setex Redis::Helpers.key(host, :nice), timeout, Time.now.utc.iso8601
  end

  def maxed_out?
    max = Setting.find{ name =~ 'max_scrapes' }.value.to_i
    return Webpage.count >= max
  end

  def cached?
    return page.cached?
  end

  def blacklisted?
    domain = Domain.find domain: [ host, url ]
    return unless domain
    return domain.blacklist
  end

  def play_nice?
    return :requeue if in_timeout?
    return :cancel  if maxed_out?
    return :cancel  if cached?
    return :cancel  if blacklisted?
  end

  def scrape links: true
    raw_page = agent.get url
    return unless raw_page.content_type =~ /html/

    go_to_timeout!

    if links
      scrape.links.each do |link|
        next if link.resolved_uri.to_s.split('#', 2).first == page.url

        self.class.perform_async link.resolved_uri
      end
    end

    raw_page
  rescue Mechanize::UnsupportedSchemeError, Mechanize::ResponseCodeError => e
    $logger.warn e

    Domain.update_or_create domain: url do |model|
      model.reason = [ model.reason, e.message ].join
      model.blacklist = true
    end

    nil
  rescue Mechanize::RobotsDisallowedError => e
    $logger.warn e

    Domain.update_or_create domain: host do |model|
      model.reason = [ model.reason, "robots.txt prevents bots" ].join
      model.blacklist = true
    end

    nil
  rescue Sequel::DatabaseError, Sequel::PoolTimeout => e
    $logger.warn e

    self.class.perform_async url

    nil
  end
end
