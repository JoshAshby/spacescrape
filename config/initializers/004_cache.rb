require_relative '../../lib/cache'

module SpaceScrape
  module_function
  def cache
    @@cache ||= Cache.new base: SpaceScrape.root.join('cache/')
  end
end
