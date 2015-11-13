require_relative '../test_helper'

class ApplicationControllerTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    ::ApplicationController
  end

  def test_get_index
    get '/'
    assert last_response.ok?
  end
end
