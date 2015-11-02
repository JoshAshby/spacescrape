module Workflows
  class Scrape < Base
    def initialize
      subscribe to: 'doc:' do |bus, env|
        env.model = Webpage.find url: env.url
      end

      # subscribe to: 'doc:fetch',   with: Cacher
      subscribe to: 'doc:fetch',   with: Timeouter
      subscribe to: 'doc:fetch',   with: Blacklister
      subscribe to: 'doc:fetch',   with: Roboter
      subscribe to: 'doc:fetch',   with: Fetcher

      subscribe to: 'doc:fetched', with: Parser

      subscribe to: 'doc:parsed',  with: Storer
    end

    def process(url:)
      return unless url

      publish to: 'doc:fetch', data: URI.parse(url)
    end
  end
end
