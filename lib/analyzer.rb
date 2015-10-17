require 'readability'
require 'loofah'

class Analyzer
  attr_accessor :document

  def initialize(html:)
    @document = html
  end

  def sanitized
    @sanitized ||= loofah.scrub!( :strip ).text
  end

  def word_count
    unless @word_count
      @word_count = 0.00
      sanitized.scan(/[[:alpha:]]+/) { word_count += 1 }
    end

    @word_count
  end

  def keyword_relevance
    @keyword_matches ||= Keyword.inject({ occurences: {}, relevance: {} }) do |memo, keyword|
      occurrences = 0.00
      sanitized.downcase.scan(keyword.keyword) { occurrences += 1 }

      weighted_match = ( occurrences / word_count ) * keyword.weight.to_f

      memo[:relevance].merge({ keyword.keyword => weighted_match })
      memo[:occurrences].merge({ keyword.keyword => occurrences })
    end
  end

  def analyze
    {
      word_count: word_count,
      keyword: keyword_relevance
    }
  end

  protected

  def readability
    @readability ||= Readability::Document.new @document
  end

  def content
    @content ||= readability.content
  end

  def loofah
    @loofah ||= Loofah.fragment content
  end
end
