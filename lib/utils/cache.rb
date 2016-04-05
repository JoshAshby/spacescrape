require 'digest'

class Cache
  def initialize base: 'cache/'
    @base = Pathname.new base

    @base.mkpath
  end

  def key name
    digest = Digest::SHA256.new << name
    digest.hexdigest
  end

  def get name
    File.read cache_path(name) if cached?(name)
  end

  def set name, v
    File.write cache_path(name), v
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

    filename = @base.join sha_hash[0..1], sha_hash[2..3], sha_hash[4..-1]

    filename.parent.mkpath

    filename
  end
end
