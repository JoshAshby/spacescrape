require 'digest'
require 'pathname'
require 'uri'

require 'mechanize'
require 'readability'
require 'loofah'

class Scraper
  def initialize url
    @page = agent.get url
    return unless @page.content_type =~ /html/

    content = Readability::Document.new @page.body

    doc = Loofah.fragment(content.content).scrub!(:strip)

    debugger

    @page.links.each{ |link| queue_link link.resolved_uri }

    save_cache
  end

  def agent
    @agent ||= Mechanize.new
  end

  def sha_hash
    @sha_hash ||= Digest::SHA256.new << @page.body
  end

  def queue_link link
  end

  def filename
    ext = Pathname.new( @page.filename ).extname
    [ sha_hash, ext ].join
  end

  def save_cache
    filepath = File.join 'crawler_cache/', filename

    # TODO: dir by hash parts? things?
    File.write filepath, @page.content.to_s
  end
end
