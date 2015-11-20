class Webpage < Sequel::Model
  def validate
    super

    errors.add :url, 'cannot be empty' if url.blank?
  end

  # def before_save
  #   return false if super == false

  #   # self.url = url
  #   # self.sha_hash = SpaceScrape.cache.key url
  # end

  def body
    SpaceScrape.cache.get "body:#{ url }"
  end

  def content
    SpaceScrape.cache.get "content:#{ url }"
  end
end
