# Builds out a Publish/Subscriber system. Subscriptions are to a pattern or a
# specific broadcast, and can have as many subscribers. Subscriptions should
# have a #match(a) method while subscribers themselves should respond to
# #call(bus, data)
class PubsubPipeline
  def initialize
    @subscribers = {}

    yield self if block_given?
  end

  def subscribe to:, with: nil, &block
    with = block if block_given?
    to = Regexp.new "^#{ to }$" if to.kind_of? String

    @subscribers[to] ||= []
    @subscribers[to] << with
  end

  def stop!
    @stopped = true
  end

  def start!
    @stopped = false
  end

  def publish to:, data: nil
    data = yield if block_given?

    @subscribers.select{ |k, v| k.match to }
      .values.flatten
      .each do |sub|
        return if @stopped
        $logger.debug "Publishing #{ data } to #{ sub }"
        sub = sub.new if sub.class == Class
        sub.call self, data
        $logger.debug "Finished publishing to #{ sub }"
        return if @stopped
      end
  end
end