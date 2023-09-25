require_relative "engine_test_helper"

class RegisterADeathRedirectTest < EngineIntegrationTest
  should "redirect" do
    stub_content_store_has_item("/register-a-death")

    visit "/register-a-death/y/overseas/afghanistan/another_country/algeria"

    assert_current_url "/register-a-death/y/overseas"
  end
end
