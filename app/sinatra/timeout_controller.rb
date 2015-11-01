class ApplicationController
  get '/timeout' do
    @timeouts = Redis.current.keys('*:nice').map do |key|
      {
        domain: key.gsub(':nice', ''),
        seconds_left: Redis.current.ttl(key),
        set_at: Redis.current.get(key)
      }
    end.select{ |p| p[:seconds_left] >= 0 }.sort_by{ |f| f[:seconds_left] }

    haml :timeout
  end
end
