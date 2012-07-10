# encoding: UTF-8
require_relative '../../integration_test_helper'

class HappyPathTest < ActionDispatch::IntegrationTest
  setup do
    fixture_flows_path = Rails.root.join(*%w{test fixtures flows})
    FLOW_REGISTRY_OPTIONS[:load_path] = fixture_flows_path
  end

  teardown do
    FLOW_REGISTRY_OPTIONS.delete(:load_path)
  end

  #%w(non_javascript javascript).each do |test_type|
  %w(non_javascript).each do |test_type|
    context "with javascript #{test_type == 'javascript' ? 'enabled' : 'disabled'}" do
      setup do
        if test_type == 'javascript'
          Capybara.current_driver = Capybara.javascript_driver
        end
      end

      should "be able to change country and date answers" do
        visit "/country-and-date-sample/y"

        select "Belarus", :from => "response"
        click_on "Next step"

        select "5", :from => "Day"
        select "May", :from => "Month"
        select "1975", :from => "Year"
        click_on "Next step"

        within 'ol li.done:nth-child(1)' do
          click_on "Change this answer"
        end

        # TODO: Fix changing answer with country questions
        pending
        within('.current-question .question-body') { assert page.has_select? "response", :selected => "Belarus" }

        select "India", :from => "response"
        click_on "Next step"

        assert_current_url "/country-and-date-sample/y/india"

        select "10", :from => "Day"
        select "June", :from => "Month"
        select "1985", :from => "Year"
        click_on "Next step"

        within 'ol li.done:nth-child(2)' do
          click_on "Change this answer"
        end

        within '.current-question .question-body' do
          assert page.has_select? "Day", :selected => "10"
          assert page_has_select? "Month", :selected => "June"
          assert page_has_select? "Year", :selected => "1985"
        end

        select "15", :from => "Day"
        select "April", :from => "Month"
        select "2000", :from => "Year"
        click_on "Next step"

        assert_current_url "/country-and-date-sample/y/india/2000-15-04"
      end
    end
  end
end
