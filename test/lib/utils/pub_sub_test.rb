require_relative '../../test_helper'

class PubSubTest < MiniTest::Test
  def test_symbol_channel
    expected = 'sigyn'

    pipeline = PubSub.new do |pubsub|
      pubsub.subscribe to: :test do |bus, env|
        assert bus == pipeline
        assert env == expected
      end
    end

    assert pipeline.subscribers.values.any?, "Didn't find any subscribers!"
    assert pipeline.publish(to: :test, data: expected).any?, "Expected message to have a subscriber"
    assert pipeline.publish(to: 'test', data: expected).any?, "Expected message to have a subscriber"
  end

  def test_string_channel
    expected = 'sigyn'

    pipeline = PubSub.new do |pubsub|
      pubsub.subscribe to: 'test' do |bus, env|
        assert bus == pipeline
        assert env == expected
      end
    end

    assert pipeline.subscribers.values.any?, "Didn't find any subscribers!"
    assert pipeline.publish(to: :test, data: expected).any?, "Expected message to have a subscriber"
    assert pipeline.publish(to: 'test', data: expected).any?, "Expected message to have a subscriber"
  end

  def test_regex_channel
    expected = 'sigyn'

    pipeline = PubSub.new do |pubsub|
      pubsub.subscribe to: /^test$/ do |bus, env|
        assert bus == pipeline
        assert env == expected
      end
    end

    assert pipeline.subscribers.values.any?, "Didn't find any subscribers!"
    assert pipeline.publish(to: :test, data: expected).any?, "Expected message to have a subscriber"
    assert pipeline.publish(to: 'test', data: expected).any?, "Expected message to have a subscriber"
  end
end
