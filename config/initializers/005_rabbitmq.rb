require 'bunny'
require 'sneakers'

Sneakers.configure(**SpaceScrape.config_for(:rabbitmq).symbolize_keys)
Sneakers.logger = SpaceScrape.logger

module SpaceScrape
  module_function
  def bunny
    @bunny ||= Bunny.new.tap do |c|
      c.start
    end
  end
end
