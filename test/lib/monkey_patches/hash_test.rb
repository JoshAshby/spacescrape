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

  def test_stringify_keys
    expected = {
      'kermit' => 'pig',
      'piggy' => ['frog']
    }

    result = {
      kermit: 'pig',
      piggy: ['frog']
    }.stringify_keys

    assert result.keys.none?{ |k| k.kind_of? Symbol }, "We have Symbol keys in the resulting hash still!"
    assert expected == result, "Hashes with symbol keys don't match!"
  end

  def test_deep_stringify_keys
    expected = {
      'kermit' => 'pig',
      'piggy' => { 'kermit' => 'frog' }
    }

    result = {
      kermit: 'pig',
      piggy: { kermit: 'frog' }
    }.deep_stringify_keys

    assert result.keys.none?{ |k| k.kind_of? Symbol }, "We have Symbol keys in the resulting hash still!"
    assert result['piggy'].keys.none?{ |k| k.kind_of? Symbol }, "We have Symbol keys in the resulting hash still!"
    assert expected == result, "Hashes with symbol keys don't match!"
  end
end
