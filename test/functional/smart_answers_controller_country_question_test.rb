require_relative "../test_helper"
require_relative "../fixtures/smart_answer_flows/smart-answers-controller-sample-with-country-question"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerCountryQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include SmartAnswersControllerTestHelper

  def setup
    setup_fixture_flows
    stub_content_store_has_item("/smart-answers-controller-sample-with-country-question")
    stub_world_locations(%w[country1 country2])
  end

  def teardown
    teardown_fixture_flows
  end

  context "country question" do
    should "display question" do
      get :show, params: { id: "smart-answers-controller-sample-with-country-question", started: "y" }
      assert_select ".govuk-caption-l", "Sample country question"
      assert_select "h1 .govuk-label.govuk-label--l", /What country\?/
      assert_select "select[name=response]"
    end

    should "show a validation error if invalid input" do
      submit_response "invalid"
      assert_select "h1 .govuk-label.govuk-label--l", /What country\?/
      assert_select "body", /Please answer this question/
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "smart-answers-controller-sample-with-country-question"))
  end
end
