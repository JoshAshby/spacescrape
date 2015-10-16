require 'digest'
require 'pathname'
require 'uri'

require 'mechanize'

class Scraper
  def initialize url
    @url = url
    scrape
  end

  def scrape
    @page = agent.get @url
    return unless @page.content_type =~ /html/

    save_cache
    save_scrape

    analyze

    @page.links.each{ |link| queue_link link.resolved_uri }
  end

  def analyze
    Analyzer.new @page.body
  end

  def agent
    @agent ||= Mechanize.new
  end

  def sha_hash
    @sha_hash ||= Digest::SHA256.new << @page.body
  end

  def queue_link link
  end

  def save_cache
    # There is probably a better way to do this...
    ext = Pathname.new( @page.filename ).extname
    filename = [ sha_hash, ext ].join

    hash_start  = filename.slice! 0..2
    start_path = File.join 'crawler_cache/', hash_start
    Dir.mkdir start_path  unless Dir.exist? start_path

    hash_middle  = filename.slice! 0..2
    middle_path = File.join start_path, hash_middle
    Dir.mkdir middle_path  unless Dir.exist? middle_path

    filepath = File.join middle_path, filename
    File.write filepath, @page.content.to_s
  end

  def save_scrape
  end
end
