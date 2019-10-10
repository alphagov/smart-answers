require_relative "engine_test_helper"

class ChangingAnswerTest < EngineIntegrationTest
  with_and_without_javascript do
    should "be able to change country and date answers" do
      stub_smart_answer_in_content_store("country-and-date-sample")

      stub_world_locations(%w(argentina belarus))

      visit "/country-and-date-sample/y"

      select "Belarus", from: "response"
      click_on "Next step"

      within("#current-question") { assert_page_has_content "What date did you move there?" }
      select "5", from: "Day"
      select "May", from: "Month"
      select "1975", from: "Year"
      click_on "Next step"

      within("#current-question") { assert_page_has_content "Which country were you born in?" }

      within("tbody tr.govuk-table__row:nth-child(1)") { click_on "Change" }

      within "#current-question" do
        assert_page_has_content "Which country do you live in?"
        assert page.has_selector? :select, "response", selected: "Belarus"
      end

      select "Argentina", from: "response"
      click_on "Next step"

      assert_current_url "/country-and-date-sample/y/argentina"

      select "10", from: "Day"
      select "June", from: "Month"
      select "1985", from: "Year"
      click_on "Next step"

      within("tbody tr.govuk-table__row:nth-child(2)") { click_on "Change" }

      within "#current-question" do
        assert page.has_select? "Day", selected: "10"
        assert page.has_select? "Month", selected: "June"
        assert page.has_select? "Year", selected: "1985"
      end

      select "15", from: "Day"
      select "April", from: "Month"
      select "2000", from: "Year"
      click_on "Next step"

      assert_current_url "/country-and-date-sample/y/argentina/2000-04-15"
    end

    should "be able to change money and salary answers" do
      stub_smart_answer_in_content_store("money-and-salary-sample")

      visit "/money-and-salary-sample/y"

      fill_in "response[amount]", with: "5000"
      select "month", from: "response[period]"
      click_on "Next step"

      within("#current-question") { assert_page_has_content "What size bonus do you want?" }
      fill_in "response", with: "1000000"
      click_on "Next step"

      within("#result-info") { assert_page_has_content "OK, here you go." }
      within("tbody tr.govuk-table__row:nth-child(1)") { click_on "Change" }

      within "#current-question" do
        assert page.has_field? "response[amount]", with: "5000.0"
        assert page.has_select? "response[period]", selected: "per month"
      end

      fill_in "response[amount]", with: "2000"
      select "week", from: "response[period]"
      click_on "Next step"

      assert_current_url "/money-and-salary-sample/y/2000.0-week"

      fill_in "response", with: "2000000"
      click_on "Next step"

      within("tbody tr.govuk-table__row:nth-child(2)") { click_on "Change" }

      within("#current-question") { assert page.has_field? "response", with: "2000000.0" }

      fill_in "response", with: "3000000"
      click_on "Next step"

      assert_current_url "/money-and-salary-sample/y/2000.0-week/3000000.0"
    end

    should "be able to change value and multiple choice answers" do
      stub_smart_answer_in_content_store("bridge-of-death")

      visit "/bridge-of-death/y"

      fill_in "response", with: "Lancelot"
      click_on "Next step"

      within("#current-question") { assert_page_has_content "What...is your quest?" }
      choose("To seek the Holy Grail", visible: false)
      click_on "Next step"

      within("#current-question") { assert_page_has_content "What...is your favorite colour?" }
      choose("Blue", visible: false)
      click_on "Next step"

      within("#result-info") { assert_page_has_content "Right, off you go." }
      within("tbody tr.govuk-table__row:nth-child(1)") { click_on "Change" }

      within("#current-question") { assert page.has_field? "response", with: "Lancelot" }

      fill_in "response", with: "Bors"
      click_on "Next step"

      assert_current_url "/bridge-of-death/y/Bors"

      within("#current-question") { assert_page_has_content "What...is your quest?" }
      choose("To seek the Holy Grail", visible: false)
      click_on "Next step"

      within("#current-question") { assert_page_has_content "What...is your favorite colour?" }
      choose("Blue", visible: false)
      click_on "Next step"

      within("#result-info") { assert_page_has_content "Right, off you go." }
      within("tbody tr.govuk-table__row:nth-child(2)") { click_on "Change" }

      within "#current-question" do
        assert page.has_checked_field?("To seek the Holy Grail", visible: false)
        assert page.has_unchecked_field?("To rescue the princess", visible: false)
        assert page.has_unchecked_field?("I dunno", visible: false)
      end

      choose("To rescue the princess", visible: false)
      click_on "Next step"

      assert_current_url "/bridge-of-death/y/Bors/to_rescue_the_princess"

      choose("Blue", visible: false)
      click_on "Next step"

      within("#result-info") { assert_page_has_content "Right, off you go." }
      within("tbody tr.govuk-table__row:nth-child(3)") { click_on "Change" }

      within "#current-question" do
        assert page.has_checked_field?("Blue", visible: false)
        assert page.has_unchecked_field?("Blue... NO! YELLOOOOOOOOOOOOOOOOWWW!!!!", visible: false)
        assert page.has_unchecked_field?("Red", visible: false)
      end

      choose("Red", visible: false)
      click_on "Next step"

      assert_current_url "/bridge-of-death/y/Bors/to_rescue_the_princess/red"
    end

    should "be able to change checkbox answers" do
      stub_smart_answer_in_content_store("checkbox-sample")

      visit "/checkbox-sample/y"

      check("Peppers", visible: false)
      check("Pepperoni", visible: false)
      click_on "Next step"

      assert_current_url "/checkbox-sample/y/pepperoni,peppers"

      within("tbody tr.govuk-table__row:nth-child(1)") { click_on "Change" }

      within "#current-question" do
        assert page.has_unchecked_field?("Ham", visible: false)
        assert page.has_checked_field?("Peppers", visible: false)
        assert page.has_unchecked_field?("Ice Cream!!!", visible: false)
        assert page.has_checked_field?("Pepperoni", visible: false)
      end

      check("Ham", visible: false)
      click_on "Next step"

      assert_current_url "/checkbox-sample/y/ham,pepperoni,peppers"
    end

    should "be able to change postcode answer" do
      stub_smart_answer_in_content_store("postcode-sample")

      visit "/postcode-sample/y"

      fill_in "response", with: "B1 1PW"
      click_on "Next step"

      assert_current_url "/postcode-sample/y/#{URI.escape('B1 1PW')}" # rubocop:disable Lint/UriEscapeUnescape

      within("tbody tr.govuk-table__row:nth-child(1)") { click_on "Change" }

      within "#current-question" do
        assert page.has_field? "response", with: "B1 1PW"
      end
    end
  end
end
