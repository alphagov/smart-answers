require_relative "../test_helper"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerRadioQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include SmartAnswersControllerTestHelper

  setup { setup_fixture_flows }
  teardown { teardown_fixture_flows }

  context "radio question" do
    should "display question" do
      get :show, params: { id: "radio-sample", started: "y" }
      assert_select ".govuk-caption-l", "Sample radio question"
      assert_select ".govuk-fieldset__legend.govuk-fieldset__legend--l h1.govuk-fieldset__heading", /Hotter or colder\?/
      assert_select "input[type=radio][name=response]"
    end

    context "no response given" do
      should "show an error message" do
        submit_response(nil)
        assert_select ".govuk-error-message"
        assert_contains css_select("title").first.content, /Error/
      end
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: "radio-sample"))
  end
end
