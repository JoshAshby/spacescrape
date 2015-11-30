module Controllers
  class ApplicationController
    get '/topics' do
      @topics = Models::Topic.order :updated_at

      haml :topics
    end

    post '/topics' do
    end

    get '/topic/:id' do
      @topic = Models::Topic.first id: params[:id]

      haml :topic
    end

    put '/topic/:id' do
    end
  end
end
