# Allow us to log to both the console and a log file at the same time...
class MultiIO
  def initialize *targets
     @targets = targets
  end

  def write *args
    @targets.each{ |t| t.write *args }
  end

  def close
    @targets.each &:close
  end
end
