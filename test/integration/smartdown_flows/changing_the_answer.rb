require 'integration_test_helper'

class ChangingTheAnswerTest < ActionDispatch::IntegrationTest
  def setup
    use_test_smartdown_flow_fixtures
    stub_content_api_default_artefact

    visit smart_answer_path(id: "multiple-answer-question-flow")
    click_on "Start now"
  end

  def teardown
    stop_using_test_smartdown_flow_fixtures
  end

  test "changing a multiple question node" do
    assert page.has_content?("How do you highlight instance vars in your editor?")

    choose "Green"
    choose "Single Quotes"
    click_on "Next step"

    choose "Tabs"
    click_on "Next step"

    assert page.has_content?("ship it")

    click_on 'Change answer to "Colours and Quotes"'
    assert page.has_content?("How do you highlight instance vars in your editor?")
  end
end
