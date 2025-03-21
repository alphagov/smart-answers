require_relative "engine_test_helper"

class HtmlEscapingUserInputTest < EngineIntegrationTest
  setup do
    stub_content_store_has_item("/value-sample")
    visit "/value-sample"
    find(:link, text: "Start now").click
  end

  context "when user input contains unsafe HTML" do
    setup do
      @javascript = "doSomethingNaughty();"
      unsafe_html = "<script id='naughty'>#{@javascript}"
      fill_in "User input", with: unsafe_html
      click_on "Continue"
      find "p", text: "text-before-user-input"
    end

    should "escape user input interpolated into outcome ERB template" do
      assert page.has_content?("text-before-user-input"), "Not on outcome page"
      assert page.has_content?("text-after-user-input"), "Not on outcome page"
      assert_not page.has_css?("script#naughty", text: @javascript, visible: false), "Includes unsafe HTML"
    end
  end
end
