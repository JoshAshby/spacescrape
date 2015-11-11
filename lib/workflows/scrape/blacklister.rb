module Workflows
  class Scrape
    class Blacklister
      def call bus, payload
        blacklists = DB[:blacklists].select(:pattern).map do |a|
          Regexp.new a[:pattern]
        end

        blacklisted = blacklists.any? do |p|
          payload.uri.to_s =~ p || payload.uri.host =~ p
        end

        if payload.uri.to_s.match 'wiki(.*).org'
          blacklisted = true unless payload.uri.to_s.match 'en.wiki(.*).org'
        end

        return unless blacklisted

        bus.publish to: 'request:cancel'
        bus.stop!
      end
    end
  end
end
