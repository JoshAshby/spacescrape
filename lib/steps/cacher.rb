class Cacher
  def call bus, env
    model = env[:model]
    return unless model.cached?

    bus.publish to: 'doc:cached', data: { model: model, body: model.cache }
    bus.stop!
  end
end
