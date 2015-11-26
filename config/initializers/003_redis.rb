require 'redis'
require 'redis-namespace'

require 'sidekiq'
require 'connection_pool'

require 'redlock'

module SpaceScrape
  module_function
  def new_redis_connection **opts
    Redis::Namespace.new 'spacescrape', { redis: Redis.new }.merge(opts)
  end

  def lock_manager
    @@lock_manager ||= Redlock::Client.new [ SpaceScrape.new_redis_connection ]
  end
end

# Redis stuff
Redis.current = SpaceScrape.new_redis_connection

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 15) { SpaceScrape.new_redis_connection }
end

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 15) { SpaceScrape.new_redis_connection }
end
