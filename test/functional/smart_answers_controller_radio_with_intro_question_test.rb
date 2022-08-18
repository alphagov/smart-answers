require_relative "../test_helper"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerRadioWithIntroQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include SmartAnswersControllerTestHelper

  setup { setup_fixture_flows }
  teardown { teardown_fixture_flows }

  context "radio with intro question" do
    should "display question" do
      get :show, params: { id: "radio-with-intro-sample", started: "y" }
      assert_select "span.govuk-caption-l", "Sample radio with intro question"
      assert_select "h1.govuk-heading-l", "Colour options"
      assert_contains css_select("div.gem-c-govspeak.govuk-govspeak").first.content, /Colours include:/
      assert_select ".govuk-fieldset__legend.govuk-fieldset__legend--m h2.govuk-fieldset__heading", /Do you want to select any of these\?/
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
