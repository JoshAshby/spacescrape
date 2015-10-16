class Webpage < Sequel::Model
  def self.fetch uri
    Webpage.find_or_create url: uri do |model|
      model.sha_hash = Digest::SHA256.new << uri
    end
  end

  def scraper
    @scraper ||= Scraper.new page: self
  end

  def scrape
    scraped_page = scraper.scrape

    self.page = scraped_page.body
    update title: scraped_page.title, domain: scraped_page.uri.host

    scraped_page
  end

  def analyzer
    @analyzer ||= Analyzer.new @page
  end

  def analyze
    analyzer.analyze
  end

  def page= v
    File.write cache_path, v
    @page = v
  end

  def page
     @page ||= File.read cache_path if cached?
  end

  def cache_key
    @cache_key ||= [ sha_hash[0..1], sha_hash[2..3], sha_hash[4..-1] ]
  end

  def cache_directory
    unless @dirname
      @dirname = File.join 'crawler_cache', *cache_key[0..1]
      FileUtils.mkdir_p @dirname
    end

    @dirname
  end

  def cache_path
    @filepath ||= File.join cache_directory, cache_key[2]
  end

  def cached?
    return false unless sha_hash
    @cached ||= File.exist? cache_path
  end
end
