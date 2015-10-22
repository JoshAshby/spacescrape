class Timeouter
  def call bus, env
    model = env[:model]

    in_timeout = Redis.current.get Redis::Helpers.key(model.uri.host, :nice)
    return unless in_timeout

    bus.publish to: 'request:retry'
    bus.stop!
  end
end
