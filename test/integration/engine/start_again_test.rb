require_relative "engine_test_helper"

class StartAgainTest < EngineIntegrationTest
  should "should set the GA4 section parameter to the title of the question when the flow is in progress" do
    visit "/session-based/start"

    find "h1", text: "Question 1 title"
    choose "Response 1"
    click_on "Continue"

    find "h1", text: "Question 2 title"
    assert page.has_css?(".govuk-link[data-module='ga4-link-tracker']")
    assert page.has_css?(".govuk-link[data-ga4-link='{\"event_name\":\"form_start_again\",\"type\":\"smart answer\",\"section\":\"Question 2 title\",\"action\":\"start again\",\"tool_name\":\"This is a test flow\"}']")
  end

  should "should set the GA4 section parameter to \"Information based on your answers\" when the flow has been completed" do
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
    assert page.has_css?(".govuk-link[data-module='ga4-link-tracker']")
    assert page.has_css?(".govuk-link[data-ga4-link='{\"event_name\":\"form_start_again\",\"type\":\"smart answer\",\"section\":\"Information based on your answers\",\"action\":\"start again\",\"tool_name\":\"This is a test flow\"}']")
  end

  should "should set the GA4 section parameter to title of the question when the user revisits a section to change their answer" do
    visit "/session-based/start"

    find "h1", text: "Question 1 title"
    choose "Response 1"
    click_on "Continue"

    find "h1", text: "Question 2 title"
    fill_in "response", with: "Response"
    click_on "Continue"

    assert_page_has_content "Results title"
    assert_current_url "/session-based/results"
    assert page.has_css?(".govuk-link[data-module='ga4-link-tracker']")
    assert page.has_css?(".govuk-link[data-ga4-link='{\"event_name\":\"form_start_again\",\"type\":\"smart answer\",\"section\":\"Information based on your answers\",\"action\":\"start again\",\"tool_name\":\"This is a test flow\"}']")

    click_on "Change Question 2 title"

    find "h1", text: "Question 2 title"
    assert page.has_css?(".govuk-link[data-module='ga4-link-tracker']")
    assert page.has_css?(".govuk-link[data-ga4-link='{\"event_name\":\"form_start_again\",\"type\":\"smart answer\",\"section\":\"Question 2 title\",\"action\":\"start again\",\"tool_name\":\"This is a test flow\"}']")
  end
end
