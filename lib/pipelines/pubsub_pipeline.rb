# Builds out a Publish/Subscriber system. Subscriptions are to a pattern or a
# specific broadcast, and can have as many subscribers. Subscriptions should
# have a #match(a) method while subscribers themselves should respond to
# #call(bus, data)
class PubsubPipeline
  attr_accessor :subscribers

  def initialize
    @subscribers = {}
    @stop = false

    yield self if block_given?
  end

  def subscribe to:, with: nil, &block
    with = block if block_given?
    to = Regexp.new "^#{ to }$" if to.kind_of? String

    @subscribers[to] ||= []
    @subscribers[to] << with
  end

  def stop!
    SpaceScrape.logger.debug "Stopping pubsub!"
    @stop = true
  end

  def reset!
    @stop = false
  end

  # Publishes the given data to the bus under the given namespace
  #
  # Returns a list of all the subscribers who recieved the message
  def publish to:, data: nil
    data = yield if block_given?

    subs = @subscribers.select{ |k, v| k.match to }
      .values.flatten

    SpaceScrape.logger.debug "Published #{ to } to #{ subs }"

    subs.each do |sub|
      SpaceScrape.logger.debug "Publishing #{ to } to #{ sub }"

      break if @stop
      sub = sub.new if sub.class == Class
      sub.call self, data
      if @stop
        SpaceScrape.logger.debug "Stopping pubsub at #{ to }"
        break
      end
    end

    # SpaceScrape.logger.debug "Current state of subscribers:"
    # SpaceScrape.logger.ap @subscribers

    subs
  end
end
