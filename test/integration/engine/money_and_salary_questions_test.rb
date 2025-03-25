require_relative "engine_test_helper"

class MoneyAndSalaryQuestionsTest < EngineIntegrationTest
  setup do
    stub_content_store_has_item("/annual-bonus")
  end

  with_and_without_javascript do
    should "handle money and salary questions" do
      visit "/annual-bonus/y"

      find "h1", text: "How much do you earn?"
      within "#current-question" do
        within '.govuk-label[for="response"]' do
          assert_page_has_content "How much do you earn?"
        end

        assert page.has_field?("response[amount]", type: "text")
        assert page.has_select?("response[period]", options: ["per week", "per month", "per year"])
      end

      fill_in "response[amount]", with: "5000"
      select "month", from: "response[period]"
      click_on "Continue"

      find "h1", text: "What size bonus do you want?"
      assert_current_url "/annual-bonus/y/5000.0-month"

      assert page.has_link?("Start again", href: "/annual-bonus")
      within ".gem-c-summary-list" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "How much do you earn?"
        end
        within(".govuk-summary-list__value") { assert_page_has_content "£5,000 per month" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/annual-bonus/y?previous_response=5000.0-month") }
      end

      within "#current-question" do
        within '.govuk-label[for="response"]' do
          assert_page_has_content "What size bonus do you want?"
        end

        assert page.has_field?("response", type: "text")
      end

      fill_in "response", with: "1000000"
      click_on "Continue"

      find "h1", text: "Information based on your answers"
      assert_current_url "/annual-bonus/y/5000.0-month/1000000.0"

      assert page.has_link?("Start again", href: "/annual-bonus")
      within ".govuk-summary-list__row:nth-child(1)" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "How much do you earn?"
        end
        within(".govuk-summary-list__value") { assert_page_has_content "£5,000 per month" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/annual-bonus/y?previous_response=5000.0-month") }
      end
      within ".govuk-summary-list__row:nth-child(2)" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "What size bonus do you want?"
        end
        within(".govuk-summary-list__value") { assert_page_has_content "£1,000,000" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/annual-bonus/y/5000.0-month?previous_response=1000000.0") }
      end

      within "#result-info" do
        within page.find(".gem-c-heading h2", match: :first) { assert_page_has_content "OK, here you go." }
        within(".info-notice") { assert_page_has_content "This is allowed because £1,000,000 is more than your annual salary of £60,000" }
      end
    end
  end # with_and_without_javascript
end
