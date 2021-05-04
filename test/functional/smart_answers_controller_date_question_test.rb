require_relative "../test_helper"
require_relative "../fixtures/smart_answer_flows/smart-answers-controller-sample-with-date-question"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerDateQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include SmartAnswersControllerTestHelper

  def setup
    setup_fixture_flows
    stub_content_store_has_item("/smart-answers-controller-sample-with-date-question")
  end

  def teardown
    teardown_fixture_flows
  end

  context "GET /<slug>" do
    context "date question" do
      should "display question" do
        get :show, params: { id: "smart-answers-controller-sample-with-date-question", started: "y" }
        assert_select ".govuk-caption-l", "Sample date question"
        assert_select ".govuk-fieldset__legend.govuk-fieldset__legend--l h1.govuk-fieldset__heading", /When\?/
        assert_select "input[name='response[day]']"
        assert_select "input[name='response[month]']"
        assert_select "input[name='response[year]']"
      end

      should "accept question input and redirect to canonical url" do
        submit_response day: "1", month: "1", year: "2011"
        assert_redirected_to "/smart-answers-controller-sample-with-date-question/y/2011-01-01"
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
          submit_response(day: "", month: "", year: "")
          assert_select ".govuk-fieldset__legend.govuk-fieldset__legend--l h1.govuk-fieldset__heading", /When\?/
        end

        should "show an error message" do
          submit_response(day: "", month: "", year: "")
          assert_select ".govuk-error-message"
          assert_contains css_select("title").first.content, /Error/
        end
      end

      should "display collapsed question, and format number" do
        get :show, params: { id: "smart-answers-controller-sample-with-date-question", started: "y", responses: "2011-01-01" }
        assert_select ".govuk-summary-list", /When\?\s+1 January 2011/
      end
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "smart-answers-controller-sample-with-date-question"))
  end
end
