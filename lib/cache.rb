require 'digest'

class Cache
  def initialize base: 'cache/'
    @base = Pathname.new base

    FileUtils.mkdir_p SpaceScrape.root.join(base)
  end

  def key name
    digest = Digest::SHA256.new << name
    digest.hexdigest
  end

  def get name
    SpaceScrape.logger.debug "Fetching cache for #{ name }"
    File.read cache_path(name) if cached?(name)
  end

  def set name, v
    SpaceScrape.logger.debug "Writing cache for #{ name }"
    length = File.write cache_path(name), v
    SpaceScrape.logger.debug "Cached #{ length } bytes"

    length
  end

  def clear name
    FileUtils.rm cache_path(name) if cached?(name)
  end

  def cached? name
    File.exist? cache_path(name)
  end

  protected

  def cache_path name
    sha_hash = key name

    cache_key = [ sha_hash[0..1], sha_hash[2..3], sha_hash[4..-1] ]

    dirname = @base.join *cache_key[0..1]
    FileUtils.mkdir_p dirname

    dirname.join cache_key[2]
  end
end
