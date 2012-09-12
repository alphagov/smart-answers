# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateStatutorySickPay < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-statutory-sick-pay'
  end

  # Q1
  should "ask to select which criteria apply to the employee" do
  	assert_current_node :select_employee_criteria?
  
  end
	context "answered 'none of the above' " do
		setup {add_response :none}
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
		  			assert_current_node :not_earned_enough
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

				context "set normal work days taken as sick to 3" do
					setup {add_response 3}
					
					## Q8 
					should "ask days taken as sick" do
						assert_current_node :normal_workdays_taken_as_sick?
						assert_state_variable "daily_rate", 28.62
					end

					## A6
					should "pass to entitled outcome" do
	  				add_response 3
	  				assert_state_variable "ssp_payment", 0.00
	  				assert_state_variable "normal_workdays_out", 3
	  				assert_current_node :entitled
	  			end
	  		end
	  	end

	  	should "return earnings too low outcome on 90.25" do
	  		add_response 90.25
	  		assert_current_node :not_earned_enough
	  	end
	  end
	end

	should "return already_receiving_benefit on maternity_paternity answer" do
		add_response :maternity_paternity
		assert_current_node :already_receiving_benefit ## A2
	end

	should "return must_be_sick_for_at_least_4_days outcome on sick_less_than_four_days " do
		add_response :sick_less_than_four_days
		assert_current_node :must_be_sick_for_at_least_4_days 	## A1
	end

	should "return has_chronic_illness outcome on chronic_illness" do
		add_response :chronic_illness
		assert_current_node :has_chronic_illness							## A3
	end

	should "return not_informed_soon_enough outcome on havent_told_you_they_were_sick" do
		add_response :havent_told_you_they_were_sick
		assert_current_node	:not_informed_soon_enough			## A7
	end
	
	should "return irregular_work_schedule outcome on different_days" do
		add_response :different_days
		assert_current_node :irregular_work_schedule 			## A4
	end



end