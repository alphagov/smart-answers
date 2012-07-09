# encoding: UTF-8
require_relative '../../integration_test_helper'

class InputValidationTest < ActionDispatch::IntegrationTest
  setup do
    fixture_flows_path = Rails.root.join(*%w{test fixtures flows})
    FLOW_REGISTRY_OPTIONS[:load_path] = fixture_flows_path
  end

  teardown do
    FLOW_REGISTRY_OPTIONS.delete(:load_path)
  end

  %w(non_javascript javascript).each do |test_type|
    should "validate input and display errors (#{test_type})" do
      if test_type == 'javascript'
        Capybara.current_driver = Capybara.javascript_driver
      end

      visit "/money-and-salary-sample/y"

      fill_in "£", :with => "-123"
      click_on "Next step"

      within '.current-question' do
        assert_page_has_content "How much do you earn?"
        within('.error') { assert_page_has_content "Please answer this question" }
        assert page.has_field?("£", :type => :text, :with => "-123")
      end

      fill_in "£", :with => "4000"
      select "month", :from => "per"
      click_on "Next step"

      assert_current_url "/money-and-salary-sample/y/4000.0-month"

      fill_in "£", :with => "asdfasdf"
      click_on "Next step"

      within '.current-question' do
        assert_page_has_content "What size bonus do you want?"
        within('.error') { assert_page_has_content "Sorry, I couldn't understand that number. Please try again." }
        assert page.has_field?("£", :type => :text, :with => "asdfasdf")
      end

      fill_in "£", :with => "50000"
      click_on "Next step"

      assert_current_url "/money-and-salary-sample/y/4000.0-month/50000.0"
    end
  end # each test type
end
