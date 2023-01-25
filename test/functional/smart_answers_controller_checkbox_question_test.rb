require_relative "../test_helper"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerCheckboxQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include SmartAnswersControllerTestHelper

  setup { setup_fixture_flows }
  teardown { teardown_fixture_flows }

  context "checkbox question" do
    should "display question" do
      get :show, params: { id: "checkbox-sample", started: "y" }
      assert_select ".govuk-caption-l", "Sample checkbox question"
      assert_select ".govuk-fieldset__legend.govuk-fieldset__legend--l h1.govuk-fieldset__heading", /What do you want on your pizza\?/
      assert_select "input[type=checkbox][name=\"response[]\"]"
    end
  end
end
