require_relative "engine_test_helper"

class SessionBasedFlowTest < EngineIntegrationTest
  should "allow a user to complete a flow" do
    visit "/session-based/start"

    find "h1", text: "Question 1 title"
    choose "Response 1"
    click_on "Continue"

    find "h1", text: "Question 2 title"
    fill_in "response", with: "Response"
    click_on "Continue"

    find "h1", text: "Information based on your answers"
    assert_page_has_content "Results title"
    assert_current_url "/session-based/results"
  end

  should "provide answer validation" do
    visit "/session-based/start"

    find "h1", text: "Question 1 title"
    click_on "Continue"

    find "h1", text: "Question 1 title"
    assert_page_has_content "Question 1 title"
    assert_page_has_content "Please answer this question"
    assert_current_url "/session-based/question1"
  end

  should "allow changing an answer" do
    visit "/session-based/start"

    find "h1", text: "Question 1 title"
    choose "Response 1"
    click_on "Continue"

    find "h1", text: "Question 2 title"
    click_on "Change"

    find "h1", text: "Question 1 title"
    assert_page_has_content "Question 1 title"
    assert_current_url "/session-based/question1"
  end

  should "allow restarting a flow" do
    visit "/session-based/start"

    find "h1", text: "Question 1 title"
    choose "Response 1"
    click_on "Continue"

    find "h1", text: "Question 2 title"
    fill_in "response", with: "Response"
    click_on "Continue"

    find "h1", text: "Information based on your answers"
    click_on "Start again"

    find "h1", text: /^This is a test flow$/
    assert_page_has_content "This is a test flow"
    assert_current_url "/session-based"
  end
end
