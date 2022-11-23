require_relative "../test_helper"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerMoneyQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include SmartAnswersControllerTestHelper

  setup { setup_fixture_flows }
  teardown { teardown_fixture_flows }

  context "GET /<slug>" do
    context "money question" do
      should "display question" do
        get :show, params: { id: "money-sample", started: "y" }
        assert_select ".govuk-caption-l", "Sample money question"
        assert_select "h1.govuk-label-wrapper .govuk-label.govuk-label--l", /How much\?/
        assert_select "input[type=text][name=response]"
      end

      should "show a validation error if invalid input" do
        submit_response "bad_number"
        assert_select "h1.govuk-label-wrapper .govuk-label.govuk-label--l", /How much\?/
        assert_select ".govuk-error-summary [href]", /Please answer this question/
        assert_select ".govuk-error-message", /Please answer this question/
      end

      context "suffix_label in erb template" do
        setup do
          get :show, params: { id: "money-sample", started: "y", responses: "1.23" }
        end

        should "show the label after the question input" do
          assert_select "input[type=text][name=response]"
        end
      end
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "money-sample"))
  end

  def submit_json_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "money-sample"))
  end
end
