module Workers
  class RescheduleWorker
    include Sidekiq::Worker

    def self.cancel! jid
      Sidekiq.redis{ |c| c.setex "cancelled-#{jid}", 86400, 1 }
    end

    def cancel!
      @cancel = true
    end

    def cancelled?
      @cancel ||= Sidekiq.redis{ |c| c.exists "cancelled-#{jid}" }
    end

    def perform url
      Redis.current.del "rescheduled:#{ url }"
      ScrapeWorker.enqueue({ url: url }.to_json)
    end
  end
end
