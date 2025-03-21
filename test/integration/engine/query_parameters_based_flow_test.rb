require_relative "engine_test_helper"

class QueryParametersBasedFlowTest < EngineIntegrationTest
  should "allow a user to complete a flow" do
    visit "/query-parameters-based/start"

    find "h1", text: "Question 1 title"
    choose "Response 1"
    click_on "Continue"

    find "h1", text: "Question 2 title"
    fill_in "response", with: "Response"
    click_on "Continue"

    find "h1", text: "Information based on your answers"
    assert_page_has_content "Results title"
    assert_current_url "/query-parameters-based/results?question1=response1&question2=Response"
  end

  should "provide answer validation" do
    visit "/query-parameters-based/start"

    find "h1", text: "Question 1 title"
    click_on "Continue"

    find "h1", text: "Question 1 title"
    assert_page_has_content "Question 1 title"
    assert_page_has_content "Please answer this question"
    assert_current_url "/query-parameters-based/question1?question1="
  end

  should "allow changing an answer" do
    visit "/query-parameters-based/start"

    find "h1", text: "Question 1 title"
    choose "Response 1"
    click_on "Continue"

    find "h1", text: "Question 2 title"
    click_on "Change"

    find "h1", text: "Question 1 title"
    assert_page_has_content "Question 1 title"
    assert_current_url "/query-parameters-based/question1?question1=response1"
  end

  should "allow restarting a flow" do
    visit "/query-parameters-based/start"

    find "h1", text: "Question 1 title"
    choose "Response 1"
    click_on "Continue"

    find "h1", text: "Question 2 title"
    fill_in "response", with: "Response"
    click_on "Continue"

    find "h1", text: "Information based on your answers"
    click_on "Start again"

    find "h1", text: "This is a test flow"
    assert_page_has_content "This is a test flow"
    assert_current_url "/query-parameters-based"
  end
end
