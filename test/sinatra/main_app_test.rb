require_relative '../test_helper'

class MainAppTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    MainApp
  end

  def test_get_index
    get '/'
    assert last_response.ok?
  end

  def test_post_index
  end

  def test_get_timeout
  end

  def test_get_blacklist
  end

  def test_port_blacklist
  end
end
