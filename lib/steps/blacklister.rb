class Blacklister
  def call bus, env
    model = env[:model]
    blacklists = DB[:blacklists].select(:pattern).map do |a|
      Regexp.new a[:pattern]
    end

    blacklisted = blacklists.any? do |p|
      model.url =~ p || model.uri.host =~ p
    end

    if model.url.match 'wiki(.*).org'
      blacklisted = true unless model.url.match 'en.wiki(.*).org'
    end

    return unless blacklisted

    bus.publish to: 'request:cancel', data: env
    bus.stop!
  end
end
