require_relative 'engine_test_helper'

class InputValidationTest < EngineIntegrationTest
  with_and_without_javascript do
    should "validate input and display errors" do
      visit "/money-and-salary-sample/y"

      fill_in "£", with: "-123"
      click_on "Next step"

      within '.current-question' do
        assert_page_has_content "How much do you earn?"
        within('.error') { assert_page_has_content "Please answer this question" }
        assert page.has_field?("£", type: "text", with: "-123")
      end

      fill_in "£", with: "4000"
      select "month", from: "per"
      click_on "Next step"

      assert_current_url "/money-and-salary-sample/y/4000.0-month"

      fill_in "£", with: "asdfasdf"
      click_on "Next step"

      within '.current-question' do
        assert_page_has_content "What size bonus do you want?"
        within('.error') { assert_page_has_content "Sorry, I couldn't understand that number. Please try again." }
        assert page.has_field?("£", type: "text", with: "asdfasdf")
      end

      fill_in "£", with: "50000"
      click_on "Next step"

      assert_current_url "/money-and-salary-sample/y/4000.0-month/50000.0"
    end

    should "allow custom validation in calculations" do
      visit "/money-and-salary-sample/y/4000.0-month"

      fill_in "£", with: "3000"
      click_on "Next step"

      within '.current-question' do
        assert_page_has_content "What size bonus do you want?"
        within('.error') { assert_page_has_content "You can't request a bonus less than your annual salary." }
        assert page.has_field?("£", type: "text", with: "3000")
      end

      fill_in "£", with: "50000"
      click_on "Next step"

      assert_current_url "/money-and-salary-sample/y/4000.0-month/50000.0"

      within '.outcome:nth-child(1)' do
        within '.result-info' do
          within('h2.result-title') { assert_page_has_content "OK, here you go." }
          within('.info-notice') { assert_page_has_content "This is allowed because £50,000 is more than your annual salary of £48,000" }
        end
      end
    end

    should "allow custom error messages with interpolation" do
      visit "/custom-errors-sample/y"

      fill_in "Things", with: "asdfasdf"
      click_on "Next step"

      within '.current-question' do
        assert_page_has_content "How many things do you own?"
        within('.error') { assert_page_has_content "Sorry, but that is not a number. Please try again." }
        assert page.has_field?("Things", type: "text", with: "asdfasdf")
      end
    end
  end # with_and_without_javascript

  should "400 when given invalid UTF-8 in responses" do
    assert_raises(ActionController::BadRequest) do
      get "/custom-errors-sample/y/age/female/%bf'%bf%22-01-02"
    end
  end
end
