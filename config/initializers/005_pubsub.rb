require_relative '../../lib/pipelines'

module SpaceScrape
  module_function
  def pubsub
    @bus ||= Pipelines::Pubsub.new
  end
end
