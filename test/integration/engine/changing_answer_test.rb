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

        within ('ol li.done:nth-child(1)') { click_on "Change this answer" }

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

        within ('ol li.done:nth-child(2)') { click_on "Change this answer" }

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

      should "be able to change money and salary answers" do
        visit "/money-and-salary-sample/y"

        fill_in "£", :with => "5000"
        select "month", :from => "per"
        click_on "Next step"

        fill_in "£", :with => "1000000"
        click_on "Next step"

        within ('ol li.done:nth-child(1)') { click_on "Change this answer" }

        within '.current-question .question-body' do
          assert page.has_field? "£", :value => "5000"
          assert page.has_select? "per", :selected => "month"
        end

        fill_in "£", :with => "2000"
        select "week", :from => "per"
        click_on "Next step"

        assert_current_url "/money-and-salary-sample/y/2000.0-week"

        fill_in "£", :with => "2000000"
        click_on "Next step"

        within ('ol li.done:nth-child(2)') { click_on "Change this answer" }

        within ('.current-question .question-body') { assert page.has_field? "£", :value => "2000000" }

        fill_in "£", :with => "3000000"
        click_on "Next step"

        assert_current_url "/money-and-salary-sample/y/2000.0-week/3000000.0"
        end

      should "be able to change value and multiple choice answers" do
        visit "/bridge-of-death/y"

        fill_in "Name:", :with => "Lancelot"
        click_on "Next step"

        choose "To seek the Holy Grail"
        click_on "Next step"

        choose "Blue"
        click_on "Next step"

        within ('ol li.done:nth-child(1)') { click_on "Change this answer" }

        within ('.current-question .question-body') { assert page.has_field? "Name:", :value => "Lancelot" }

        fill_in "Name:", :with => "Bors"
        click_on "Next step"

        assert_current_url "/bridge-of-death/y/Bors"

        choose "To seek the Holy Grail"
        click_on "Next step"

        puts page.current_url

        choose "Blue"
        click_on "Next step"

        within ('ol li.done:nth-child(2)') { click_on "Change this answer" }

        within '.current-question .question-body' do
           assert page.has_checked_field? "To seek the Holy Grail"
           assert page.has_unchecked_field? "To rescue the princess"
           assert page.has_unchecked_field? "I dunno"
        end

        choose "To rescue the princess"
        click_on "Next step"

        assert_current_url "/bridge-of-death/y/Bors/to_rescue_the_princess"

        choose "Blue"
        click_on "Next step"

        within ('ol li.done:nth-child(3)') { click_on "Change this answer" }

        within '.current-question .question-body' do
          assert page.has_checked_field? "Blue"
          assert page.has_unchecked_field? "Blue... NO! YELLOOOOOOOOOOOOOOOOWWW!!!!"
          assert page.has_unchecked_field? "Red"
        end

        choose "Red"
        click_on "Next step"

        assert_current_url "/bridge-of-death/y/Bors/to_rescue_the_princess/red"
      end
    end
  end
end
