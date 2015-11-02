class Webpage < Sequel::Model
  def validate
    super

    errors.add :url, 'cannot be empty' if !url || url.empty?
  end

  def before_save
    return false if super == false

    self.url = url
    # self.sha_hash = SpaceScrape.cache.key url
  end
end
