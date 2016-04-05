class Webpage < Sequel::Model
  def validate
    super

    errors.add :url, 'cannot be empty' if url.blank?
  end

  def body
    SpaceScrape.cache.get "body:#{ url }"
  end

  def content
    SpaceScrape.cache.get "content:#{ url }"
  end
end
