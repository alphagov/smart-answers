require_relative "engine_test_helper"

class CustomButtonTest < EngineIntegrationTest
  setup do
    stub_content_store_has_item("/custom-button")
    visit "/custom-button"
    click_on "Start now"
  end

  should "display custom button text" do
    assert page.has_css?("button.gem-c-button", text: "Continue"), "Button does not have correct text"
  end
end
