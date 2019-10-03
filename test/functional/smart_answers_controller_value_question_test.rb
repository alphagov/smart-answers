require_relative "../test_helper"
require_relative "../helpers/fixture_flows_helper"
require_relative "../fixtures/smart_answer_flows/smart-answers-controller-sample-with-value-question"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerValueQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include FixtureFlowsHelper
  include SmartAnswersControllerTestHelper

  def setup
    setup_fixture_flows

    stub_smart_answer_in_content_store("smart-answers-controller-sample-with-value-question")
  end

  def teardown
    teardown_fixture_flows
  end

  context "GET /<slug>" do
    context "value question" do
      should "display question" do
        get :show, params: { id: "smart-answers-controller-sample-with-value-question", started: "y" }
        assert_select ".govuk-label", /How many green bottles\?/
        assert_select "input[type=text][name=response]"
      end

      should "accept question input and redirect to canonical url" do
        submit_response "10"
        assert_redirected_to "/smart-answers-controller-sample-with-value-question/y/10"
      end

      should "display collapsed question, and format number" do
        get :show, params: { id: "smart-answers-controller-sample-with-value-question", started: "y", responses: "12345" }
        assert_select ".govuk-table", /How many green bottles\?\s+12,345/
      end
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "smart-answers-controller-sample-with-value-question"))
  end

  def submit_json_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "smart-answers-controller-sample-with-value-question"))
  end
end
