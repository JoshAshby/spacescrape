class Webpage < Sequel::Model
  def before_save
    return false if super == false

    self.url = self.url.split('#', 2).first
    self.sha_hash = Digest::SHA256.new << self.url
  end

  def cache= v
    File.write cache_path, v
    @cache = v
  end

  def cache
     @cache ||= File.read cache_path if cached?
  end

  def cached?
    return false unless sha_hash
    @cached ||= File.exist? cache_path
  end

  protected

  def cache_key
    @cache_key ||= [ sha_hash[0..1], sha_hash[2..3], sha_hash[4..-1] ]
  end

  def cache_directory
    unless @dirname
      @dirname = File.join 'crawler_cache', *cache_key[0..1]
      FileUtils.mkdir_p @dirname
    end

    @dirname
  end

  def cache_path
    @filepath ||= File.join cache_directory, cache_key[2]
  end
end
