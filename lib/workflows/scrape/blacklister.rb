module Workflows
  class Scrape
    class Blacklister
      def call bus, uri
        blacklists = DB[:blacklists].select(:pattern).map do |a|
          Regexp.new a[:pattern]
        end

        blacklisted = blacklists.any? do |p|
          uri.to_s =~ p || uri.host =~ p
        end

        if uri.to_s.match 'wiki(.*).org'
          blacklisted = true unless uri.to_s.match 'en.wiki(.*).org'
        end

        return unless blacklisted

        bus.publish to: 'request:cancel', data: uri
        bus.stop!
      end
    end
  end
end
