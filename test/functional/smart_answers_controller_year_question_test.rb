require_relative "../test_helper"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerYearQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include SmartAnswersControllerTestHelper

  setup { setup_fixture_flows }
  teardown { teardown_fixture_flows }

  context "GET /<slug>" do
    context "year question" do
      should "display question" do
        get :show, params: { id: "year-sample", started: "y" }
        assert_select ".govuk-caption-l", "Sample year question"
        assert_select ".govuk-fieldset__legend.govuk-fieldset__legend--l h1.govuk-fieldset__heading", /What year\?/
        assert_select "input[name='response[year]']"
      end

      should "accept question input and redirect to canonical url" do
        submit_response year: "2011"
        assert_redirected_to "/year-sample/y/2011"
      end

      should "not error if passed blank response" do
        submit_response ""
        assert_response :success
      end

      should "not error if passed string response" do
        submit_response "bob"
        assert_response :success
      end

      context "no response given" do
        should "redisplay question" do
          submit_response(year: "")
          assert_select ".govuk-fieldset__legend.govuk-fieldset__legend--l h1.govuk-fieldset__heading", /What year\?/
        end

        should "show an error message" do
          submit_response(year: "")
          assert_select ".govuk-error-message"
          assert_contains css_select("title").first.content, /Error/
        end
      end

      should "display answered question, and format number" do
        get :show, params: { id: "year-sample", started: "y", responses: "2011" }
        assert_select ".govuk-summary-list", /What year\?\s+2011/
      end
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "year-sample"))
  end
end
