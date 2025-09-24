require_relative "engine_test_helper"

class RadioAndValueQuestionsTest < EngineIntegrationTest
  with_and_without_javascript do
    setup do
      stub_content_store_has_item("/bridge-of-death")
    end

    should "handle radio and value questions" do
      visit "/bridge-of-death"

      find "h1", text: "The Bridge of Death"
      assert_current_url "/bridge-of-death"

      assert page.has_xpath?("//meta[@name = 'description'][@content = 'The Gorge of Eternal Peril!!!']", visible: :all)
      assert page.has_no_xpath?("//meta[@name = 'robots'][@content = 'noindex']", visible: :all)

      within "h1" do
        assert_page_has_content("The Bridge of Death")
      end

      within "article" do
        within("h2") { assert_page_has_content("STOP!") }
        assert_page_has_content("He who would cross the Bridge of Death Must answer me These questions three Ere the other side he see.")
        assert page.has_no_content?("-----") # markdown should be rendered, not output
        assert page.has_link?("Start now", href: "/bridge-of-death/y")
      end

      click_on "Start now"

      find "h1", text: "What...is your name?"
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
      click_on "Continue"

      find "h1", text: "What...is your quest?"
      assert_current_url "/bridge-of-death/y/Lancelot"

      assert page.has_link?("Start again", href: "/bridge-of-death")
      within ".govuk-summary-list__row" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "What...is your name?"
        end
        within(".govuk-summary-list__value") { assert_page_has_content "Lancelot" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/bridge-of-death/y?previous_response=Lancelot") }
      end

      within "#current-question" do
        within ".govuk-fieldset__legend" do
          assert_page_has_content "What...is your quest?"
        end

        assert page.has_field?("To seek the Holy Grail", type: "radio", with: "to_seek_the_holy_grail", visible: false)
        assert page.has_content?("This is dangerous")
        assert page.has_field?("To rescue the princess", type: "radio", with: "to_rescue_the_princess", visible: false)
        assert page.has_field?("I dunno", type: "radio", with: "dunno", visible: false)
        # Assert they're in the correct order
        options = page.all(:xpath, ".//label").map(&:text).map(&:strip)
        assert_equal ["To seek the Holy Grail", "To rescue the princess", "I dunno"], options
      end

      choose("To seek the Holy Grail", visible: false, allow_label_click: true)
      click_on "Continue"

      find "h1", text: "Colour options"
      assert_current_url "/bridge-of-death/y/Lancelot/to_seek_the_holy_grail"

      assert page.has_link?("Start again", href: "/bridge-of-death")
      within ".govuk-summary-list__row:nth-child(1)" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "What...is your name?"
        end
        within(".govuk-summary-list__value") { assert_page_has_content "Lancelot" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/bridge-of-death/y?previous_response=Lancelot") }
      end
      within ".govuk-summary-list__row:nth-child(2)" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "What...is your quest?"
        end
        within(".govuk-summary-list__value") { assert_page_has_content "To seek the Holy Grail" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/bridge-of-death/y/Lancelot?previous_response=to_seek_the_holy_grail") }
      end

      within "#current-question" do
        within("h1.govuk-heading-l") { assert_page_has_content "Colour options" }
        assert_page_has_content "Colours include"

        within ".govuk-fieldset__legend" do
          assert_page_has_content "Do you want to select any of these?"
        end

        assert page.has_field?("Yes", type: "radio", with: "yes", visible: false)
        assert page.has_field?("No", type: "radio", with: "no", visible: false)
        # Assert they're in the correct order
        options = page.all(:xpath, ".//label").map(&:text).map(&:strip)
        assert_equal %w[Yes No], options
      end

      choose("Yes", visible: false, allow_label_click: true)
      click_on "Continue"

      find "h1", text: "What...is your favorite colour?"
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

      choose("Blue", visible: false, allow_label_click: true)
      click_on "Continue"

      find "h1", text: "Information based on your answers"
      assert_current_url "/bridge-of-death/y/Lancelot/to_seek_the_holy_grail/yes/blue"

      assert page.has_link?("Start again", href: "/bridge-of-death")
      within ".govuk-summary-list__row:nth-child(1)" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "What...is your name?"
        end
        within(".govuk-summary-list__value") { assert_page_has_content "Lancelot" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/bridge-of-death/y?previous_response=Lancelot") }
      end
      within ".govuk-summary-list__row:nth-child(2)" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "What...is your quest?"
        end
        within(".govuk-summary-list__value") { assert_page_has_content "To seek the Holy Grail" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/bridge-of-death/y/Lancelot?previous_response=to_seek_the_holy_grail") }
      end
      within ".govuk-summary-list__row:nth-child(3)" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "Colour options"
        end
        within(".govuk-summary-list__value") { assert_page_has_content "Yes" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/bridge-of-death/y/Lancelot/to_seek_the_holy_grail?previous_response=yes") }
      end
      within ".govuk-summary-list__row:nth-child(4)" do
        within ".govuk-summary-list__key" do
          assert_page_has_content "What...is your favorite colour?"
        end
        within(".govuk-summary-list__value") { assert_page_has_content "Blue" }
        within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/bridge-of-death/y/Lancelot/to_seek_the_holy_grail/yes?previous_response=blue") }
      end

      within "#result-info" do
        within page.find(".gem-c-heading h2", match: :first) { assert_page_has_content "Right, off you go." }
        assert_page_has_content "Oh! Well, thank you. Thank you very much."
      end
    end
  end # with_and_without_javascript

  should "calculate alternate path correctly" do
    visit "/bridge-of-death/y"

    find "h1", text: "What...is your name?"
    fill_in "response", with: "Robin"
    click_on "Continue"

    find "h1", text: "What...is your quest?"
    choose("To seek the Holy Grail", visible: false)
    click_on "Continue"

    find "h1", text: "What...is the capital of Assyria?"
    assert_current_url "/bridge-of-death/y/Robin/to_seek_the_holy_grail"

    assert page.has_link?("Start again", href: "/bridge-of-death")
    within ".govuk-summary-list__row:nth-child(1)" do
      within ".govuk-summary-list__key" do
        assert_page_has_content "What...is your name?"
      end
      within(".govuk-summary-list__value") { assert_page_has_content "Robin" }
      within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/bridge-of-death/y?previous_response=Robin") }
    end
    within ".govuk-summary-list__row:nth-child(2)" do
      within ".govuk-summary-list__key" do
        assert_page_has_content "What...is your quest?"
      end
      within(".govuk-summary-list__value") { assert_page_has_content "To seek the Holy Grail" }
      within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/bridge-of-death/y/Robin?previous_response=to_seek_the_holy_grail") }
    end

    within "#current-question" do
      within ".govuk-label" do
        assert_page_has_content "What...is the capital of Assyria?"
      end

      assert page.has_field?("response", type: "text")
    end

    fill_in "response", with: "I don't know THAT"
    click_on "Continue"

    find "h1", text: "The Bridge of Death: Information based on your answers", normalize_ws: true
    within "#result-info" do
      within page.find(".gem-c-heading h2", match: :first) { assert_page_has_content "AAAAARRRRRRRRRRRRRRRRGGGGGHHH!!!!!!!" }
      within(".info-notice") { assert_page_has_content "Robin is thrown into the Gorge of Eternal Peril" }
    end
  end
end
