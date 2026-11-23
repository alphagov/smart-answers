require_relative "../test_helper"

class RoutingTest < ActionDispatch::IntegrationTest
  include Rack::Test::Methods

  should "route root path to smart answers controller index action" do
    assert_routing "/", controller: "smart_answers", action: "index"
  end

  should "route step path to flow controller step action" do
    assert_routing "/radio-sample/step", controller: "flow", action: "step", id: "radio-sample"
  end
end
