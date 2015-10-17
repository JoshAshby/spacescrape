# Finally the sinatra app to interface with this all...
class MainApp < Sinatra::Base
  set :views, -> { File.join $current_dir, 'views' }

  get '/' do
    @scrapes = Webpage.all

    haml :index
  end

  get '/domains' do
    @domains = Domain.all

    haml :domains
  end

  post '/' do
    ScraperWorker.perform_async params['url'] if params['url']

    redirect to('/')
  end
end
