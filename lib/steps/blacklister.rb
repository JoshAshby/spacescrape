class Blacklister
  def call bus, env
    model = env[:model]
    blacklisted = Blacklist.where do |a|
      a.like(a.lower(model.url), a.pattern) |  a.like(a.lower(model.uri.host), a.pattern)
    end.any?


    if model.url.match 'wikipedia.org'
      blacklisted = true unless model.url.match 'en.wikipedia.org'
    end

    return unless blacklisted

    bus.publish to: 'request:cancel'
    bus.stop!
  end
end
