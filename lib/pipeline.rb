class Pipeline
  def initialize(model:)
  end

  protected

  def timeout
    @timeout ||= Setting.find{ name =~ 'play_nice_timeout' }.value.to_i
  end

  def in_timeout?
    $logger.debug "Checking timeout for #{ host }"
    key = Redis.current.get Redis::Helpers.key(host, :nice)
    return true if key
  end

  def go_to_timeout!
    $logger.debug "Going into timeout for domain #{ host }"
    Redis.current.setex Redis::Helpers.key(host, :nice), timeout, Time.now.utc.iso8601
  end

  def maxed_out?
    return false
    max = Setting.find{ name =~ 'max_scrapes' }.value.to_i
    count = Webpage.count
    $logger.debug "Count is #{ count } with max #{ max } while checking #{ url }"
    return count >= max
  end

  def blacklisted?
    $logger.debug "Checking blacklist for #{ url }"
    return Blacklist.where do
      like(lower('google'), pattern) |  like(lower('wikipedia'), pattern)
    end.any?
  end
end
