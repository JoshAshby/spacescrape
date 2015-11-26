module Controllers
  class ApplicationController
    get '/' do
      haml :index
    end
  end
end
