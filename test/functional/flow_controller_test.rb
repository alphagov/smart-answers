require_relative "../test_helper"
require_relative "../fixtures/smart_answer_flows/smart-answers-controller-sample"
require_relative "smart_answers_controller_test_helper"

class FlowControllerTest < ActionController::TestCase
  include SmartAnswersControllerTestHelper

  def setup
    setup_fixture_flows
  end

  def teardown
    teardown_fixture_flows
  end

  context "GET /<slug>" do
    setup do
      stub_content_store_has_item("/smart-answers-controller-sample")
    end

    should "display landing page in html if no questions answered yet" do
      get :landing, params: { id: "smart-answers-controller-sample" }
      assert_select "h1", /Smart answers controller sample/
    end

    should "not have noindex tag on landing page" do
      get :landing, params: { id: "smart-answers-controller-sample" }
      assert_select "meta[name=robots][content=noindex]", count: 0
    end

    should "have cache headers set to 30 mins" do
      Rails.application.config.stubs(:set_http_cache_control_expiry_time).returns(true)

      get :landing, params: { id: "smart-answers-controller-sample" }
      assert_equal "max-age=1800, public", @response.header["Cache-Control"]
    end

    context "meta description in erb template" do
      should "be shown" do
        get :landing, params: { id: "smart-answers-controller-sample" }
        assert_select "head meta[name=description]" do |meta_tags|
          assert_equal "This is a test description", meta_tags.first["content"]
        end
      end
    end
  end
end
