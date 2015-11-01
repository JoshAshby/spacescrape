class ApplicationController
  get '/' do
    @topics = Topic.order :updated_at

    haml :index
  end
end
