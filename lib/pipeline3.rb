class Fetcher
  def initialize url
    @url = url
  end

  def process
    puts "Fetcher process"
    return cache if cached?
    remote
  end

  def cached?
    false
  end

  def remote
    ""
  end

  def cache
    ""
  end
end

class Parser
  def initiailze html
    @html = html
  end

  def process
    puts "Parser process"
    return ""
  end
end

class Extractor
  def initialize content
    @content = content
  end

  def process
    puts "Extractor process"
    return ""
  end
end

class Analyzer
  def initialize document
    @document = document
  end

  def process
    puts "Analyzer process"
    return ""
  end
end

[ Fetcher, Parser, Extractor, Analyzer ].inject 'some_url' do |memo, obj|
  puts memo
  obj.new(memo).process
end
