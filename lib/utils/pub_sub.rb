class PubSub
  attr_reader :subscribers, :stop

  def initialize
    @subscribers = {}
    @stop        = false

    yield self if block_given?
  end

  def make_regex string
    return string if string.kind_of? Regexp

    Regexp.new "^#{ string.to_s }$" if [ String, Symbol ].include? string.class
  end

  # Subscribes the given class, method or block to a channel or channel
  # pattern.
  #
  # A class may be used for the channel pattern, however if one is used then
  # it must respond to the class method #match()
  #
  # The subscriber can be any number of things: A class, an object, a method
  # or a block. When a class is used, it must support being initialized without
  # any arguments.
  #
  # All subscribers must respond to #call(bus, data) which will be used
  # everytime a message is published to them.
  #
  # @param to [Regexp, String, Symbol] Channel pattern to subscribe to
  # @param with [Class, Object, method, block] Must support #call(bus, data)
  #
  # @return [Class, Object, method, block] the subscriber, to allow
  #   unsubscribing it in the future
  def subscribe to:, with: nil, &block
    with = block if block_given?
    to = make_regex to

    @subscribers[to] ||= []
    @subscribers[to] << with

    with
  end

  # Unsubscribes the given subscriber from the given channel pattern.
  def unsubscribe from:, with:, &block
    from = make_regex from
    @subscribers[from].delete with, &block
  end

  # Stops propgation of the message to later subscribers.
  #
  # PubsubPipeline will not automatically unstop a bus, see #reset!()
  def stop!
    @stop = true
  end

  def reset!
    @stop = false
  end

  # Publishes data on the bus to the given channel
  #
  # @return [Array] all subscribers who recieved the message
  def publish to:, data: nil
    data = yield if block_given?

    to = to.to_s
    subs = @subscribers.select do |k, v|
      Array(to).any?{ |t| k.match t }
    end.values.flatten.uniq

    actual_subs = []

    subs.each do |sub|
      break if @stop

      sub = sub.new if sub.class == Class
      sub.call self, data

      break if @stop

      actual_subs << sub
    end

    actual_subs
  end
end
