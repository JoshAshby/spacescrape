class Webpage < Sequel::Model
  def validate
    super

    errors.add :url, 'cannot be empty' if !url || url.empty?
  end

  def before_save
    return false if super == false

    self.url = url.split('#', 2).first
    self.sha_hash = SpaceScrape.cache.key url
  end

  def uri
    @uri ||= URI url
  end

  def host
    @host ||= uri.host
  end

  def cache= v
    SpaceScrape.cache.set url, v
  end

  def set_cache v
    SpaceScrape.cache.set url, v
  end

  def cache
    SpaceScrape.cache.get url
  end

  def clear_cache!
    SpaceScrape.cache.clear url
  end

  def cached?
    return false unless sha_hash
    SpaceScrape.cache.cached? url
  end
end