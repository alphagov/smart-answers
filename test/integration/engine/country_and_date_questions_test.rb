# encoding: UTF-8
require_relative 'engine_test_helper'

class CountryAndDateQuestionsTest < EngineIntegrationTest

  with_and_without_javascript do
    should "handle country and date questions" do
      visit "/country-and-date-sample/y"

      within '.current-question' do
        within 'h2' do
          within('.question-number') { assert_page_has_content "1" }
          assert_page_has_content "Which country do you live in?"
        end
      end
      within '.question-body' do
        # TODO Check country list
        assert page.has_select?("response")
      end

      select "Belarus", :from => "response"
      click_on "Next step"

      assert_current_url "/country-and-date-sample/y/belarus"

      within '.done-questions' do
        within('.start-again') { assert page.has_link?("Start again", :href => '/country-and-date-sample') }
        within 'ol li.done:nth-child(1)' do
          within 'h3' do
            within('.question-number') { assert_page_has_content "1" }
            assert_page_has_content "Which country do you live in?"
          end
          within('.answer') { assert_page_has_content "Belarus" }
          within('.undo') { assert page.has_link?("Change this answer", :href => "/country-and-date-sample/y/?previous_response=belarus") }
        end
      end

      within '.current-question' do
        within 'h2' do
          within('.question-number') { assert_page_has_content "2" }
          assert_page_has_content "What date did you move there?"
        end
      end

      within '.question-body' do
        # TODO Check options for dates
        assert page.has_select? 'Day'
        assert page.has_select? 'Month'
        assert page.has_select? 'Year'
      end

      select "5", :from => "Day"
      select "May", :from => "Month"
      select "1975", :from => "Year"
      click_on "Next step"

      assert_current_url "/country-and-date-sample/y/belarus/1975-05-05"

      within '.done-questions' do
        within('.start-again') { assert page.has_link?("Start again", :href => '/country-and-date-sample') }
        within 'ol li.done:nth-child(1)' do
          within 'h3' do
            within('.question-number') { assert_page_has_content "1" }
            assert_page_has_content "Which country do you live in?"
          end
          within('.answer') { assert_page_has_content "Belarus" }
          within('.undo') { assert page.has_link?("Change this answer", :href => "/country-and-date-sample/y/?previous_response=belarus") }
        end
        within 'ol li.done:nth-child(2)' do
          within 'h3' do
            within('.question-number') { assert_page_has_content "2" }
            assert_page_has_content "What date did you move there?"
          end
          within('.answer') { assert_page_has_content "5 May 1975" }
          within('.undo') { assert page.has_link?("Change this answer", :href => "/country-and-date-sample/y/belarus?previous_response=1975-05-05") }
        end
      end

      within '.outcome' do
        within '.result-info' do
          within('h2.result-title') { assert_page_has_content "Great - you've lived in belarus for 37 years!" }
        end
      end
    end
  end # with_and_without_javascript
end
