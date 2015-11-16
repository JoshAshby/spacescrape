require 'nokogiri'
require 'byebug'

module Workflows
  class Scrape
    class Parser
      def call bus, payload
        @payload = payload
        nokogiri_document = Nokogiri::HTML.parse payload.bodyy

        unless is_english? nokogiri_document
          return bus.stop!
        end

        payload.links = parse_links nokogiri_document
        payload.nokogiri = nokogiri_document

        bus.publish to: 'request:links', data: payload.links
        bus.publish to: 'doc:parsed',    data: payload
      end

      def parse_links nokogiri_document
        hrefs = nokogiri_document.xpath('//a/@href')
        links = hrefs.map do |href|
          begin
            (@payload.uri + href).to_s.split('#', 2).first
          rescue URI::InvalidURIError, NoMethodError
            next
          end
        end.uniq.compact

        links
      end

      def is_english? nokogiri_document
        lang_attr = nokogiri_document.xpath('/html/@lang').first

        return true unless lang_attr

        lang = lang_attr.value

        SpaceScrape.logger.debug "Language of #{ @payload.uri.to_s } is #{ lang }"
        SpaceScrape.logger.debug "Language matches en? #{ lang =~ /en/ }" if lang

        (lang =~ /^en/) != nil
      end
    end
  end
end
