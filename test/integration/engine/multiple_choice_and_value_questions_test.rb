require_relative "engine_test_helper"

class MultipleChoiceAndValueQuestionsTest < EngineIntegrationTest
  with_and_without_javascript do
    setup do
      stub_smart_answer_in_content_store("bridge-of-death")
    end

    should "handle multiple-choice and value questions" do
      visit "/bridge-of-death"

      assert_current_url "/bridge-of-death"

      assert page.has_xpath?("//meta[@name = 'description'][@content = 'The Gorge of Eternal Peril!!!']", visible: :all)
      assert page.has_no_xpath?("//meta[@name = 'robots'][@content = 'noindex']", visible: :all)

      within "h1" do
        assert_page_has_content("The Bridge of Death")
      end
      within ".intro" do
        within("h2") { assert_page_has_content("STOP!") }
        assert_page_has_content("He who would cross the Bridge of Death Must answer me These questions three Ere the other side he see.")

        assert page.has_no_content?("-----") # markdown should be rendered, not output

        assert page.has_link?("Start now", href: "/bridge-of-death/y")
      end

      click_on "Start now"

      assert_current_url "/bridge-of-death/y"

      # This is asserting that the form URL doesn't get created with a trailing /
      # If this happens, the cache servers strip off the / and redirect.  This breaks things.
      form = page.find(:xpath, "id('content')//form")
      assert_same_url "/bridge-of-death/y", form[:action]

      assert page.has_xpath?("//meta[@name = 'robots'][@content = 'noindex']", visible: :all)

      within "#current-question" do
        within ".govuk-label" do
          assert_page_has_content "What...is your name?"
        end

        assert page.has_field?("response", type: "text")
      end

      fill_in "response", with: "Lancelot"
      click_on "Next step"

      assert_current_url "/bridge-of-death/y/Lancelot"

      within ".govuk-table" do
        assert page.has_link?("Start again", href: "/bridge-of-death")
        within "tbody tr.govuk-table__row" do
          within ".govuk-table__cell:nth-child(1)" do
            assert_page_has_content "What...is your name?"
          end
          within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "Lancelot" }
          within(".govuk-table__cell:nth-child(3)") { assert page.has_link?("Change", href: "/bridge-of-death/y?previous_response=Lancelot") }
        end
      end

      within "#current-question" do
        within ".govuk-fieldset__legend" do
          assert_page_has_content "What...is your quest?"
        end

        assert page.has_field?("To seek the Holy Grail", type: "radio", with: "to_seek_the_holy_grail", visible: false)
        assert page.has_field?("To rescue the princess", type: "radio", with: "to_rescue_the_princess", visible: false)
        assert page.has_field?("I dunno", type: "radio", with: "dunno", visible: false)
        # Assert they're in the correct order
        options = page.all(:xpath, ".//label").map(&:text).map(&:strip)
        assert_equal ["To seek the Holy Grail", "To rescue the princess", "I dunno"], options
      end

      choose("To seek the Holy Grail", visible: false)
      click_on "Next step"

      assert_current_url "/bridge-of-death/y/Lancelot/to_seek_the_holy_grail"

      within ".govuk-table" do
        assert page.has_link?("Start again", href: "/bridge-of-death")
        within "tbody tr.govuk-table__row:nth-child(1)" do
          within ".govuk-table__cell:nth-child(1)" do
            assert_page_has_content "What...is your name?"
          end
          within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "Lancelot" }
          within(".govuk-table__cell:nth-child(3)") { assert page.has_link?("Change", href: "/bridge-of-death/y?previous_response=Lancelot") }
        end
        within "tbody tr.govuk-table__row:nth-child(2)" do
          within ".govuk-table__cell:nth-child(1)" do
            assert_page_has_content "What...is your quest?"
          end
          within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "To seek the Holy Grail" }
          within(".govuk-table__cell:nth-child(3)") { assert page.has_link?("Change", href: "/bridge-of-death/y/Lancelot?previous_response=to_seek_the_holy_grail") }
        end
      end

      within "#current-question" do
        within ".govuk-fieldset__legend" do
          assert_page_has_content "What...is your favorite colour?"
        end

        assert page.has_field?("Blue", type: "radio", with: "blue", visible: false)
        assert page.has_field?("Blue... NO! YELLOOOOOOOOOOOOOOOOWWW!!!!", type: "radio", with: "blue_no_yellow", visible: false)
        assert page.has_field?("Red", type: "radio", with: "red", visible: false)
        # Assert they're in the correct order
        options = page.all(:xpath, ".//label").map(&:text).map(&:strip)
        assert_equal ["Blue", "Blue... NO! YELLOOOOOOOOOOOOOOOOWWW!!!!", "Red"], options
      end

      choose("Blue", visible: false)
      click_on "Next step"

      assert_current_url "/bridge-of-death/y/Lancelot/to_seek_the_holy_grail/blue"

      within ".govuk-table" do
        assert page.has_link?("Start again", href: "/bridge-of-death")
        within "tbody tr.govuk-table__row:nth-child(1)" do
          within ".govuk-table__cell:nth-child(1)" do
            assert_page_has_content "What...is your name?"
          end
          within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "Lancelot" }
          within(".govuk-table__cell:nth-child(3)") { assert page.has_link?("Change", href: "/bridge-of-death/y?previous_response=Lancelot") }
        end
        within "tbody tr.govuk-table__row:nth-child(2)" do
          within ".govuk-table__cell:nth-child(1)" do
            assert_page_has_content "What...is your quest?"
          end
          within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "To seek the Holy Grail" }
          within(".govuk-table__cell:nth-child(3)") { assert page.has_link?("Change", href: "/bridge-of-death/y/Lancelot?previous_response=to_seek_the_holy_grail") }
        end
        within "tbody tr.govuk-table__row:nth-child(3)" do
          within ".govuk-table__cell:nth-child(1)" do
            assert_page_has_content "What...is your favorite colour?"
          end
          within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "Blue" }
          within(".govuk-table__cell:nth-child(3)") { assert page.has_link?("Change", href: "/bridge-of-death/y/Lancelot/to_seek_the_holy_grail?previous_response=blue") }
        end
      end

      within "#result-info" do
        within("h2.gem-c-heading") { assert_page_has_content "Right, off you go." }
        assert_page_has_content "Oh! Well, thank you. Thank you very much."
      end
    end
  end # with_and_without_javascript

  should "calculate alternate path correctly" do
    visit "/bridge-of-death/y"

    fill_in "response", with: "Robin"
    click_on "Next step"

    choose("To seek the Holy Grail", visible: false)
    click_on "Next step"

    assert_current_url "/bridge-of-death/y/Robin/to_seek_the_holy_grail"

    within ".govuk-table" do
      assert page.has_link?("Start again", href: "/bridge-of-death")
      within "tbody tr.govuk-table__row:nth-child(1)" do
        within ".govuk-table__cell:nth-child(1)" do
          assert_page_has_content "What...is your name?"
        end
        within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "Robin" }
        within(".govuk-table__cell:nth-child(3)") { assert page.has_link?("Change", href: "/bridge-of-death/y?previous_response=Robin") }
      end
      within "tbody tr.govuk-table__row:nth-child(2)" do
        within ".govuk-table__cell:nth-child(1)" do
          assert_page_has_content "What...is your quest?"
        end
        within(".govuk-table__cell:nth-child(2)") { assert_page_has_content "To seek the Holy Grail" }
        within(".govuk-table__cell:nth-child(3)") { assert page.has_link?("Change", href: "/bridge-of-death/y/Robin?previous_response=to_seek_the_holy_grail") }
      end
    end

    within "#current-question" do
      within ".govuk-label" do
        assert_page_has_content "What...is the capital of Assyria?"
      end

      assert page.has_field?("response", type: "text")
    end

    fill_in "response", with: "I don't know THAT"
    click_on "Next step"

    within "#result-info" do
      within("h2.gem-c-heading") { assert_page_has_content "AAAAARRRRRRRRRRRRRRRRGGGGGHHH!!!!!!!" }
      within(".info-notice") { assert_page_has_content "Robin is thrown into the Gorge of Eternal Peril" }
    end
  end
end
