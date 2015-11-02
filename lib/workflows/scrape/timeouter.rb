module Workflows
  class Scrape
    class Timeouter
      def call bus, uri
        in_timeout = Redis.current.get Redis::Helpers.key(uri.host, :nice)

        unless in_timeout
          Redis.current.setex Redis::Helpers.key(uri.host, :nice), timeout, Time.now.utc.iso8601
          return
        end

        bus.publish to: 'request:reschedule', data: { uri: uri, timeout: timeout }
        bus.stop!
      end

      def timeout
        @min ||= Setting.find({ name: 'timeout_min' }).value.to_i
        @max ||= Setting.find({ name: 'timeout_max' }).value.to_i

        @jitter_threshold ||= @max - @min
        jitter = SecureRandom.random_number @jitter_threshold

        timeout ||= @min + jitter
      end
    end
  end
end
