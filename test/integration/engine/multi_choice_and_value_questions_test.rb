# encoding: UTF-8
require_relative 'engine_test_helper'

class MultiChoiceAndValudQuestionsTest < EngineIntegrationTest

  with_and_without_javascript do
    should "handle multiple-choice and value questions" do
      visit "/bridge-of-death"

      assert_current_url "/bridge-of-death"

      assert page.has_xpath?("//meta[@name = 'description'][@content = 'The Gorge of Eternal Peril!!!']", visible: :all)
      assert page.has_no_xpath?("//meta[@name = 'robots'][@content = 'noindex']", visible: :all)

      within 'h1' do
        assert_page_has_content("The Bridge of Death")
      end
      within '.intro' do
        within('h2') { assert_page_has_content("STOP!") }
        assert_page_has_content("He who would cross the Bridge of Death Must answer me These questions three Ere the other side he see.")

        assert page.has_no_content?("-----") # markdown should be rendered, not output

        assert page.has_link?("Start now", href: "/bridge-of-death/y")
      end

      click_on "Start now"

      assert_current_url "/bridge-of-death/y"

      # This is asserting that the form URL doesn't get created with a trailing /
      # If this happens, the cache servers strip off the / and redirect.  This breaks things.
      form = page.find(:xpath, "id('js-replaceable')//form")
      assert_equal "/bridge-of-death/y", form[:action]

      assert page.has_xpath?("//meta[@name = 'robots'][@content = 'noindex']", visible: :all)

      within '.current-question' do
        within 'h2' do
          assert_page_has_content "What...is your name?"
        end
        within '.question-body' do
          assert page.has_field?("Name:", type: "text")
        end
      end

      fill_in "Name:", with: "Lancelot"
      click_on "Next step"

      assert_current_url "/bridge-of-death/y/Lancelot"

      within '.done-questions' do
        assert page.has_link?("Start again", href: '/bridge-of-death')
        within 'tr.section' do
          within 'td.previous-question-title' do
            assert_page_has_content "What...is your name?"
          end
          within('td.previous-question-body') { assert_page_has_content "Lancelot" }
          within('.link-right') { assert page.has_link?("Change", href: "/bridge-of-death/y?previous_response=Lancelot") }
        end
      end

      within '.current-question' do
        within 'h2' do
          assert_page_has_content "What...is your quest?"
        end
        within '.question-body' do
          assert page.has_field?("To seek the Holy Grail", type: 'radio', with: "to_seek_the_holy_grail")
          assert page.has_field?("To rescue the princess", type: 'radio', with: "to_rescue_the_princess")
          assert page.has_field?("I dunno", type: 'radio', with: "dunno")
          # Assert they're in the correct order
          options = page.all(:xpath, ".//label").map(&:text).map(&:strip)
          assert_equal ["To seek the Holy Grail", "To rescue the princess", "I dunno"], options
        end
      end

      choose "To seek the Holy Grail"
      click_on "Next step"

      assert_current_url "/bridge-of-death/y/Lancelot/to_seek_the_holy_grail"

      within '.done-questions' do
        assert page.has_link?("Start again", href: '/bridge-of-death')
        within 'tr.section:nth-child(1)' do
          within 'td.previous-question-title' do
            assert_page_has_content "What...is your name?"
          end
          within('td.previous-question-body') { assert_page_has_content "Lancelot" }
          within('.link-right') { assert page.has_link?("Change", href: "/bridge-of-death/y?previous_response=Lancelot") }
        end
        within 'tr.section:nth-child(2)' do
          within 'td.previous-question-title' do
            assert_page_has_content "What...is your quest?"
          end
          within('td.previous-question-body') { assert_page_has_content "To seek the Holy Grail" }
          within('.link-right') { assert page.has_link?("Change", href: "/bridge-of-death/y/Lancelot?previous_response=to_seek_the_holy_grail") }
        end
      end

      within '.current-question' do
        within 'h2' do
          assert_page_has_content "What...is your favorite colour?"
        end
        within '.question-body' do
          assert page.has_field?("Blue", type: 'radio', with: "blue")
          assert page.has_field?("Blue... NO! YELLOOOOOOOOOOOOOOOOWWW!!!!", type: 'radio', with: "blue_no_yellow")
          assert page.has_field?("Red", type: 'radio', with: "red")
          # Assert they're in the correct order
          options = page.all(:xpath, ".//label").map(&:text).map(&:strip)
          assert_equal ["Blue", "Blue... NO! YELLOOOOOOOOOOOOOOOOWWW!!!!", "Red"], options
        end
      end

      choose "Blue"
      click_on "Next step"

      assert_current_url "/bridge-of-death/y/Lancelot/to_seek_the_holy_grail/blue"

      within '.done-questions' do
        assert page.has_link?("Start again", href: '/bridge-of-death')
        within 'tr.section:nth-child(1)' do
          within 'td.previous-question-title' do
            assert_page_has_content "What...is your name?"
          end
          within('td.previous-question-body') { assert_page_has_content "Lancelot" }
          within('.link-right') { assert page.has_link?("Change", href: "/bridge-of-death/y?previous_response=Lancelot") }
        end
        within 'tr.section:nth-child(2)' do
          within 'td.previous-question-title' do
            assert_page_has_content "What...is your quest?"
          end
          within('td.previous-question-body') { assert_page_has_content "To seek the Holy Grail" }
          within('.link-right') { assert page.has_link?("Change", href: "/bridge-of-death/y/Lancelot?previous_response=to_seek_the_holy_grail") }
        end
        within 'tr.section:nth-child(3)' do
          within 'td.previous-question-title' do
            assert_page_has_content "What...is your favorite colour?"
          end
          within('td.previous-question-body') { assert_page_has_content "Blue" }
          within('.link-right') { assert page.has_link?("Change", href: "/bridge-of-death/y/Lancelot/to_seek_the_holy_grail?previous_response=blue") }
        end
      end

      within '.outcome:nth-child(1)' do
        within '.result-info' do
          within('h2.result-title') { assert_page_has_content "Right, off you go." }
          assert_page_has_content "Oh! Well, thank you. Thank you very much."
        end
      end
    end
  end # with_and_without_javascript

  should "calculate alternate path correctly" do
    visit "/bridge-of-death/y"

    fill_in "Name:", with: "Robin"
    click_on "Next step"

    choose "To seek the Holy Grail"
    click_on "Next step"

    assert_current_url "/bridge-of-death/y/Robin/to_seek_the_holy_grail"

    within '.done-questions' do
      assert page.has_link?("Start again", href: '/bridge-of-death')
      within 'tr.section:nth-child(1)' do
        within 'td.previous-question-title' do
          assert_page_has_content "What...is your name?"
        end
        within('td.previous-question-body') { assert_page_has_content "Robin" }
        within('.link-right') { assert page.has_link?("Change", href: "/bridge-of-death/y?previous_response=Robin") }
      end
      within 'tr.section:nth-child(2)' do
        within 'td.previous-question-title' do
          assert_page_has_content "What...is your quest?"
        end
        within('td.previous-question-body') { assert_page_has_content "To seek the Holy Grail" }
        within('.link-right') { assert page.has_link?("Change", href: "/bridge-of-death/y/Robin?previous_response=to_seek_the_holy_grail") }
      end
    end

    within '.current-question' do
      within 'h2' do
        assert_page_has_content "What...is the capital of Assyria?"
      end
      within '.question-body' do
        assert page.has_field?("Answer:", type: "text")
      end
    end

    fill_in "Answer:", with: "I don't know THAT"
    click_on "Next step"

    within '.outcome:nth-child(1)' do
      within '.result-info' do
        within('h2.result-title') { assert_page_has_content "AAAAARRRRRRRRRRRRRRRRGGGGGHHH!!!!!!!" }
        within('.info-notice') { assert_page_has_content "Robin is thrown into the Gorge of Eternal Peril" }
      end
    end
  end
end
