require_relative "engine_test_helper"

class InputValidationTest < EngineIntegrationTest
  with_and_without_javascript do
    should "validate input and display errors" do
      stub_content_store_has_item("/annual-bonus")

      visit "/annual-bonus/y"

      fill_in "response[amount]", with: "-123"
      click_on "Continue"

      within "#current-question" do
        assert_page_has_content "How much do you earn?"
        within(".govuk-error-summary [href]") { assert_page_has_content "Please answer this question" }
        within(".govuk-error-message") { assert_page_has_content "Please answer this question" }
        assert page.has_field?("response[amount]", type: "text", with: "-123")
      end

      fill_in "response[amount]", with: "4000"
      select "month", from: "response[period]"
      click_on "Continue"

      assert_current_url "/annual-bonus/y/4000.0-month"

      fill_in "response", with: "asdfasdf"
      click_on "Continue"

      within "#current-question" do
        assert_page_has_content "What size bonus do you want?"
        within(".govuk-error-message") { assert_page_has_content "Sorry, that number is not valid. Please try again." }
        assert page.has_field?("response", type: "text", with: "asdfasdf")
      end

      fill_in "response", with: "50000"
      click_on "Continue"

      assert_current_url "/annual-bonus/y/4000.0-month/50000.0"
    end

    should "allow custom validation in calculations" do
      stub_content_store_has_item("/annual-bonus")

      visit "/annual-bonus/y/4000.0-month"

      fill_in "response", with: "3000"
      click_on "Continue"

      within "#current-question" do
        assert_page_has_content "What size bonus do you want?"
        within(".govuk-error-message") { assert_page_has_content "You can't request a bonus less than your annual salary." }
        assert page.has_field?("response", type: "text", with: "3000")
      end

      fill_in "response", with: "50000"
      click_on "Continue"

      assert_current_url "/annual-bonus/y/4000.0-month/50000.0"

      within "#result-info" do
        within page.find(".gem-c-heading h2", match: :first) { assert_page_has_content "OK, here you go." }
        within(".info-notice") { assert_page_has_content "This is allowed because £50,000 is more than your annual salary of £48,000" }
      end
    end

    should "allow custom error messages with interpolation" do
      stub_content_store_has_item("/custom-errors-sample")

      visit "/custom-errors-sample/y"

      fill_in "response", with: "asdfasdf"
      click_on "Continue"

      within "#current-question" do
        assert_page_has_content "How many things do you own?"
        within(".govuk-error-message") { assert_page_has_content "Sorry, but that is not a number. Please try again." }
        assert page.has_field?("response", type: "text", with: "asdfasdf")
      end
    end
  end # with_and_without_javascript

  should "400 when given invalid UTF-8 in responses" do
    stub_content_store_has_item("/custom-errors-sample")

    assert_raises(ActionController::BadRequest) do
      get "/custom-errors-sample/y/age/female/%bf'%bf%22-01-02"
    end
  end
end
