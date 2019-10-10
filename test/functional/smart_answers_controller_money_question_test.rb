require_relative "../test_helper"
require_relative "../helpers/fixture_flows_helper"
require_relative "../fixtures/smart_answer_flows/smart-answers-controller-sample-with-money-question"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerMoneyQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include FixtureFlowsHelper
  include SmartAnswersControllerTestHelper

  def setup
    setup_fixture_flows

    stub_smart_answer_in_content_store("smart-answers-controller-sample-with-money-question")
  end

  def teardown
    teardown_fixture_flows
  end

  context "GET /<slug>" do
    context "money question" do
      should "display question" do
        get :show, params: { id: "smart-answers-controller-sample-with-money-question", started: "y" }
        assert_select ".govuk-label", /How much\?/
        assert_select "input[type=text][name=response]"
      end

      should "show a validation error if invalid input" do
        submit_response "bad_number"
        assert_select ".govuk-label", /How much\?/
        assert_select "body", /Please answer this question/
      end

      context "suffix_label in erb template" do
        setup do
          get :show, params: { id: "smart-answers-controller-sample-with-money-question", started: "y", responses: "1.23" }
        end

        should "show the label after the question input" do
          assert_select "input[type=text][name=response]"
        end
      end
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "smart-answers-controller-sample-with-money-question"))
  end

  def submit_json_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "smart-answers-controller-sample-with-money-question"))
  end
end
