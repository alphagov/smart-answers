require "test_helper"
GovukTest.configure

class SessionAnswersTest < ActionDispatch::SystemTestCase
  setup do
    Capybara.current_driver = :headless_chrome
  end

  teardown do
    Capybara.use_default_driver
  end

  test "Change link returns previously visited page" do
    visit "find-coronavirus-support/s"
    within "legend" do
      assert_page_has_content "What do you need help with because of coronavirus?"
    end
    check("None of these", visible: false)
    click_on "Continue"
    within "legend" do
      assert_page_has_content "Where do you want to find information about?"
    end
    click_on "Change"
    within "legend" do
      assert_page_has_content "What do you need help with because of coronavirus?"
    end
  end

  test "Returning to start of flow resets session" do
    visit "find-coronavirus-support/s"
    within "legend" do
      assert_page_has_content "What do you need help with because of coronavirus?"
    end
    check("None of these", visible: false)
    click_on "Continue"
    within "legend" do
      assert_page_has_content "Where do you want to find information about?"
    end
    visit "find-coronavirus-support/s"
    within "legend" do
      assert_page_has_content "What do you need help with because of coronavirus?"
    end
  end

  def assert_page_has_content(text)
    assert page.has_content?(text), "'#{text}' not found in page"
  end
end
