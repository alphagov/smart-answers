require_relative "../test_helper"
require_relative "../helpers/fixture_flows_helper"
require_relative "../fixtures/smart_answer_flows/smart-answers-controller-sample-with-postcode-question"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerPostcodeQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include FixtureFlowsHelper
  include SmartAnswersControllerTestHelper

  def setup
    setup_fixture_flows
    stub_content_store_has_item("/smart-answers-controller-sample-with-postcode-question")
  end

  def teardown
    teardown_fixture_flows
  end

  context "postcode question" do
    should "display question" do
      get :show, params: { id: "smart-answers-controller-sample-with-postcode-question", started: "y" }
      assert_select ".govuk-caption-l", "Sample postcode question"
      assert_select "h1.govuk-label-wrapper .govuk-label.govuk-label--l", /Postcode\?/
      assert_select "input[type=text][name=response]"
    end

    should "show a validation error if invalid input" do
      submit_response "invalid postcode"
      assert_select "h1.govuk-label-wrapper .govuk-label.govuk-label--l", /Postcode\?/
      assert_select "body", /Please answer this question/
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "smart-answers-controller-sample-with-postcode-question"))
  end
end
