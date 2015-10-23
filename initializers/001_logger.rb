require 'logger'

require_relative '../lib/multi_io'

module SpaceScrape
  module_function
  def logger
    @@logger ||= Logger.new MultiIO.new(
      File.open(SpaceScrape.root.join('logs', 'server.log'), 'a'),
      STDOUT
    )
  end
end

# setup our logger for everything...
SpaceScrape.logger.level = Logger::DEBUG
