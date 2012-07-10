# encoding: UTF-8
require_relative 'engine_test_helper'

class InputValidationTest < EngineIntegrationTest

  with_and_without_javascript do
    should "validate input and display errors" do

      visit "/money-and-salary-sample/y"

      fill_in "£", :with => "-123"
      click_on "Next step"

      within '.current-question' do
        assert_page_has_content "How much do you earn?"
        within('.error') { assert_page_has_content "Please answer this question" }
        assert page.has_field?("£", :type => :text, :with => "-123")
      end

      fill_in "£", :with => "4000"
      select "month", :from => "per"
      click_on "Next step"

      assert_current_url "/money-and-salary-sample/y/4000.0-month"

      fill_in "£", :with => "asdfasdf"
      click_on "Next step"

      within '.current-question' do
        assert_page_has_content "What size bonus do you want?"
        within('.error') { assert_page_has_content "Sorry, I couldn't understand that number. Please try again." }
        assert page.has_field?("£", :type => :text, :with => "asdfasdf")
      end

      fill_in "£", :with => "50000"
      click_on "Next step"

      assert_current_url "/money-and-salary-sample/y/4000.0-month/50000.0"
    end

    should "allow custom validation in calculations" do
      pending "Custom validation bug needs to be fixed"
      visit "/money-and-salary-sample/y/4000.0-month"

      fill_in "£", :with => "3000"
      click_on "Next step"

      within '.current-question' do
        assert_page_has_content "What size bonus do you want?"
        within('.error') { assert_page_has_content "You can't request a bonus less than your annual salary." }
        assert page.has_field?("£", :type => :text, :with => "3000")
      end

      fill_in "£", :with => "50000"
      click_on "Next step"

      assert_current_url "/money-and-salary-sample/y/4000.0-month/50000.0"

      within '.outcome' do
        within '.result-info' do
          within('h2.result-title') { assert_page_has_content "OK, here you go." }
          within('.info-notice') { assert_page_has_content "This is allowed because £50,000 is more than your annual salary of £48,000" }
        end
      end
    end
  end # with_and_without_javascript
end
