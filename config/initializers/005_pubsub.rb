require_relative '../../lib/pipelines'

module SpaceScrape
  module_function
  def pubsub
    @rabbitmq_bus ||= Pipelines::Pubsub.new
  end
end
