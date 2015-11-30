module Workflows
  class Scrape
    class Timeouter
      def call bus, payload
        in_timeout = Redis.current.get Redis::Helpers.key(payload.uri.host, :nice)

        unless in_timeout
          Redis.current.setex Redis::Helpers.key(payload.uri.host, :nice), timeout, Time.now.utc.iso8601
          return
        end

        bus.publish to: 'request:reschedule', data: timeout
        bus.stop!
      end

      def timeout
        @min ||= Models::Setting.find({ name: 'timeout_min' }).value.to_i
        @max ||= Models::Setting.find({ name: 'timeout_max' }).value.to_i

        @jitter_threshold ||= @max - @min
        jitter = SecureRandom.random_number @jitter_threshold

        timeout ||= @min + jitter
      end
    end
  end
end
