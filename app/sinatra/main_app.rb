require 'sinatra/base'
require 'haml'
require 'tilt/haml'

# Finally the sinatra app to interface with this all...
class MainApp < Sinatra::Base
  set :views, -> { SpaceScrape.root.join 'app/views' }

  get '/' do
    @webpages = Webpage.order(:id)

    haml :index
  end

  post '/' do
    Scraper.process_async params['url'] if params['url']

    redirect to('/')
  end

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

  get '/blacklist' do
    @blacklist = Blacklist.all

    haml :blacklist
  end

  post '/blacklist' do
    if params['pattern']
      Blacklist.update_or_create pattern: params['pattern'] do |model|
        model.reason = params['reason']
      end
    end

    redirect to('/blacklist')
  end
end
