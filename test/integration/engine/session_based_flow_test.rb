require_relative "engine_test_helper"

class SessionBasedFlowTest < EngineIntegrationTest
  should "allow a user to complete a flow" do
    visit "/session-based/start"

    choose "Response 1"
    click_on "Continue"

    fill_in "response", with: "Response"
    click_on "Continue"

    assert_page_has_content "Results title"
    assert_current_url "/session-based/results"
  end

  should "provide answer validation" do
    visit "/session-based/start"

    click_on "Continue"

    assert_page_has_content "Question 1 title"
    assert_page_has_content "Please answer this question"
    assert_current_url "/session-based/question1"
  end

  should "allow changing an answer" do
    visit "/session-based/start"

    choose "Response 1"
    click_on "Continue"

    click_on "Change"

    assert_page_has_content "Question 1 title"
    assert_current_url "/session-based/question1"
  end

  should "allow restarting a flow" do
    visit "/session-based/start"

    choose "Response 1"
    click_on "Continue"

    fill_in "response", with: "Response"
    click_on "Continue"

    click_on "Start again"

    assert_page_has_content "This is a test flow"
    assert_current_url "/session-based"
  end
end
