# encoding: UTF-8
require_relative '../integration_test_helper'
require_relative 'maternity_answer_logic'
require_relative 'smart_answer_test_helper'

class HolidayPayTest < ActionDispatch::IntegrationTest
  test "Answering all questions and clicking calculate gives result" do       
    visit "/calculate-your-annual-leave"
    choose "A full year"                                                      
    choose "Daily"
    select "5", from: "days a week"
    select "1", from: "start_date__3i"
    select "February", from: "start_date__2i"
    click_button "Calculate"
    wait_until { page.has_content? "28.0 days" }
  end

  test "Entering details for part of a year gives correct result" do       
    visit "/calculate-your-annual-leave"
    choose "Part of a year"
    select "leaving", from: "someone is"
    select "5", from: "leave_join_date__3i"
    select "July", from: "leave_join_date__2i"
    select "2014", from: "leave_join_date__1i" 
                                                         
    choose "Daily"
    select "5", from: "days a week"

    select "1", from: "start_date__3i"
    select "February", from: "start_date__2i"
    
    click_button "Calculate"               
    wait_until { page.has_content? "11.8 days" }
  end

  test "The calculator remembers the values entered by the user on submit" do
    visit "/calculate-your-annual-leave"
    
    choose "Part of a year"
    select "leaving", from: "someone is"
    select "5", from: "leave_join_date__3i"
    select "July", from: "leave_join_date__2i"
    select "2014", from: "leave_join_date__1i"
    choose "Hourly"
    fill_in "hours a week", with: "25"
    select "3", from: "days_per_week"
    select "12", from: "start_date__3i"
    select "November", from: "start_date__2i"
    click_button "Calculate"

    wait_until {
      has_content? "Calculator"
    }

    assert has_checked_field? "Part of a year"
    assert has_select? "someone is", selected: "leaving"

    assert has_select? "leave_join_date__3i", selected: "5"
    assert has_select? "leave_join_date__2i", selected: "July"
    assert has_select? "leave_join_date__1i", selected: "2014"

    assert has_checked_field? "Hourly" 
    assert has_field? "hours a week", with: "25"
    assert has_select? "days_per_week", selected: "3"

    assert has_select? "start_date__3i", selected: "12"
    assert has_select? "start_date__2i", selected: "November"
  end    
end
