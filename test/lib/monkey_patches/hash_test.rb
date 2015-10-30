require_relative '../../test_helper'

class HashTest < MiniTest::Test
  def test_symbolize_keys
    expected = {
      kermit: 'pig',
      piggy: ['frog']
    }

    result = {
      'kermit' => 'pig',
      'piggy' => ['frog']
    }.symbolize_keys

    assert result.keys.none?{ |k| k.kind_of? String }, "We have String keys in the resulting hash still!"
    assert expected == result, "Hashes with symbol keys don't match!"
  end

  def test_deep_symbolize_keys
    expected = {
      kermit: 'pig',
      piggy: { kermit: 'frog' }
    }

    result = {
      'kermit' => 'pig',
      'piggy' => { 'kermit' => 'frog' }
    }.deep_symbolize_keys

    assert result.keys.none?{ |k| k.kind_of? String }, "We have String keys in the resulting hash still!"
    assert result[:piggy].keys.none?{ |k| k.kind_of? String }, "We have String keys in the resulting hash still!"
    assert expected == result, "Hashes with symbol keys don't match!"
  end

  def test_unconventional_symbolize_keys
    skip "Ugh"
    obj = Object.new

    assert_raises NoMethodError, "Should have ran into a problem while symbolizing keys" do
      {
        'kermit' => 'pig',
        'piggy' => ['frog'],
        /a/ => :a,
        [ 1 ] => :a,
        obj => :a,
        1 => :a
      }.symbolize_keys
    end
  end

  def test_unconventional_deep_symbolize_keys
    skip "Ugh"
    obj = Object.new

    assert_raises NoMethodError, "Should have ran into a problem while symbolizing keys" do
      {
        'kermit' => 'pig',
        'piggy' => { /kermit/ => 'frog' },
        /a/ => :a,
        [ 1 ] => :a,
        obj => :a,
        1 => :a
      }.deep_symbolize_keys
    end
  end

  def test_stringify_keys
    obj = Object.new

    expected = {
      'kermit' => 'pig',
      'piggy' => ['frog'],
      '(?-mix:a)' => :a,
      '[1]' => :a,
      obj.to_s => :a,
      '1' => :a
    }

    result = {
      kermit: 'pig',
      piggy: ['frog'],
      /a/ => :a,
      [ 1 ] => :a,
      obj => :a,
      1 => :a
    }.stringify_keys

    assert result.keys.none?{ |k| k.kind_of? Symbol }, "We have Symbol keys in the resulting hash still!"
    assert expected == result, "Hashes with string keys don't match!"
  end

  def test_deep_stringify_keys
    obj = Object.new

    expected = {
      'kermit' => 'pig',
      'piggy' => { 'kermit' => 'frog' },
      '(?-mix:a)' => :a,
      '[1]' => :a,
      obj.to_s => :a,
      '1' => :a
    }

    result = {
      kermit: 'pig',
      piggy: { kermit: 'frog' },
      /a/ => :a,
      [ 1 ] => :a,
      obj => :a,
      1 => :a
    }.deep_stringify_keys

    assert result.keys.none?{ |k| k.kind_of? Symbol }, "We have Symbol keys in the resulting hash still!"
    assert result['piggy'].keys.none?{ |k| k.kind_of? Symbol }, "We have Symbol keys in the resulting hash still!"
    assert expected == result, "Hashes with string keys don't match!"
  end
end
