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
	  			assert_current_node :maternity_leave_details
	  		end
  		end
	  end
  end
end