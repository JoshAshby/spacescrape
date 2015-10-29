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

  def keyword_breakdown
    @breakdown ||= Keyword.inject({}) do |memo, keyword|
      occurrences = 0.00
      @document.downcase.scan(keyword.keyword) { occurrences += 1 }

      memo.merge({
        keyword.keyword => {
          weight: keyword.weight,
          occurrences: occurrences
        }
      })
    end
  end

  def keyword_distribution
    total_weight = keyword_breakdown.map do |k, v|
      v[:weight]
    end.sum

    dist = keyword_breakdown.map do |k, v|
      v[:weight] if v[:occurrences] > 0
    end

    dist / total_weight
  end

  def keyword_volume
    keyword_breakdown.map do |k, v|
      ( v[:occurences] / word_count.to_f ) * v[:weight]
    end.sum / keyword_breakdown.length
  end

  def analyze!
    {
      word_count: word_count,
      breakdown: keyword_breakdown,
      volume: keyword_volume,
      distribution: keyword_distribution
    }
  end
end
