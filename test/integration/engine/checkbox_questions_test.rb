require_relative "engine_test_helper"

class CheckboxQuestionsTest < EngineIntegrationTest
  setup do
    stub_content_store_has_item("/checkbox-sample")
  end

  with_and_without_javascript do
    should "handle checkbox questions" do
      visit "/checkbox-sample/y"

      within "#current-question" do
        within ".govuk-fieldset__legend" do
          assert_page_has_content "What do you want on your pizza?"
        end

        assert page.has_field?("Ham", type: "checkbox", with: "ham", visible: false)
        assert page.has_field?("Peppers", type: "checkbox", with: "peppers", visible: false)
        assert page.has_content?("They are spicy")
        assert page.has_field?("Ice Cream!!!", type: "checkbox", with: "ice_cream", visible: false)
        assert page.has_field?("Pepperoni", type: "checkbox", with: "pepperoni", visible: false)
        # Assert they're in the correct order
        options = page.all(:xpath, ".//label").map(&:text).map(&:strip)
        assert_equal ["Ham", "Peppers", "Ice Cream!!!", "Pepperoni"], options
      end

      check("Ham", visible: false)
      check("Pepperoni", visible: false)
      click_on "Continue"

      assert_current_url "/checkbox-sample/y/ham,pepperoni"

      assert page.has_link?("Start again", href: "/checkbox-sample")
      within ".govuk-summary-list__key" do
        assert_page_has_content "What do you want on your pizza?"
      end
      within ".govuk-summary-list__value" do
        assert_equal %w[Ham Pepperoni], page.all("li").map(&:text)
      end
      within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/checkbox-sample/y?previous_response=ham%2Cpepperoni") }

      within ".outcome:nth-child(1)" do
        assert_page_has_content "Ok, your pizza is on its way"
        assert_page_has_content "You chose to have ham,pepperoni on your pizza."
      end
    end

    should "allow selecting no options from a checkbox question" do
      visit "/checkbox-sample/y"

      click_on "Continue"

      assert_current_url "/checkbox-sample/y/none"

      assert page.has_link?("Start again", href: "/checkbox-sample")
      within ".govuk-summary-list__key" do
        assert_page_has_content "What do you want on your pizza?"
      end
      within(".govuk-summary-list__value") { assert_page_has_content "None" }
      within(".govuk-summary-list__actions") { assert page.has_link?("Change", href: "/checkbox-sample/y?previous_response=none") }

      assert_page_has_content "Are you sure you don't want any toppings?"

      check("Definitely no toppings", visible: false)

      click_on "Continue"

      assert_current_url "/checkbox-sample/y/none/none"

      within ".outcome:nth-child(1)" do
        assert_page_has_content "Ok, your margherita pizza is on its way"
      end
    end

    should "expect explicit selection of 'none' option when present" do
      visit "/checkbox-sample/y/none"

      assert_page_has_content "Are you sure you don't want any toppings?"

      click_on "Continue"

      assert_equal current_path, "/checkbox-sample/y/none"

      within(".govuk-error-summary [href]") do
        assert_page_has_content "Please answer this question"
      end

      within(".govuk-error-message") do
        assert_page_has_content "Please answer this question"
      end
    end
  end # with_and_without_javascript

  with_javascript do
    should "toggle options when none option is present" do
      visit "/checkbox-sample/y/none"

      check("Definitely no toppings", visible: false)
      check("Hmm I'm not sure, ask me again please", visible: false)
      assert_not page.has_checked_field?("Definitely no toppings")

      check("Definitely no toppings", visible: false)
      assert_not page.has_checked_field?("Hmm I'm not sure, ask me again please")
      click_on "Continue"

      assert_current_url "/checkbox-sample/y/none/none"
    end
  end

  should "calculate next_node correctly" do
    visit "/checkbox-sample/y"

    check("Ham", visible: false)
    check("Ice Cream!!!", visible: false)
    click_on("Continue", visible: false)

    assert_current_url "/checkbox-sample/y/ham,ice_cream"
    within ".outcome:nth-child(1)" do
      assert_page_has_content "No way. That's disgusting!"
    end
  end
end
