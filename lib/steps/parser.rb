require 'nokogiri'
require 'byebug'

class Parser
  def call bus, env
    html, model = env[:body], env[:model]

    document = Nokogiri::HTML.parse html

    hrefs = document.xpath('//a/@href')
    links = hrefs.map do |href|
      begin
        (model.uri + href).to_s.split('#', 2).first
      rescue URI::InvalidURIError, NoMethodError
        next
      end
    end.uniq.compact

    bus.publish to: 'request:links', data: links
    bus.publish to: 'doc:parsed',    data: env.merge({ nokogiri: document, links: links })
  end
end
