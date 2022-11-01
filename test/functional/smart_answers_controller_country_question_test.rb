require_relative "../test_helper"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerCountryQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include SmartAnswersControllerTestHelper

  setup do
    setup_fixture_flows
    stub_worldwide_api_has_locations(%w[country1 country2])
  end

  teardown { teardown_fixture_flows }

  context "country question" do
    should "display question" do
      get :show, params: { id: "country-sample", started: "y" }
      assert_select ".govuk-caption-l", "Sample country question"
      assert_select "h1 .govuk-label.govuk-label--l", /What country\?/
      assert_select "select[name=response]"
    end

    should "show a validation error if invalid input" do
      submit_response "invalid"
      assert_select "h1 .govuk-label.govuk-label--l", /What country\?/
      assert_select ".govuk-error-summary [href]", /Please answer this question/
      assert_select ".govuk-error-message", /Please answer this question/
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "country-sample"))
  end
end
