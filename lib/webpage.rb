class Page
  def self.fetch url: nil, sha_hash: nil
    new(url: url, sha_hash: sha_hash).fetch
  end

  attr_accessor :url, :page

  def initialize url: nil, sha_hash: nil
    @sha_hash, @url = sha_hash, url
  end

  def fetch
    return fetch_cache if cached?

    scrape

    self
  end

  def scrape
    scraped_page = Scraper.new(@url).scrape

    @meta = Scrape.create do |model|
      model.title = scraped_page.title
      model.url = @url
      model.domain = scraped_page.uri.host
      model.sha_hash = sha_hash
    end

    @page = page.content
    write_cache

    @page
  end

  def analyze
    Analyzer.new(@page).analyze
  end

  def meta
    unless @meta
      @meta = Scrape.find{ url =~ @url }
      @sha_hash = @meta.sha_hash
    end

    @meta
  end

  def sha_hash
    @sha_hash ||= Digest::SHA256.new << @url
  end

  def cache_key
    @cache_key ||= [ @sha_hash[0..1], @sha_hash[2..3], @sha_hash[4..-1] ]
  end

  def cache_directory
    unless @dirname
      @dirname = File.join 'crawler_cache', *cache_key[0..1]
      FileUtils.mkdir_p @dirname
    end

    @dirname
  end

  def cache_path
    @filepath ||= File.join cache_directory, cache_key[3]
  end

  def cached?
    @cached ||= File.exist? cache_path
  end

  def fetch_cache
    @page ||= File.read cache_path
  end

  def write_cache
    File.write cache_path, @page
  end
end
