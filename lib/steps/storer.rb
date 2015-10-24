class Storer
  def call bus, env
    SpaceScrape.logger.debug "caching #{ env[:model] }"

    env[:model].update title: env[:nokogiri].title
    env[:model].cache = env[:body] unless env[:model].cached?

    Parse.create webpage: env[:model], parsed_at: Time.now

    env[:links].each do |link|
      Link.create webpage: env[:model], url: link
    end
  end
end
