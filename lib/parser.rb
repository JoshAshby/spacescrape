class Parser
  def call bus, env
    @html = env
    bus.publish to: 'doc:parsed', data: parse!
  end

  def parse!
    @html
  end

  protected
end
