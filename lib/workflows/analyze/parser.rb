require 'nokogiri'
require 'byebug'

module Workflows
  class Analyze
    class Parser
      def call bus, env
        @env = env
        @document = Nokogiri::HTML.parse @env[:body]

        unless check_language
          return bus.stop!
        end

        links = parse_links

        bus.publish to: 'request:links', data: links
        bus.publish to: 'doc:parsed', data: @env.merge({ nokogiri: @document, links: links })
      end

      def parse_links
        hrefs = @document.xpath('//a/@href')
        links = hrefs.map do |href|
          begin
            (@env[:model].uri + href).to_s.split('#', 2).first
          rescue URI::InvalidURIError, NoMethodError
            next
          end
        end.uniq.compact

        links
      end

      def check_language
        lang_attr = @document.xpath '/html/@lang'

        SpaceScrape.logger.debug "Language of #{ @env[:model].url } is #{ lang_attr }. #{  }"
        SpaceScrape.logger.debug "Language matches en? #{ lang_attr.to_s =~ /en/ }" if lang_attr

        return true if lang_attr && (lang_attr.to_s =~ /en/) != nil

        (lang_attr =~ /^en/) != nil
      end
    end
  end
end
