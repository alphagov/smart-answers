require_relative 'engine_test_helper'
require 'gds_api/test_helpers/worldwide'

class ChangingAnswerTest < EngineIntegrationTest
  include GdsApi::TestHelpers::Worldwide

  with_and_without_javascript do
    should "be able to change country and date answers" do
      worldwide_api_has_selection_of_locations

      visit "/country-and-date-sample/y"

      select "Belarus", from: "response"
      click_on "Next step"

      within('.current-question') { assert_page_has_content "What date did you move there?" }
      select "5", from: "Day"
      select "May", from: "Month"
      select "1975", from: "Year"
      click_on "Next step"

      within('.current-question') { assert_page_has_content "Which country were you born in?" }

      within('tr.section:nth-child(1)') { click_on "Change" }

      within '.current-question' do
        assert_page_has_content "Which country do you live in?"
        assert page.has_selector? :select, "response", selected: "Belarus"
      end

      select "South Korea", from: "response"
      click_on "Next step"

      assert_current_url "/country-and-date-sample/y/south-korea"

      select "10", from: "Day"
      select "June", from: "Month"
      select "1985", from: "Year"
      click_on "Next step"

      within('tr.section:nth-child(2)') { click_on "Change" }

      within '.current-question .question-body' do
        assert page.has_select? "Day", selected: "10"
        assert page.has_select? "Month", selected: "June"
        assert page.has_select? "Year", selected: "1985"
      end

      select "15", from: "Day"
      select "April", from: "Month"
      select "2000", from: "Year"
      click_on "Next step"

      assert_current_url "/country-and-date-sample/y/south-korea/2000-04-15"
    end

    should "be able to change money and salary answers" do
      visit "/money-and-salary-sample/y"

      fill_in "£", with: "5000"
      select "month", from: "per"
      click_on "Next step"

      within('.current-question') { assert_page_has_content "What size bonus do you want?" }
      fill_in "£", with: "1000000"
      click_on "Next step"

      within('.result-info') { assert_page_has_content "OK, here you go." }
      within('tr.section:nth-child(1)') { click_on "Change" }

      within '.current-question .question-body' do
        assert page.has_field? "£", with: "5000.0"
        assert page.has_select? "per", selected: "month"
      end

      fill_in "£", with: "2000"
      select "week", from: "per"
      click_on "Next step"

      assert_current_url "/money-and-salary-sample/y/2000.0-week"

      fill_in "£", with: "2000000"
      click_on "Next step"

      within('tr.section:nth-child(2)') { click_on "Change" }

      within('.current-question .question-body') { assert page.has_field? "£", with: "2000000.0" }

      fill_in "£", with: "3000000"
      click_on "Next step"

      assert_current_url "/money-and-salary-sample/y/2000.0-week/3000000.0"
    end

    should "be able to change value and multiple choice answers" do
      visit "/bridge-of-death/y"

      fill_in "Name:", with: "Lancelot"
      click_on "Next step"

      within('.current-question') { assert_page_has_content "What...is your quest?" }
      choose "To seek the Holy Grail"
      click_on "Next step"

      within('.current-question') { assert_page_has_content "What...is your favorite colour?" }
      choose "Blue"
      click_on "Next step"

      within('.result-info') { assert_page_has_content "Right, off you go." }
      within('tr.section:nth-child(1)') { click_on "Change" }

      within('.current-question .question-body') { assert page.has_field? "Name:", with: "Lancelot" }

      fill_in "Name:", with: "Bors"
      click_on "Next step"

      assert_current_url "/bridge-of-death/y/Bors"

      within('.current-question') { assert_page_has_content "What...is your quest?" }
      choose "To seek the Holy Grail"
      click_on "Next step"

      within('.current-question') { assert_page_has_content "What...is your favorite colour?" }
      choose "Blue"
      click_on "Next step"

      within('.result-info') { assert_page_has_content "Right, off you go." }
      within('tr.section:nth-child(2)') { click_on "Change" }

      within '.current-question .question-body' do
        assert page.has_checked_field? "To seek the Holy Grail"
         assert page.has_unchecked_field? "To rescue the princess"
         assert page.has_unchecked_field? "I dunno"
      end

      choose "To rescue the princess"
      click_on "Next step"

      assert_current_url "/bridge-of-death/y/Bors/to_rescue_the_princess"

      choose "Blue"
      click_on "Next step"

      within('.result-info') { assert_page_has_content "Right, off you go." }
      within('tr.section:nth-child(3)') { click_on "Change" }

      within '.current-question .question-body' do
        assert page.has_checked_field? "Blue"
        assert page.has_unchecked_field? "Blue... NO! YELLOOOOOOOOOOOOOOOOWWW!!!!"
        assert page.has_unchecked_field? "Red"
      end

      choose "Red"
      click_on "Next step"

      assert_current_url "/bridge-of-death/y/Bors/to_rescue_the_princess/red"
    end

    should "be able to change checkbox answers" do
      visit "/checkbox-sample/y"

      check "Peppers"
      check "Pepperoni"
      click_on "Next step"

      assert_current_url "/checkbox-sample/y/pepperoni,peppers"

      within('tr.section:nth-child(1)') { click_on "Change" }

      within '.current-question .question-body' do
        assert page.has_unchecked_field?("Ham")
        assert page.has_checked_field?("Peppers")
        assert page.has_unchecked_field?("Ice Cream!!!")
        assert page.has_checked_field?("Pepperoni")
      end

      check "Ham"
      click_on "Next step"

      assert_current_url "/checkbox-sample/y/ham,pepperoni,peppers"
    end

    should "be able to change postcode answer" do
      visit "/postcode-sample/y"

      fill_in "response", with: "B1 1PW"
      click_on "Next step"

      assert_current_url "/postcode-sample/y/#{URI.escape('B1 1PW')}"

      within('tr.section:nth-child(1)') { click_on "Change" }

      within '.current-question .question-body' do
        assert page.has_field? "response", with: "B1 1PW"
      end
    end
  end
end
