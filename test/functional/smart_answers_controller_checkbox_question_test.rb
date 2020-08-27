require_relative "../test_helper"
require_relative "../fixtures/smart_answer_flows/smart-answers-controller-sample-with-checkbox-question"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerCheckboxQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include SmartAnswersControllerTestHelper

  def setup
    setup_fixture_flows
    stub_content_store_has_item("/smart-answers-controller-sample-with-checkbox-question")
  end

  def teardown
    teardown_fixture_flows
  end

  context "checkbox question" do
    should "display question" do
      get :show, params: { id: "smart-answers-controller-sample-with-checkbox-question", started: "y" }
      assert_select ".govuk-fieldset__legend.govuk-fieldset__legend--l .govuk-caption-l", "Sample checkbox question"
      assert_select ".govuk-fieldset__legend.govuk-fieldset__legend--l h1.govuk-fieldset__heading", /What\?/
      assert_select "input[type=checkbox][name=\"response[]\"]"
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "smart-answers-controller-sample-with-checkbox-question"))
  end
end
