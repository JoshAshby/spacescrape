module Workflows
  class Scrape
    class Timeouter
      def call bus, env
        in_timeout = Redis.current.get Redis::Helpers.key(env.model.uri.host, :nice)
        return unless in_timeout

        bus.publish to: 'request:reschedule', data: requeue_delay
        bus.stop!
      end

      def requeue_delay timeout: 60
        jitter_threshold = Setting.find({ name: 'play_nice_jitter_threshold' }).value.to_i
        jitter = SecureRandom.random_number jitter_threshold

        timeout + jitter
      end
    end
  end
end
