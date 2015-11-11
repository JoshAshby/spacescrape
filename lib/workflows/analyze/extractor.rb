require 'readability'
require 'loofah'

# TODO: This could probably be split up... since you know this is part of a
# pipeline, after all

module Workflows
  class Analyze
    class Extractor
      def call bus, env
        @html = env[:body]
        bus.publish to: 'doc:extracted', data: env.merge({ content: extract! })
      end

      def extract!
        @document ||= loofah.scrub!( :strip ).text
      end

      protected

      def readability
        @readability ||= Readability::Document.new @html
      end

      def content
        @content ||= readability.content
      end

      def loofah
        @loofah ||= Loofah.fragment content
      end
    end
  end
end
