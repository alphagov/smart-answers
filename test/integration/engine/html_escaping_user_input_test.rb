require_relative 'engine_test_helper'

class HtmlEscapingUserInputTest < EngineIntegrationTest
  setup do
    visit "/value-sample"
    click_on "Start now"
  end

  context "when user input contains unsafe HTML" do
    setup do
      @javascript = "doSomethingNaughty();"
      unsafe_html = "<script id='naughty'>#{@javascript}"
      fill_in "User input", with: unsafe_html
      click_on "Next step"
    end

    should "escape user input interpolated into outcome ERB template" do
      assert page.has_content?('text-before-user-input'), "Not on outcome page"
      assert page.has_content?('text-after-user-input'), "Not on outcome page"
      refute page.has_css?("script#naughty", text: @javascript, visible: false), "Includes unsafe HTML"
    end
  end
end
