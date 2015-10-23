require 'readability'
require 'loofah'

class Analyzer
  def call bus, env
    @env = env
    @document = env[:content]

    bus.publish to: 'doc:analyzed', data: env.merge({ analysis: analyze! })
  end

  def word_count
    unless @word_count
      @word_count = 0.00
      @document.scan(/[[:alpha:]]+/) { @word_count += 1 }
    end

    @word_count
  end

  def keyword_relevance
    @keyword_matches ||= Keyword.inject({ occurrences: {}, relevance: {} }) do |memo, keyword|
      occurrences = 0.00
      @document.downcase.scan(keyword.keyword) { occurrences += 1 }

      weighted_match = ( occurrences / word_count ) * keyword.weight.to_f

      memo[:relevance].merge!({ keyword.keyword => weighted_match })
      memo[:occurrences].merge!({ keyword.keyword => occurrences })

      memo
    end
  end

  def analyze!
    {
      word_count: word_count,
      keyword: keyword_relevance
    }
  end
end
