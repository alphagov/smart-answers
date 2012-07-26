# encoding: UTF-8
require_relative 'engine_test_helper'

class CheckboxQuestionsTest < EngineIntegrationTest

  with_and_without_javascript do
    should "handle checkbox questions" do
      visit "/checkbox-sample/y"

      within '.current-question' do
        within 'h2' do
          within('.question-number') { assert_page_has_content "1" }
          assert_page_has_content "What do you want on your pizza?"
        end
        within '.question-body' do
          assert page.has_field?("Ham", :type => 'checkbox', :with => "ham")
          assert page.has_field?("Peppers", :type => 'checkbox', :with => "peppers")
          assert page.has_field?("Ice Cream!!!", :type => 'checkbox', :with => "ice_cream")
          assert page.has_field?("Pepperoni", :type => 'checkbox', :with => "pepperoni")
          # Assert they're in the correct order
          options = page.all(:xpath, ".//label").map(&:text).map(&:strip)
          assert_equal ["Ham", "Peppers", "Ice Cream!!!", "Pepperoni"], options
        end
      end

      check "Ham"
      check "Pepperoni"
      click_on "Next step"

      assert_current_url "/checkbox-sample/y/ham,pepperoni"

      within '.done-questions' do
        within('.start-again') { assert page.has_link?("Start again", :href => '/checkbox-sample') }
        within 'ol li.done' do
          within 'h3' do
            within('.question-number') { assert_page_has_content "1" }
            assert_page_has_content "What do you want on your pizza?"
          end
          within '.answer' do
            assert_equal ['Ham', 'Pepperoni'], page.all("li").map(&:text)
          end
          within('.undo') { assert page.has_link?("Change this answer", :href => "/checkbox-sample/y/?previous_response=ham%2Cpepperoni") }
        end
      end

      within '.outcome' do
        assert_page_has_content "Ok, your pizza is on its way"
        assert_page_has_content "You chose to have ham,pepperoni on your pizza."
      end
    end

    should "allow selecting no options from a checkbox question" do
      visit "/checkbox-sample/y"

      click_on "Next step"

      assert_current_url "/checkbox-sample/y/none"

      within '.done-questions' do
        within('.start-again') { assert page.has_link?("Start again", :href => '/checkbox-sample') }
        within 'ol li.done' do
          within 'h3' do
            within('.question-number') { assert_page_has_content "1" }
            assert_page_has_content "What do you want on your pizza?"
          end
          within('.answer') { assert_page_has_content "none" }
          within('.undo') { assert page.has_link?("Change this answer", :href => "/checkbox-sample/y/?previous_response=none") }
        end
      end

      within '.outcome' do
        assert_page_has_content "Ok, your margherita pizza is on its way"
      end
    end
  end # with_and_without_javascript

  should "calculate next_node correctly" do
    visit "/checkbox-sample/y"

    check "Ham"
    check "Ice Cream!!!"
    click_on "Next step"

    assert_current_url "/checkbox-sample/y/ham,ice_cream"
    within '.outcome' do
      assert_page_has_content "No way. That's disgusting!"
    end
  end
end
