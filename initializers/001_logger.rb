require 'logger'

require_relative '../lib/multi_io'

# setup our logger for everything...
$logger = Logger.new MultiIO.new(
  File.open(File.join($current_dir, 'logs', 'server.log'), 'a'),
  $stdout
)

$logger.level = Logger::DEBUG
