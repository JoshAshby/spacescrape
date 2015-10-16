require 'redis'

module Redis::Helpers
  module_function

  def key *args
    args.flatten.join ':'
  end
end
