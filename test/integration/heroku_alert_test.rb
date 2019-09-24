require_relative "../integration_test_helper"

class HerokuAlertTest < ActionDispatch::IntegrationTest
  should "not generally display the heroku alert" do
    visit "/"
    assert page.has_text? "Smart Answers"
    assert page.has_no_css? ".heroku-alert"
  end

  context "on heroku" do
    setup do
      Capybara.app_host = "http://example.herokuapp.com"
    end

    should "display the heroku alert" do
      visit "/"
      assert page.has_text? "Smart Answers"
      assert page.has_css? ".heroku-alert"
    end

    teardown do
      Capybara.app_host = nil
    end
  end
end
