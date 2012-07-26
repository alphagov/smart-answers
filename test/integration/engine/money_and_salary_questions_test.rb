# encoding: UTF-8
require_relative 'engine_test_helper'

class MoneyAndSalaryQuestionsTest < EngineIntegrationTest

  with_and_without_javascript do
    should "handle money and salary questions" do
      visit "/money-and-salary-sample/y"

      within '.current-question' do
        within 'h2' do
          within('.question-number') { assert_page_has_content "1" }
          assert_page_has_content "How much do you earn?"
        end
        within '.question-body' do
          assert page.has_field?("£", :type => :text)
          assert page.has_select?("per", :options => %w(week month))
        end
      end

      fill_in "£", :with => "5000"
      select "month", :from => "per"
      click_on "Next step"

      assert_current_url "/money-and-salary-sample/y/5000.0-month"

      within '.done-questions' do
        within('.start-again') { assert page.has_link?("Start again", :href => '/money-and-salary-sample') }
        within 'ol li.done' do
          within 'h3' do
            within('.question-number') { assert_page_has_content "1" }
            assert_page_has_content "How much do you earn?"
          end
          within('.answer') { assert_page_has_content "£5,000 per month" }
          within('.undo') { assert page.has_link?("Change this answer", :href => "/money-and-salary-sample/y/?previous_response=5000.0-month") }
        end
      end

      within '.current-question' do
        within 'h2' do
          within('.question-number') { assert_page_has_content "2" }
          assert_page_has_content "What size bonus do you want?"
        end
        within '.question-body' do
          assert page.has_field?("£", :type => :text)
        end
      end

      fill_in "£", :with => "1000000"
      click_on "Next step"

      assert_current_url "/money-and-salary-sample/y/5000.0-month/1000000.0"

      within '.done-questions' do
        within('.start-again') { assert page.has_link?("Start again", :href => '/money-and-salary-sample') }
        within 'ol li.done:nth-child(1)' do
          within 'h3' do
            within('.question-number') { assert_page_has_content "1" }
            assert_page_has_content "How much do you earn?"
          end
          within('.answer') { assert_page_has_content "£5,000 per month" }
          within('.undo') { assert page.has_link?("Change this answer", :href => "/money-and-salary-sample/y/?previous_response=5000.0-month") }
        end
        within 'ol li.done:nth-child(2)' do
          within 'h3' do
            within('.question-number') { assert_page_has_content "2" }
            assert_page_has_content "What size bonus do you want?"
          end
          within('.answer') { assert_page_has_content "£1,000,000" }
          within('.undo') { assert page.has_link?("Change this answer", :href => "/money-and-salary-sample/y/5000.0-month?previous_response=1000000.0") }
        end
      end

      within '.outcome' do
        within '.result-info' do
          within('h2.result-title') { assert_page_has_content "OK, here you go." }
          within('.info-notice') { assert_page_has_content "This is allowed because £1,000,000 is more than your annual salary of £60,000" }
        end
      end
    end
  end # with_and_without_javascript
end
