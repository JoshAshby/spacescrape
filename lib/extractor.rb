require 'readability'
require 'loofah'

class Extractor
  attr_accessor :html, :document

  def call bus, env
    @html = env
    bus.publish to: 'doc:extracted', data: extract!
  end

  def extract!
    @document ||= loofah.scrub!( :strip ).text
  end

  protected

  def readability
    @readability ||= Readability::Document.new @html
  end

  def content
    @content ||= readability.content
  end

  def loofah
    @loofah ||= Loofah.fragment content
  end
end
