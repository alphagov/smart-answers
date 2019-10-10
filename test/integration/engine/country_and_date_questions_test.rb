require_relative "engine_test_helper"

class CountryAndDateQuestionsTest < EngineIntegrationTest
  with_and_without_javascript do
    setup do
      @location_slugs = %w(
        angola aruba bangladesh belarus brazil brunei
        cambodia chad croatia denmark eritrea france ghana iceland
        japan laos luxembourg malta micronesia mozambique nicaragua
        panama portugal sao-tome-and-principe singapore south-korea
        sri-lanka venezuela vietnam
      )
      stub_world_locations(@location_slugs)
      Timecop.travel("2013-01-01")

      stub_smart_answer_in_content_store("country-and-date-sample")
    end

    should "handle country and date questions" do
      visit "/country-and-date-sample/y"

      within "#current-question" do
        assert_page_has_content "Which country do you live in?"
      end
      within "#current-question" do
        assert page.has_select?("response")
        actual = page.all("select option").map(&:value)
        assert_equal @location_slugs, actual
      end

      select "Belarus", from: "response"
      click_on "Next step"

      assert_current_url "/country-and-date-sample/y/belarus"

      within ".govuk-table" do
        assert page.has_link?("Start again", href: "/country-and-date-sample")
        within "tbody tr.govuk-table__row:nth-child(1)" do
          within ".govuk-table__cell:nth-child(1)" do
            assert_page_has_content "Which country do you live in?"
          end
          within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "Belarus" }
          within(".govuk-table__cell:nth-child(3)") { assert page.has_link?("Change", href: "/country-and-date-sample/y?previous_response=belarus") }
        end
      end

      within "#current-question" do
        assert_page_has_content "What date did you move there?"
      end

      within "#current-question" do
        # TODO Check options for dates
        assert page.has_select? "Day"
        assert page.has_select? "Month"
        assert page.has_select? "Year"
      end

      select "5", from: "Day"
      select "May", from: "Month"
      select "1975", from: "Year"
      click_on "Next step"

      assert_current_url "/country-and-date-sample/y/belarus/1975-05-05"

      within ".govuk-table" do
        assert page.has_link?("Start again", href: "/country-and-date-sample")
        within "tbody tr.govuk-table__row:nth-child(1)" do
          within ".govuk-table__cell:nth-child(1)" do
            assert_page_has_content "Which country do you live in?"
          end
          within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "Belarus" }
          within(".govuk-table__cell:nth-child(3)") { assert page.has_link?("Change", href: "/country-and-date-sample/y?previous_response=belarus") }
        end

        within "tbody tr.govuk-table__row:nth-child(2)" do
          within ".govuk-table__cell:nth-child(1)" do
            assert_page_has_content "What date did you move there?"
          end

          within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "5 May 1975" }
          within(".govuk-table__cell:nth-child(3)") { assert page.has_link?("Change", href: "/country-and-date-sample/y/belarus?previous_response=1975-05-05") }
        end
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
      click_on "Next step"

      assert_current_url "/country-and-date-sample/y/belarus/1975-05-05/venezuela"

      within ".govuk-table" do
        assert page.has_link?("Start again", href: "/country-and-date-sample")
        within "tbody tr.govuk-table__row:nth-child(1)" do
          within ".govuk-table__cell:nth-child(1)" do
            assert_page_has_content "Which country do you live in?"
          end
          within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "Belarus" }
          within(".govuk-table__cell:nth-child(3)") { assert page.has_link?("Change", href: "/country-and-date-sample/y?previous_response=belarus") }
        end

        within "tbody tr.govuk-table__row:nth-child(2)" do
          within ".govuk-table__cell:nth-child(1)" do
            assert_page_has_content "What date did you move there?"
          end

          within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "5 May 1975" }
          within(".govuk-table__cell:nth-child(3)") { assert page.has_link?("Change", href: "/country-and-date-sample/y/belarus?previous_response=1975-05-05") }
        end

        within "tbody tr.govuk-table__row:nth-child(3)" do
          within ".govuk-table__cell:nth-child(1)" do
            assert_page_has_content "Which country were you born in?"
          end

          within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "Venezuela" }
          within(".govuk-table__cell:nth-child(3)") { assert page.has_link?("Change", href: "/country-and-date-sample/y/belarus/1975-05-05?previous_response=venezuela") }
        end
      end

      within "#result-info" do
        within("h2.gem-c-heading") { assert_page_has_content "Great - you've lived in belarus for 37 years, and were born in venezuela!" }
      end
    end
  end # with_and_without_javascript
end
