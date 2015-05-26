require_relative "../integration_test_helper"

class HealthcheckTest < ActionDispatch::IntegrationTest
  should "returns health check status" do
    get "/healthcheck"
    assert_response :success
  end
end
