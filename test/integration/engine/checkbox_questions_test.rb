require_relative 'engine_test_helper'

class CheckboxQuestionsTest < EngineIntegrationTest
  setup do
    stub_smart_answer_in_content_store("checkbox-sample")
  end

  with_and_without_javascript do
    should "handle checkbox questions" do
      visit "/checkbox-sample/y"

      within '.current-question' do
        within '[data-test=question]' do
          assert_page_has_content "What do you want on your pizza?"
        end
        within '.question-body' do
          assert page.has_field?("Ham", type: 'checkbox', with: "ham")
          assert page.has_field?("Peppers", type: 'checkbox', with: "peppers")
          assert page.has_field?("Ice Cream!!!", type: 'checkbox', with: "ice_cream")
          assert page.has_field?("Pepperoni", type: 'checkbox', with: "pepperoni")
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
        assert page.has_link?("Start again", href: '/checkbox-sample')
        within 'tr.section' do
          within 'td.previous-question-title' do
            assert_page_has_content "What do you want on your pizza?"
          end
          within 'td.previous-question-body' do
            assert_equal %w(Ham Pepperoni), page.all("li").map(&:text)
          end
          within('.link-right') { assert page.has_link?("Change", href: "/checkbox-sample/y?previous_response=ham%2Cpepperoni") }
        end
      end

      within '.outcome:nth-child(1)' do
        assert_page_has_content "Ok, your pizza is on its way"
        assert_page_has_content "You chose to have ham,pepperoni on your pizza."
      end
    end

    should "allow selecting no options from a checkbox question" do
      visit "/checkbox-sample/y"

      click_on "Next step"

      assert_current_url "/checkbox-sample/y/none"

      within '.done-questions' do
        assert page.has_link?("Start again", href: '/checkbox-sample')
        within 'tr.section' do
          within 'td.previous-question-title' do
            assert_page_has_content "What do you want on your pizza?"
          end
          within('td.previous-question-body') { assert_page_has_content "none" }
          within('.link-right') { assert page.has_link?("Change", href: "/checkbox-sample/y?previous_response=none") }
        end
      end

      within('.question') do
        assert_page_has_content "Are you sure you don't want any toppings?"
      end

      check "Definitely no toppings"

      click_on "Next step"

      assert_current_url "/checkbox-sample/y/none/none"

      within '.outcome:nth-child(1)' do
        assert_page_has_content "Ok, your margherita pizza is on its way"
      end
    end

    should "expect explicit selection of 'none' option when present" do
      visit "/checkbox-sample/y/none"

      within('.question') do
        assert_page_has_content "Are you sure you don't want any toppings?"
      end

      click_on "Next step"

      assert_equal current_path, "/checkbox-sample/y/none"

      within(".error-message") do
        assert_page_has_content "Please answer this question"
      end
    end
  end # with_and_without_javascript

  with_javascript do
    should "toggle options when none option is present" do
      visit "/checkbox-sample/y/none"

      check "Definitely no toppings"
      check "Hmm I'm not sure, ask me again please"
      refute page.has_checked_field?("Definitely no toppings")

      check "Definitely no toppings"
      refute page.has_checked_field?("Hmm I'm not sure, ask me again please")
      click_on "Next step"

      assert_current_url "/checkbox-sample/y/none/none"
    end
  end

  should "calculate next_node correctly" do
    visit "/checkbox-sample/y"

    check "Ham"
    check "Ice Cream!!!"
    click_on "Next step"

    assert_current_url "/checkbox-sample/y/ham,ice_cream"
    within '.outcome:nth-child(1)' do
      assert_page_has_content "No way. That's disgusting!"
    end
  end
end
