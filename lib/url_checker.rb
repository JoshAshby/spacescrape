class UrlChecker
  attr_accessor :pipeline

  def pipeline
    @pipeline ||= PubsubPipeline.new do |pubsub|
      pubsub.subscribe to: 'doc:check', with: Blacklister
      pubsub.subscribe to: 'doc:check', with: Roboter
    end
  end

  def check url
    url = Webpage.new url: url unless url.kind_of? Webpage
    pipeline.publish to: 'doc:check', data: { model: url }
  end
end
