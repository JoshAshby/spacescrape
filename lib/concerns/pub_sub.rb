module Concerns
  module PubSub
    extend ActiveSupport::Concern

    class_methods do
      def subscribers
        @_subscribers ||= []
      end

      def subscribe *args, &block
        subscribers << [ args, block ]
      end
    end

    included do
      extend Forwardable

      def_delegators :bus, :publish, :stop, :reset, :stop!, :reset!
    end

    def setup_class_subscribers!
      # I should figure out a better way to do this ...
      self.class.subscribers.each do |subscriber|
        subscribe(*subscriber[0], &subscriber[1])
      end
    end

    def bus
      @bus ||= ::PubSub.new
    end

    def subscribe to:, with: nil, &block
      with = self.method with if with.kind_of? Symbol

      bus.subscribe to: to, with: with, &block
    end
  end
end
