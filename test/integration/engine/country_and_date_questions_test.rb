require_relative "engine_test_helper"

class CountryAndDateQuestionsTest < EngineIntegrationTest
  with_and_without_javascript do
    setup do
      @location_slugs = %w[
        angola
        aruba
        bangladesh
        belarus
        brazil
        brunei
        cambodia
        chad
        croatia
        denmark
        eritrea
        federated-states-of-micronesia
        france
        ghana
        iceland
        japan
        laos
        luxembourg
        malta
        mozambique
        nicaragua
        panama
        portugal
        sao-tome-and-principe
        singapore
        south-korea
        sri-lanka
        venezuela
        vietnam
      ]
      stub_worldwide_api_has_locations(@location_slugs)
      travel_to("2013-01-01")
      stub_content_store_has_item("/moved-to-country")
    end

    should "handle country and date questions" do
      visit "/moved-to-country/y"

      find "h1", text: "Which country do you live in?"
      within "#current-question" do
        assert_page_has_content "Which country do you live in?"
      end
      within "#current-question" do
        assert page.has_select?("response")
        actual = page.all("select option").map(&:value)
        assert_equal @location_slugs, actual
      end

      select "Belarus", from: "response"
      click_on "Continue"

      find "h1", text: "What date did you move there?"
      assert_current_url "/moved-to-country/y/belarus"

      assert page.has_link?("Start again", href: "/moved-to-country")
      within ".govuk-summary-list__row:nth-child(1)" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "Which country do you live in?"
        end
        within(".govuk-summary-list__value") { assert_page_has_content "Belarus" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/moved-to-country/y?previous_response=belarus") }
      end

      within "#current-question" do
        assert_page_has_content "What date did you move there?"
      end

      within "#current-question" do
        # TODO: Check options for dates
        assert page.has_field? "Day"
        assert page.has_field? "Month"
        assert page.has_field? "Year"
      end

      fill_in "Day", with: "5"
      fill_in "Month", with: "5"
      fill_in "Year", with: "1975"
      click_on "Continue"

      find "h1", text: "Which country were you born in?"
      assert_current_url "/moved-to-country/y/belarus/1975-05-05"

      assert page.has_link?("Start again", href: "/moved-to-country")
      within ".govuk-summary-list__row:nth-child(1)" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "Which country do you live in?"
        end
        within(".govuk-summary-list__value") { assert_page_has_content "Belarus" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/moved-to-country/y?previous_response=belarus") }
      end

      within ".govuk-summary-list__row:nth-child(2)" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "What date did you move there?"
        end

        within(".govuk-summary-list__value") { assert_page_has_content "5 May 1975" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/moved-to-country/y/belarus?previous_response=1975-05-05") }
      end

      within "#current-question" do
        assert_page_has_content "Which country were you born in?"
      end
      within "#current-question" do
        assert page.has_select?("response")
        actual = page.all("select option").map(&:value)
        assert_equal @location_slugs, actual
      end

      select "Venezuela", from: "response"
      click_on "Continue"
      find "h1", text: ": Information based on your answers", normalize_ws: true
      assert_current_url "/moved-to-country/y/belarus/1975-05-05/venezuela"

      assert page.has_link?("Start again", href: "/moved-to-country")
      within ".govuk-summary-list__row:nth-child(1)" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "Which country do you live in?"
        end
        within(".govuk-summary-list__value") { assert_page_has_content "Belarus" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/moved-to-country/y?previous_response=belarus") }
      end

      within ".govuk-summary-list__row:nth-child(2)" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "What date did you move there?"
        end

        within(".govuk-summary-list__value") { assert_page_has_content "5 May 1975" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/moved-to-country/y/belarus?previous_response=1975-05-05") }
      end

      within ".govuk-summary-list__row:nth-child(3)" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "Which country were you born in?"
        end

        within(".govuk-summary-list__value") { assert_page_has_content "Venezuela" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/moved-to-country/y/belarus/1975-05-05?previous_response=venezuela") }
      end

      within "#result-info" do
        within page.find(".gem-c-heading h2", match: :first) { assert_page_has_content "Great - you've lived in belarus for 37 years, and were born in venezuela!" }
      end
    end
  end # with_and_without_javascript
end
