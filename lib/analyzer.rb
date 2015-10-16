require 'readability'
require 'loofah'

class Analyzer
  def initialize html
    @document = html

    analyze
  end

  def readability
    @readability ||= Readability::Document.new @document
  end

  def loofah
    @loofah ||= Loofah.fragment content
  end

  def content
    @content ||= readability.content
  end

  def sanitized
    @sanitized ||= loofah.scrub!( :strip ).text
  end

  def analyze
    ap sanitized.scan(/[[:alpha:]]+/).count
  end
end
