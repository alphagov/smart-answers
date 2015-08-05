require 'integration_test_helper'

class QuestionTypesTest < ActionDispatch::IntegrationTest
  def setup
    use_test_smartdown_flow_fixtures
    stub_content_api_default_artefact

    visit smart_answer_path(id: "animal-example-simple")
    click_on "Start now"
  end

  def teardown
    stop_using_test_smartdown_flow_fixtures
  end

  test "a text field question" do
    choose "Lion"
    click_on "Next step"
    choose "No"
    click_on "Next step"
    fill_in "response", with: "fast"
    click_on "Next step"

    assert page.has_content?("You can outrun a lion")
  end

  test "a multiple choice question" do
    choose "Lion"
    click_on "Next step"
    choose "Yes"
    click_on "Next step"

    assert page.has_content?("You've trained with lions")
  end
end
