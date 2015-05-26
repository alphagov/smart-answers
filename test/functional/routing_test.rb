require_relative '../test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  include Rack::Test::Methods

  should "not 404 without blowing up when given a slug with invalid UTF-8" do
    assert_raises ActionController::RoutingError do
      get "/non-gb-driving-licence%E2%EF%BF%BD%EF%BF%BD"
    end
  end
end
