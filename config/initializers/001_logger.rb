require 'logger'

FileUtils.mkdir_p SpaceScrape.root.join('logs')

module SpaceScrape
  module_function
  def logger
    @@logger_io ||= MultiIO.new(
      File.open(SpaceScrape.root.join('logs', 'server.log'), 'a'),
      STDOUT
    )

    @@logger ||= Logger.new(@@logger_io).tap do |logger|
      # setup our logger for everything...
      if SpaceScrape.environment == :development
        logger.level = Logger::DEBUG
      else
        logger.level = Logger::INFO
      end
    end
  end
end
