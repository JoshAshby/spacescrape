require_relative '../lib/pipelines/pubsub_pipeline.rb'

module SpaceScrape
  module_function
  def pubsub
    @bus ||= PubsubPipeline.new
  end
end
