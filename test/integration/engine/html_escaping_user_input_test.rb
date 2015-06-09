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
      assert page.has_css?("h2", text: "Outcome with template"), "Not on outcome page"
      including_hidden_elements do
        refute page.has_css?("script#naughty", text: @javascript), "Includes unsafe HTML"
      end
    end
  end

  private

  def including_hidden_elements
    original_value = Capybara.ignore_hidden_elements
    Capybara.ignore_hidden_elements = false
    yield if block_given?
    Capybara.ignore_hidden_elements = original_value
  end
end
