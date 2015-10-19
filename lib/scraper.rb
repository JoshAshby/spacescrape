require 'mechanize'

class Scraper
  attr_accessor :url

  def initialize(url:)
    @url = url
  end

  def scrape links: true
    return :abort if already_scraped? || blacklisted? || maxed_out?
    return :retry if in_timeout?

    raw_page = agent.get url

    # Not really sure why this is needed, but sometimes the page object doesn't respond to over half of the mechanize page instance methods that is should
    return :abort unless raw_page.respond_to? :content_type
    return :abort unless raw_page.content_type =~ /html/

    go_to_timeout!

    $logger.debug "Going thru with scraping #{ url }..."

    # TODO: How to get rid of this so that this isn't dependant on the
    # worker...
    if links
      raw_page.links.each do |link|
        next if link.resolved_uri.to_s.split('#', 2).first == url.split('#', 2).first

        ScraperWorker.perform_async link.resolved_uri
      end
    end

    raw_page
  rescue Mechanize::UnsupportedSchemeError, Mechanize::ResponseCodeError => e
    $logger.warn e

    return :abort
  rescue Mechanize::RobotsDisallowedError => e
    $logger.warn e

    Blacklist.update_or_create pattern: "%#{URI(@url).host}%" do |model|
      model.reason = [ model.reason, "robots.txt prevents bots" ].join
    end

    return :abort
  rescue Sequel::DatabaseError, Sequel::PoolTimeout => e
    $logger.warn e

    return :retry
  end

  protected

  def agent
    unless @agent
      @agent = Mechanize.new
      @agent.log = $logger
      @agent.user_agent_alias = 'Mac Mozilla'
    end

    @agent
  end

  def uri
    @uri ||= URI url
  end

  def host
    @host ||= uri.host
  end

  def timeout
    @timeout ||= Setting.find{ name =~ 'play_nice_timeout' }.value.to_i
  end

  def in_timeout?
    $logger.debug "Checking timeout for #{ host }"
    key = Redis.current.get Redis::Helpers.key(host, :nice)
    return true if key
  end

  def go_to_timeout!
    $logger.debug "Going into timeout for domain #{ host }"
    Redis.current.setex Redis::Helpers.key(host, :nice), timeout, Time.now.utc.iso8601
  end

  def maxed_out?
    max = Setting.find{ name =~ 'max_scrapes' }.value.to_i
    count = Webpage.count
    $logger.debug "Count is #{ count } with max #{ max } while checking #{ url }"
    return count >= max
  end

  def blacklisted?
    $logger.debug "Checking blacklist for #{ url }"
    return Blacklist.where do
      like(lower('google'), domain) |  like(lower('wikipedia'), pattern)
    end.any?
  end
end
