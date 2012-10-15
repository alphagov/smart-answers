# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class PlanPaternityLeaveTest < ActiveSupport::TestCase
  include FlowTestHelper

  context "test baby due in 3 months and leave 2 weeks before" do
  	setup do
	    setup_for_testing_flow 'plan-paternity-leave'
	  end

  	should "start on the baby_due_date? question" do
  		assert_current_node :baby_due_date?
  	end

  	should "no error on over 9 months" do
  		add_response 1.years.since
  		assert_current_node :leave_duration?
    end

    should "no error on due_date before today" do
      add_response 3.months.ago
      assert_current_node :leave_duration?
  	end

    context "set 3 months to baby_due_date" do
  		setup do
		  	@due_date = 3.months.since
        add_response @due_date
		  end
  		
      should "be on leave_duration?" do
        assert_current_node :leave_duration?
      end


      context "set one week leave" do
        setup do
          add_response :one_week
        end
        
        should "be on leave_start?" do
          assert_current_node :leave_start?
          assert_state_variable "leave_duration", 1
          # FIXME:
	  #assert_state_variable "potential_leave", "11 January 2013 to 01 March 2013"
        end
        should "succeed on 7 weeks" do
          add_response 7.weeks.since(@due_date)
          assert_current_node :paternity_leave_details 
        end

        should "fail on 7 weeks and 1 day" do
          add_response 1.day.since(7.weeks.since(@due_date))
          assert_current_node_is_error
        end

        should "fail on 8 weeks after due_date" do
          add_response 8.weeks.since(@due_date)
          assert_current_node_is_error
        end
      end

      context "set two weeks leave" do
        setup do
          add_response :two_weeks
        end

        should "be on leave_start?" do
          assert_current_node :leave_start?
        end
        
        should "fail on before due_date" do
          add_response 2.days.ago(@due_date)
          assert_current_node_is_error
        end

        should "fail on 7 weeks" do
          add_response 7.weeks.since(@due_date)
          assert_current_node_is_error
        end

        should "fail on 6 weeks and 1 day" do
          add_response 1.day.since(6.weeks.since(@due_date))
          assert_current_node_is_error
        end

        should "succeed on 6 weeks" do
          add_response 6.weeks.since(@due_date)
          assert_current_node :paternity_leave_details
        end

  	  	context "set 2 weeks to leave_start?" do
  	  		setup {add_response 2.weeks.since(@due_date)}
  	  		should "go to outcome" do
  	  			assert_current_node :paternity_leave_details
  	  		end
    		end
      end
	  end
  end
end
