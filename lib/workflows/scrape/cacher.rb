module Workflows
  class Scrape
    class Cacher
      def call bus, env
        model = env[:model]
        return unless model.cached?

        env.body = model.cache
        bus.publish to: ['doc:cached', 'doc:fetched'], data: env
        bus.stop!
      end
    end
  end
end
