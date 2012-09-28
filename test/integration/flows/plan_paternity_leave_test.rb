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

  	should "error on over 9 months" do
  		add_response 1.years.since
  		assert_current_node_is_error
  	end

  	should "error on due_date before today" do
  		add_response 3.months.ago
  		assert_current_node_is_error
  	end

  	context "set 3 months to baby_due_date" do
  		setup do
		  	add_response 3.months.since
		  end
  		
  		should "be on leave_start?" do
	  		assert_current_node :leave_start?
	  	end

	  	context "set 2 weeks to leave_start?" do
	  		setup {add_response :weeks_2}
	  		should "go to outcome" do
	  			assert_current_node :paternity_leave_details
	  		end
  		end
	  end
  end
end