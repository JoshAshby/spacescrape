class Fetcher
  def initialize url
    @url = url
  end

  def remote
    fail NotImplementedError
  end

  def cache
    fail NotImplementedError
  end
end

class Extractor
  def initialize html
    @html = html
  end

  def extract
    fail NotImplementedError
  end
end

class Analyzer
  def initialize document
    @document = document
  end

  def analyze
    fail NotImplementedError
  end
end

class Pipeline
  def initialize fetcher: Fetcher, extractor: Extractor, analyzer: Analyzer
  end

  def process url
    html = @fetcher.new(url).fetch
    document = @extractor.new(html).extract
    analysis = @analyzer.new(document).analyze
  end
end
