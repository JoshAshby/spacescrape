class Storer
  def call bus, env
    SpaceScrape.logger.debug "caching #{ env[:model] }"

    env[:model].update title: env[:nokogiri].title
    env[:model].set_cache env[:body]
  end
end
