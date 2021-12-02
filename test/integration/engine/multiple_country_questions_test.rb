require_relative "engine_test_helper"

class MultipleCountryQuestionsTest < EngineIntegrationTest
  without_javascript do
    should "validate input and display errors" do
      @countries = %w[angola denmark iceland portugal]
      stub_worldwide_api_has_locations(@countries)
      stub_content_store_has_item("/multiple-country-sample")

      visit "/multiple-country-sample/y"

      assert page.has_field?("response[0]")
      assert page.has_field?("response[1]")

      fill_in "response[0]", with: "Angola"
      fill_in "response[1]", with: "Denmark"

      click_on "Continue"

      assert_current_url "/multiple-country-sample/y/Angola%7CDenmark"
    end
  end
end
