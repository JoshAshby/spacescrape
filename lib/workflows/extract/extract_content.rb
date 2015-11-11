require 'readability'
require 'loofah'

module Workflows
  class Extract
    class ExtractContent
      def extract body
        @readability ||= Readability::Document.new body
        @content     ||= @readability.content
        @loofah      ||= Loofah.fragment @content
        @document    ||= @loofah.scrub!( :strip ).text
      end

      def call bus, payload
        payload.content = extract payload.body

        bus.publish to: 'doc:extracted', data: payload
      end
    end
  end
end
