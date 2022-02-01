require_relative "../test_helper"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerSalaryQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include SmartAnswersControllerTestHelper

  setup { setup_fixture_flows }
  teardown { teardown_fixture_flows }

  context "GET /<slug>" do
    context "salary question" do
      should "display question" do
        get :show, params: { id: "salary-sample", started: "y" }
        assert_select ".govuk-caption-l", "Sample salary question"
        assert_select "h1.govuk-label-wrapper .govuk-label.govuk-label--l", /How much\?/
        assert_select "input[type=text][name='response[amount]']"
        assert_select "select[name='response[period]']"
      end

      context "error message set in erb template" do
        setup do
          submit_response({ amount: "bad_number" }, responses: "1.23")
        end

        should "show a validation error if invalid amount" do
          assert_select ".govuk-label", /Salary question with error message/
          assert_select ".govuk-error-message", /salary-question-error-message/
          assert_contains css_select("title").first.content, /Error/
        end
      end

      context "no error message set in erb template" do
        should "show a generic message" do
          submit_response amount: "bad_number"
          assert_select "h1.govuk-label-wrapper .govuk-label.govuk-label--l", /How much\?/
          assert_select ".govuk-error-message", /Please answer this question/
        end

        should "not error if passed string response" do
          submit_response "bob"
          assert_response :success
        end
      end

      should "show a validation error if invalid period" do
        submit_response amount: "1", period: "bad_period"
        assert_select "h1.govuk-label-wrapper .govuk-label.govuk-label--l", /How much\?/
        assert_select ".govuk-error-message", /Please answer this question/
      end

      should "accept responses as GET params and redirect to canonical url" do
        submit_response amount: "1", period: "month"
        assert_redirected_to "/salary-sample/y/1.0-month"
      end

      context "a response has been accepted" do
        should "show response summary" do
          get :show, params: { id: "salary-sample", started: "y", responses: "1.0-month" }
          assert_select ".govuk-summary-list", /How much\?\s+£1 per month/
        end

        should "have cache headers set to 5 mins for inner pages" do
          Rails.application.config.stubs(:set_http_cache_control_expiry_time).returns(true)

          get :show, params: { id: "salary-sample", started: "y", responses: "1.0-month" }
          assert_equal "max-age=300, public", @response.header["Cache-Control"]
        end
      end
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "salary-sample"))
  end

  def submit_json_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "salary-sample"))
  end
end
