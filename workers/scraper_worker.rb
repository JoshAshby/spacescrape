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
    $logger.debug "Planning on scrapping #{ @id }"

    scraper = Scraper.new url: @webpage.url
    scrape = scraper.scrape!

    $logger.debug "Scraped #{ @id } with result: #{ scrape.kind_of?(Symbol) ? scrape : 'document' }"

    return cancel!  if scrape == :abort
    return requeue! if scrape == :retry

    $logger.debug "Updating #{ @id } with scraped info"

    @webpage.update title: scrape.title
    @webpage.cache = scrape.body
  end

  def perform id
    @id, @webpage = id, Webpage.find(id: id)
    return cancel! unless @webpage

    scrape unless @webpage.cached?

    $logger.debug "Extracting and analyzing #{ @id }"

    extractor = Extractor.new(html: @webpage.cache)
    extract   = extractor.extract!
    analyzer  = Analyzer.new(document: extract)
    analyze   = analyzer.analyze!

    $logger.ap analyze

    $logger.debug "Queueing links for #{ @id }"

    extractor.links.each do |link|
      link_webpage = Webpage.find_or_new url: link
      next unless link_webpage.new?

      link_webpage.save
      self.class.perform_async link_webpage.id
    end

    $logger.debug "All done with #{ @id }"
  end
end
