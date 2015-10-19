# Finally the sinatra app to interface with this all...
class MainApp < Sinatra::Base
  set :views, -> { File.join $current_dir, 'views' }

  get '/' do
    @webpages = Webpage.all

    haml :index
  end

  post '/' do
    if params['url']
      webpage = Webpage.find_or_create url: params['url']
      ScraperWorker.perform_async webpage.id
    end

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
