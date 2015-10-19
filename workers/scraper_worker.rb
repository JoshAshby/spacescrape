require 'sidekiq'

class ScraperWorker
  include Sidekiq::Worker

  def self.cancel! jid
    Sidekiq.redis{ |c| c.setex "cancelled-#{jid}", 86400, 1 }
  end

  def cancelled?
    @cancel ||= Sidekiq.redis{ |c| c.exists "cancelled-#{jid}" }
  end

  def cancel!
    @cancel = true
  end

  def timeout
    @timeout ||= Setting.find{ name =~ 'play_nice_timeout' }.value.to_i
  end

  def requeue!
    cancel!

    jitter_threshold = Setting.find{ name =~ 'play_nice_jitter_threshold' }.value.to_i

    jitter = SecureRandom.random_number jitter_threshold
    interval = timeout + jitter

    $logger.debug "Requeueing #{ @mid } for #{ interval }"

    ScraperWorker.perform_in interval, @mid
  end

  def scrape
    $logger.debug "Planning on scrapping #{ @mid }"

    scraper = Scraper.new(url: @webpage.url)
    scrape = scraper.scrape!

    $logger.debug "Scraped #{ @mid } with result: #{ scrape.kind_of?(Symbol) ? scrape : 'document' }"

    return cancel!  if scrape == :abort
    return requeue! if scrape == :retry

    $logger.debug "Updating #{ @mid } with scraped info"

    @webpage.update title: scrape.title
    @webpage.cache = scrape.body

    $logger.debug "Queueing links for #{ @mid }"

    scraper.links.each do |link|
      link_webpage = Webpage.find url: link
      next if link_webpage

      link_webpage = Webpage.create url: link
      self.class.perform_async link_webpage.id
    end
  end

  def perform mid
    @mid, @webpage = mid, Webpage.find(id: mid)
    return cancel! unless @webpage

    scrape unless @webpage.cached?

    $logger.debug "Extracting and analyzing #{ @mid }"

    extract = Extractor.new(html: @webpage.cache).extract!
    analyze = Analyzer.new(document: extract).analyze!

    $logger.ap analyze

    $logger.debug "All done with #{ @mid }"
  end
end
