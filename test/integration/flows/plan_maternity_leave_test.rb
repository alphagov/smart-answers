# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class PlanMaternityLeaveTest < ActiveSupport::TestCase
  include FlowTestHelper

  context "test baby due in 3 months and leave 2 weeks before" do
  	setup do
	    setup_for_testing_flow 'plan-maternity-leave'
	  end

  	should "start on the baby_due_date? question" do
  		assert_current_node :baby_due_date?
  	end

  	should "no error on over 9 months" do
  		add_response 1.years.since
      assert_current_node :leave_start?
    end

    should "no error on due_date before today" do
      add_response 3.months.ago
      assert_current_node :leave_start?
  	end

  	context "set 3 months to baby_due_date" do
  		setup do
		  	add_response 3.months.since
		  end
  		
  		should "be on leave_start?" do
	  		assert_current_node :leave_start?
	  	end

	  	context "test leave_start?" do
        should "2 weeks before due_date go to outcome" do
          add_response 2.weeks.ago(3.months.since)
          assert_current_node :maternity_leave_details
        end

        should "12 weeks before due_date should fail" do 
          add_response 12.weeks.ago(3.months.since)
          assert_current_node_is_error
        end
        should "2 days after due_date should fail" do
          add_response 2.days.since(3.months.since)
          assert_current_node_is_error
        end
        should "fail if leave date is over 11 weeks before due date (leave date week start)" do
          leave_start_date = 11.weeks.ago(3.months.since)
          week_start_for_leave_date = leave_start_date.to_date - leave_start_date.wday
          add_response 1.day.ago(week_start_for_leave_date)
          assert_current_node_is_error
        end
        should "proceed if leave date is under 11 weeks before due date (leave date week start)" do
          leave_start_date = 11.weeks.ago(3.months.since)
          week_start_for_leave_date = leave_start_date - leave_start_date.wday
          add_response week_start_for_leave_date
          assert_current_node :maternity_leave_details     
        end
  		end
    end
  end
end
