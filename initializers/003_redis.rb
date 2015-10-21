require 'redis'
require 'redis-namespace'

require 'sidekiq'
require 'connection_pool'

require 'redlock'

# Redis stuff
$redis_conn = -> (**opts) { Redis::Namespace.new 'spacescrape', { redis: Redis.new}.merge(opts) }
Redis.current = $redis_conn.call

Sidekiq.configure_server do |config|
  config.redis =  ConnectionPool.new size: 15, &$redis_conn
end

Sidekiq.configure_client do |config|
  config.redis =  ConnectionPool.new size: 15, &$redis_conn
end

$lock_manager = Redlock::Client.new [ $redis_conn.call ]
