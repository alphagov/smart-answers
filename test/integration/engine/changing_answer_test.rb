require_relative "engine_test_helper"

class ChangingAnswerTest < EngineIntegrationTest
  with_and_without_javascript do
    should "be able to change country and date answers" do
      stub_content_store_has_item("/moved-to-country")
      stub_worldwide_api_has_locations(%w[argentina belarus])

      visit "/moved-to-country/y"

      find "h1", text: "Which country do you live in?"
      select "Belarus", from: "response"
      click_on "Continue"

      find "h1", text: "What date did you move there?"
      fill_in "response[day]", with: "5"
      fill_in "response[month]", with: "5"
      fill_in "response[year]", with: "1975"
      click_on "Continue"

      find "h1", text: "Which country were you born in?"
      within(".govuk-summary-list__row:nth-child(1)") { click_on "Change" }

      find "h1", text: "Which country do you live in?"
      within "#current-question" do
        assert page.has_selector? :select, "response", selected: "Belarus"
      end
      select "Argentina", from: "response"
      click_on "Continue"

      find "h1", text: "What date did you move there?"
      assert_current_url "/moved-to-country/y/argentina"

      fill_in "response[day]", with: "10"
      fill_in "response[month]", with: "6"
      fill_in "response[year]", with: "1985"
      click_on "Continue"

      within(".govuk-summary-list__row:nth-child(2)") { click_on "Change" }

      find "h1", text: "What date did you move there?"
      within "#current-question" do
        assert page.has_field? "Day", with: "10"
        assert page.has_field? "Month", with: "6"
        assert page.has_field? "Year", with: "1985"
      end

      fill_in "response[day]", with: "15"
      fill_in "response[month]", with: "4"
      fill_in "response[year]", with: "2000"
      click_on "Continue"

      find "h1", text: "Which country were you born in?"
      assert_current_url "/moved-to-country/y/argentina/2000-04-15"
    end

    should "be able to change money and salary answers" do
      stub_content_store_has_item("/annual-bonus")

      visit "/annual-bonus/y"

      find "h1", text: "How much do you earn?"
      fill_in "response[amount]", with: "5000"
      select "month", from: "response[period]"
      click_on "Continue"

      find "h1", text: "What size bonus do you want?"
      fill_in "response", with: "1000000"
      click_on "Continue"

      find "h1", text: "Information based on your answers"
      within(".govuk-summary-list__row:nth-child(1)") { click_on "Change" }

      find "h1", text: "How much do you earn?"
      within "#current-question" do
        assert page.has_field? "response[amount]", with: "5000.0"
        assert page.has_select? "response[period]", selected: "per month"
      end

      fill_in "response[amount]", with: "2000"
      select "week", from: "response[period]"
      click_on "Continue"

      find "h1", text: "What size bonus do you want?"
      assert_current_url "/annual-bonus/y/2000.0-week"

      fill_in "response", with: "2000000"
      click_on "Continue"

      find "h1", text: "Information based on your answers"
      within(".govuk-summary-list__row:nth-child(2)") do
        click_on "Change"
      end

      find "h1", text: "What size bonus do you want?"
      within("#current-question") { assert page.has_field? "response", with: "2000000.0" }
      fill_in "response", with: "3000000"
      click_on "Continue"

      find "h1", text: "Information based on your answers"
      assert_current_url "/annual-bonus/y/2000.0-week/3000000.0"
    end

    should "be able to change value and radio answers" do
      stub_content_store_has_item("/bridge-of-death")

      visit "/bridge-of-death/y"

      find "h1", text: "What...is your name?"
      fill_in "response", with: "Lancelot"
      click_on "Continue"

      find "h1", text: "What...is your quest?"
      choose("To seek the Holy Grail", visible: false, allow_label_click: true)
      click_on "Continue"

      find "h1", text: "Colour options"
      choose("Yes", visible: false, allow_label_click: true)
      click_on "Continue"

      find "h1", text: "What...is your favorite colour?"
      choose("Blue", visible: false, allow_label_click: true)
      click_on "Continue"

      find "h1", text: "The Bridge of Death: Information based on your answers", normalize_ws: true
      within(".govuk-summary-list__row:nth-child(1)") { click_on "Change" }

      find "h1", text: "What...is your name?"
      fill_in "response", with: "Bors"
      click_on "Continue"

      find "h1", text: "What...is your quest?"
      assert_current_url "/bridge-of-death/y/Bors"

      choose("To seek the Holy Grail", visible: false, allow_label_click: true)
      click_on "Continue"

      find "h1", text: "Colour options"
      choose("Yes", visible: false, allow_label_click: true)
      click_on "Continue"

      find "h1", text: "What...is your favorite colour?"
      choose("Blue", visible: false, allow_label_click: true)
      click_on "Continue"

      find "h1", text: "The Bridge of Death: Information based on your answers", normalize_ws: true
      within(".govuk-summary-list__row:nth-child(2)") { click_on "Change" }

      find "h1", text: "What...is your quest?"
      within "#current-question" do
        assert page.has_checked_field?("To seek the Holy Grail", visible: false)
        assert page.has_unchecked_field?("To rescue the princess", visible: false)
        assert page.has_unchecked_field?("I dunno", visible: false)
      end

      choose("To rescue the princess", visible: false, allow_label_click: true)
      click_on "Continue"

      find "h1", text: "Colour options"
      assert_current_url "/bridge-of-death/y/Bors/to_rescue_the_princess"

      choose("Yes", visible: false, allow_label_click: true)
      click_on "Continue"

      find "h1", text: "What...is your favorite colour?"
      choose("Blue", visible: false, allow_label_click: true)
      click_on "Continue"

      find "h1", text: "The Bridge of Death: Information based on your answers", normalize_ws: true
      within(".govuk-summary-list__row:nth-child(4)") { click_on "Change" }

      find "h1", text: "What...is your favorite colour?"
      within "#current-question" do
        assert page.has_checked_field?("Blue", visible: false)
        assert page.has_unchecked_field?("Blue... NO! YELLOOOOOOOOOOOOOOOOWWW!!!!", visible: false)
        assert page.has_unchecked_field?("Red", visible: false)
      end

      choose("Red", visible: false, allow_label_click: true)
      click_on "Continue"

      find "h1", text: "The Bridge of Death: Information based on your answers", normalize_ws: true
      assert_current_url "/bridge-of-death/y/Bors/to_rescue_the_princess/yes/red"
    end

    should "be able to change checkbox answers" do
      stub_content_store_has_item("/checkbox-sample")

      visit "/checkbox-sample/y"

      find "h1", text: "What do you want on your pizza?"
      check("Peppers", visible: false, allow_label_click: true)
      check("Pepperoni", visible: false, allow_label_click: true)
      click_on "Continue"

      find "h1", text: "Information based on your answers"
      assert_current_url "/checkbox-sample/y/pepperoni,peppers"

      within(".govuk-summary-list__row:nth-child(1)") { click_on "Change" }

      find "h1", text: "What do you want on your pizza?"
      within "#current-question" do
        assert page.has_unchecked_field?("Ham", visible: false)
        assert page.has_checked_field?("Peppers", visible: false)
        assert page.has_unchecked_field?("Ice Cream!!!", visible: false)
        assert page.has_checked_field?("Pepperoni", visible: false)
      end

      check("Ham", visible: false, allow_label_click: true)
      click_on "Continue"

      find "h1", text: "Information based on your answers"
      assert_current_url "/checkbox-sample/y/ham,pepperoni,peppers"
    end

    should "be able to change postcode answer" do
      stub_content_store_has_item("/postcode-sample")

      visit "/postcode-sample/y"

      find "h1", text: "User input?"
      fill_in "response", with: "B1 1PW"
      click_on "Continue"

      find "h1", text: "Sample postcode question: Information based on your answers", normalize_ws: true
      assert_current_url "/postcode-sample/y/B1%201PW"

      within(".govuk-summary-list__row:nth-child(1)") { click_on "Change" }

      find "h1", text: "User input?"
      within "#current-question" do
        assert page.has_field? "response", with: "B1 1PW"
      end
    end
  end
end
