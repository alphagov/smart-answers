require_relative "../test_helper"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerPostcodeQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include SmartAnswersControllerTestHelper

  setup { setup_fixture_flows }
  teardown { teardown_fixture_flows }

  context "postcode question" do
    should "display question" do
      get :show, params: { id: "postcode-sample", started: "y" }
      assert_select ".govuk-caption-l", "Sample postcode question"
      assert_select "h1.govuk-label-wrapper .govuk-label.govuk-label--l", /User input\?/
      assert_select "input[type=text][name=response]"
    end

    should "show a validation error if invalid input" do
      submit_response "invalid postcode"
      assert_select "h1.govuk-label-wrapper .govuk-label.govuk-label--l", /User input\?/
      assert_select ".govuk-error-summary [href]", /Please answer this question/
      assert_select ".govuk-error-message", /Please answer this question/
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "postcode-sample"))
  end
end
