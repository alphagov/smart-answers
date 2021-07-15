require_relative "../test_helper"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerValueQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include SmartAnswersControllerTestHelper

  setup { setup_fixture_flows }
  teardown { teardown_fixture_flows }

  context "GET /<slug>" do
    context "value question" do
      should "display question" do
        get :show, params: { id: "value-sample", started: "y" }
        assert_select ".govuk-caption-l", "Sample value question"
        assert_select "h1.govuk-label-wrapper .govuk-label.govuk-label--l", /User input\?/
        assert_select "input[type=text][name=response]"
      end

      should "accept question input and redirect to canonical url" do
        submit_response "10"
        assert_redirected_to "/value-sample/y/10"
      end

      should "display answered question, and format number" do
        get :show, params: { id: "value-sample", started: "y", responses: "12345" }
        assert_select ".govuk-summary-list", /User input\?\s+12,345/
      end
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "value-sample"))
  end

  def submit_json_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "value-sample"))
  end
end
