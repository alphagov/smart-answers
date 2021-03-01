require_relative "engine_test_helper"

class MoneyAndSalaryQuestionsTest < EngineIntegrationTest
  with_and_without_javascript do
    setup do
      stub_content_store_has_item("/money-and-salary-sample")
    end

    should "handle money and salary questions" do
      visit "/money-and-salary-sample/y"

      within "#current-question" do
        within '.govuk-label[for="response_amount"]' do
          assert_page_has_content "How much do you earn?"
        end

        assert page.has_field?("response[amount]", type: "text")
        assert page.has_select?("response[period]", options: ["per week", "per month", "per year"])
      end

      fill_in "response[amount]", with: "5000"
      select "month", from: "response[period]"
      click_on "Continue"

      assert_current_url "/money-and-salary-sample/y/5000.0-month"

      within ".govuk-table" do
        assert page.has_link?("Start again", href: "/money-and-salary-sample")
        within "tbody tr.govuk-table__row" do
          within ".govuk-table__cell:nth-child(1)" do
            assert_page_has_content "How much do you earn?"
          end
          within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "£5,000 per month" }
        end
      end

      within "#current-question" do
        within '.govuk-label[for="response"]' do
          assert_page_has_content "What size bonus do you want?"
        end

        assert page.has_field?("response", type: "text")
      end

      fill_in "response", with: "1000000"
      click_on "Continue"

      assert_current_url "/money-and-salary-sample/y/5000.0-month/1000000.0"

      within ".govuk-table" do
        assert page.has_link?("Start again", href: "/money-and-salary-sample")
        within "tbody tr.govuk-table__row:nth-child(1)" do
          within ".govuk-table__cell:nth-child(1)" do
            assert_page_has_content "How much do you earn?"
          end
          within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "£5,000 per month" }
        end
        within "tbody tr.govuk-table__row:nth-child(2)" do
          within ".govuk-table__cell:nth-child(1)" do
            assert_page_has_content "What size bonus do you want?"
          end
          within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "£1,000,000" }
        end
      end

      within "#result-info" do
        within(".result-body h2.gem-c-heading") { assert_page_has_content "OK, here you go." }
        within(".info-notice") { assert_page_has_content "This is allowed because £1,000,000 is more than your annual salary of £60,000" }
      end
    end
  end # with_and_without_javascript
end
