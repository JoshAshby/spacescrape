require 'sinatra/base'
require 'haml'

# Finally the sinatra app to interface with this all...
class MainApp < Sinatra::Base
  set :views, -> { SpaceScrape.root.join 'views' }

  get '/' do
    @webpages = Webpage.all

    haml :index
  end

  post '/' do
    Scraper.pipeline.publish to: 'doc:async', data: params['url'] if params['url']

    redirect to('/')
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
