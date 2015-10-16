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
    word_count = 0.00
    sanitized.scan(/[[:alpha:]]+/) { word_count += 1 }

    keyword_matches = Keyword.inject({}) do |memo, keyword|
      occurrences = 0.00
      sanitized.downcase.scan(keyword.keyword) { occurrences += 1 }

      weighted_match = ( occurrences / word_count ) * keyword.weight
      percentage_match = weighted_match * 100

      memo.merge({ keyword.keyword => percentage_match })
    end

    ap [
      word_count,
      keyword_matches
    ]
  end
end
