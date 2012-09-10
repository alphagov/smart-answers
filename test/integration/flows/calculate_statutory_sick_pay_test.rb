# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateStatutorySickPay < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-statutory-sick-pay'
  end

  ## Q1
  # should "ask to select which criteria apply to the employee" do
  # 	assert_current_node :select_employee_criteria?
  # end

  ## Q2
  should "ask when employee became sick"  do
  	assert_current_node :employee_paid_for_last_8_weeks?
  end

  context "answer yes" do
  	setup {add_response :yes}

  	## Q3
  	should "ask if related_illness in the last 8 weeks" do
  		assert_current_node :related_illness?
  	end

  	context "answer yes" do
  		setup {add_response :yes}

  		## Q4
  		should "ask how many days have been missed" do
  			assert_current_node :how_many_days_missed?
  		end

  		context "answered 3 sick days" do
	  		setup {add_response 3}
	  		
	  		## Q7 
	  		should "ask how many days they work" do
	  			assert_state_variable "prev_sick_days", 3
	  			assert_current_node :how_many_days_worked?
	  		end

	  		context "5 days worked" do
		  		setup {add_response 5}

		  		## Q8 
		  		should "ask how may sick days they had" do
		  			assert_state_variable "pattern_days", 5
		  			assert_state_variable "daily_rate", 17.17
		  			assert_current_node :normal_workdays_taken_as_sick?
		  		end

		  		context "4 work days out" do
		  			setup {add_response 4}

		  			should "give entitled outcome" do
			  			assert_state_variable "normal_workdays_out", 4
			  			assert_current_node :entitled
		  			end
		  		end
	  		end
  		end

  	end

		context "answer no" do
	  	setup {add_response :no}

	  	## Q6 
	  	should "ask what the employee's average weekly earnings were" do
	  		assert_current_node :what_was_average_weekly_earnings?
	  	end

	  	context "avg weekly earnings £250.25" do
	  		setup {add_response 250.25}

	  		## Q7 
	  		should "ask how many days they work" do
	  			assert_state_variable "over_eight_awe", 250.25
	  			assert_current_node :how_many_days_worked?
	  		end
	  	end
	  	context "avg weekly earnings £95.22" do
	  		setup {add_response 95.22}

	  		## A5 
	  		should "earnings too low" do
	  			assert_current_node :not_entitled
	  		end
			end
	  end

  end

  context "answer no" do
  	setup {add_response :no}

  	## Q5
  	should "ask what the workers average weekly was when they got sick" do
  		assert_current_node :what_was_average_weekly_pay?
  	end
  	context "avg weekly earnings £250.25" do
  		setup {add_response 250.25}

  		## Q7 
  		should "ask how many days they work" do
  			assert_state_variable "under_eight_awe", 250.25
  			assert_current_node :how_many_days_worked?
  		end
  	end
  end




end