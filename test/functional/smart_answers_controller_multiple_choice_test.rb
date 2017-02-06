require_relative '../test_helper'
require_relative '../helpers/fixture_flows_helper'
require_relative '../fixtures/smart_answer_flows/smart-answers-controller-sample-with-multiple-choice-question'
require_relative 'smart_answers_controller_test_helper'

class SmartAnswersControllerMultipleChoiceQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include FixtureFlowsHelper
  include SmartAnswersControllerTestHelper

  def setup
    setup_fixture_flows
  end

  def teardown
    teardown_fixture_flows
  end

  context "multiple choice question" do
    context "no response given" do
      should "show an error message" do
        submit_response(nil)
        assert_select ".step.current .error"
      end
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: 'smart-answers-controller-sample-with-multiple-choice-question'))
  end

  def submit_json_response(response = nil, other_params = {})
    super(response, other_params.merge(id: 'smart-answers-controller-sample-with-multiple-choice-question'))
  end
end
