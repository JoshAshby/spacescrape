class Analyzer
  def call bus, env
    @env = env
    @document = env[:content]

    bus.publish to: 'doc:analyzed', data: env.merge({ analysis: analyze! })
  end

  def analyze!
    topics = Classifier.new.classify doc: @document

    ap topics

    topics
  end
end
