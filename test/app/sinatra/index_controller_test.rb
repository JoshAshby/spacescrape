require_relative '../../test_helper'

class Controllers::IndexControllerTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    ::Controllers::ApplicationController
  end

  def test_get_index
    get '/'
    assert last_response.ok?
  end
end
