require_relative "../test_helper"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerMultipleCountrySelectQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include SmartAnswersControllerTestHelper

  setup do
    setup_fixture_flows
    stub_worldwide_api_has_locations(%w[country1 country2])
  end

  teardown { teardown_fixture_flows }

  context "multiple country question" do
    should "display question with with two country selects" do
      get :show, params: { id: "multiple-country-sample", started: "y" }
      assert_select ".govuk-caption-l", "Sample multiple country question"
      assert_select "input[name='response[0]']"
      assert_select "input[name='response[1]']"
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "multiple-country-sample"))
  end
end
