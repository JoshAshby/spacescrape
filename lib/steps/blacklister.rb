class Blacklister
  def call bus, env
    model = env[:model]
    blacklisted = Blacklist.where do |a|
      a.like(a.lower(model.url), a.pattern) |  a.like(a.lower(model.uri.host), a.pattern)
    end.any?

    return unless blacklisted

    bus.publish to: 'request:cancel'
    bus.stop!
  end
end
