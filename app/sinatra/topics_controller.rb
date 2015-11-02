class ApplicationController
  get '/topics' do
    @topics = Topic.order :updated_at

    haml :topics
  end

  post '/topics' do
  end

  get '/topics/:id' do
    @topic = Topic.first id: params[:id]

    haml :topic
  end

  put '/topics/:id' do
  end
end
