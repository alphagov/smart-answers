# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateStatutorySickPayTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-statutory-sick-pay'
  end

  	should "ask if employee is getting maternity pay" do
  		assert_current_node :getting_maternity_pay?
  	end

  	context "answered yes to maternity" do
  		should "return already_receiving_benefit on maternity answer" do
  			add_response :yes
			assert_current_node :already_receiving_benefit 
		end
	end

	context "answered no to maternity " do
		setup {add_response :no}
	  
	 	should "ask if employee is getting paternity or adoption pay"  do
	  		assert_current_node :getting_paternity_or_adoption_pay?
	  	end

	  	context "answer yes" do
	  		setup {add_response :yes}

	  		should "have set warning message and ask if employee was sick less then four days" do
	  			assert_phrase_list :warning_message, [:paternity_adoption_warning]
	  			assert_current_node :sick_less_than_four_days?
	  		end

	  		context "answer yes to less than four days" do
	  			should "return must_be_sick_for_at_least_4_days outcome on sick_less_than_four_days " do
					add_response :yes
					assert_current_node :must_be_sick_for_at_least_4_days 	
				end
			end

	  		context "answer no to less than four days" do
	  			setup {add_response :no}

	  			should "ask if they told you within seven days" do
	  				assert_current_node :have_told_you_they_were_sick?
	  			end

	  			context "answer no to told within 7 days" do
	  				should "return not_informed_soon_enough outcome on havent_told_you_they_were_sick" do
						add_response :no
						assert_current_node	:not_informed_soon_enough			
					end
				end

	  			context "answer yes to told within 7 days" do
	  				setup {add_response :yes}

	  				should "ask if they normally work different days" do
	  					assert_current_node :different_days?
	  				end

	  				context "answer yes to irregular work schedule" do
						should "return irregular_work_schedule outcome on different_days" do
							add_response :yes
							assert_current_node :irregular_work_schedule 		
						end
	  				end

	  				context "answer no to irregular schedule" do
	  					setup {add_response :no}

	  					should "ask for sickness start date" do
	  						assert_current_node :sickness_start_date?
	  					end

	  					context "answer 10 September 2012" do
	  						setup {add_response Date.parse('10 September 2012')}
	  				
	  						should "ask for sickness end date" do
	  							assert_current_node :sickness_end_date?
	  						end

	  						context "answer 20 September 2012" do
	  							setup {add_response Date.parse('20 September 2012')}

	  							should "ask if employee was paid for at least eight weeks" do
		  							assert_current_node :employee_paid_for_last_8_weeks?
		  						end

		  						context "answer yes to at least 8 weeks" do
		  							setup {add_response :yes}

		  							should "ask what were average weekly earnings" do
		  								assert_current_node :what_was_average_weekly_earnings?
		  							end

		  							context "earnings too low - 95.50" do
		  								setup {add_response 95.50}

		  								should "display not earned enough" do
		  									assert_current_node :not_earned_enough
		  								end
		  							end

		  							context "earnings high enough - £250.25" do
		  								setup {add_response 250.25}

		  								should "ask if they had a related illness" do
		  									assert_state_variable "over_eight_awe", 250.25
		  									assert_current_node :related_illness?
		  								end

		  								## TODO: continue flow
		  							end
		  						end # yes to 8 weeks

		  						context "answer no to at least 8 weeks" do
		  							setup {add_response :no}

		  							should "ask what was average weekly pay when they got sick" do
		  								assert_current_node :what_was_average_weekly_pay?
		  							end

		  							context "avg weekly pay £250.25" do
	  									setup {add_response 250.25}

	  									should "ask if they had related illness" do
	  										assert_state_variable "under_eight_awe", 250.25
	  										assert_current_node :related_illness?
	  									end

	  									context "no to related illness" do
	  										setup {add_response :no}

	  										should "ask how many days worked" do
	  											assert_current_node :how_many_days_worked?
	  										end

	  										context "5 days worked" do
			  									setup {add_response '5'}

										  		should "ask how may sick days they had" do
			  										assert_state_variable "pattern_days", 5
			  										assert_state_variable "daily_rate", 17.17
			  										assert_current_node :normal_workdays_taken_as_sick?
			  									end

			  									context "4 work days out" do
			  										setup {add_response 4}

			  										should "give entitled outcome" do
				  									assert_state_variable "normal_workdays_out", 4
				  									assert_state_variable "ssp_payment", "17.17"
				  									assert_current_node :entitled
			  									end
			  								end
			  							end # no to related illness

			  							# context "yes to related illness" do
			  							# 	setup {add_response :yes}

			  							# 	should "ask how many days missed" do
			  							# 		assert_current_node :how_many_days_missed?
			  							# 	end

			  						# 		context "days missed" do
			  						# 			should "return an error if 0" do
	  								# 				add_response '0'
	  								# 				assert_current_node_is_error
	  								# 				assert_current_node :how_many_days_missed?
	  								# 			end

	  								# 			should "return an error if text" do
	  								# 				add_response 'sometext'
	  								# 				assert_current_node_is_error
	  								# 				assert_current_node :how_many_days_missed?
											# 	end
											# end
										# end

										 #  		context "answered 3 sick days during related illness" do
											#   		setup {add_response '3'}
											  		
											#   		should "ask how many days they work" do
											#   			assert_state_variable "prev_sick_days", 3
											#   			assert_current_node :how_many_days_worked?
											#   		end

											#   		context "enter text" do
											# 	  		setup {add_response 'sometext'}
												  		
											# 	  		should "return an error if text" do
											# 	  			assert_current_node_is_error
											# 	  			assert_current_node :how_many_days_worked?
											# 	  		end
											# 	  	end

											# 	  	should "return an error if 0" do
											#   			add_response '0'
											#   			assert_current_node_is_error
											#   			assert_current_node :how_many_days_worked?
											#   		end
										  	
										 #  			should "ask for days taken as sick if 1" do
											#   			add_response '1'
											#   			assert_current_node :normal_workdays_taken_as_sick?
											#   		end
										  			
										 #  			should "ask for days taken as sick if 2" do
											#   			add_response '2'
											#   			assert_current_node :normal_workdays_taken_as_sick?
											#   		end
										  			
										 #  			should "ask for days taken as sick if 3" do
											#   			add_response '3'
											#   			assert_current_node :normal_workdays_taken_as_sick?
											#   		end
										  			
										 #  			should "ask for days taken as sick if 4" do
											#   			add_response '4'
											#   			assert_current_node :normal_workdays_taken_as_sick?
											#   		end
										  			
										 #  			should "ask for days taken as sick if 6" do
											#   			add_response '6'
											#   			assert_current_node :normal_workdays_taken_as_sick?
											#   		end
										  			
										 #  			should "ask for days taken as sick if 7" do
											#   			add_response '7'
											#   			assert_current_node :normal_workdays_taken_as_sick?
											#   		end

											#   		context "5 days worked" do
											# 	  		setup {add_response '5'}

											# 	  		should "ask how may sick days they had" do
											# 	  			assert_state_variable "pattern_days", 5
											# 	  			assert_state_variable "daily_rate", 17.17
											# 	  			assert_current_node :normal_workdays_taken_as_sick?
											# 	  		end

											# 	  		context "4 work days out" do
											# 	  			setup {add_response 4}

											# 	  			should "give entitled outcome" do
											# 		  			assert_state_variable "normal_workdays_out", 4
											# 		  			assert_state_variable "ssp_payment", "17.17"
											# 		  			assert_current_node :entitled
											# 	  			end
											# 	  		end
											#   		end
											#   	end # 3 sick days		
											# end # how mant days missed
			  						# 	end # yes to related illness
			  						end # avg weekly pay
			  					end # no to 8 weeks
			  				end #end date
			  			end # start date	
			  		end #no to irregular schedule
		  		end # told within 7 days
		  	end # no to less than four days
		end # yes to paternity adoption
	end
end

end
	 

# 	  context "answer no" do
# 	  	setup {add_response :no}

# 	  	should "ask what the workers average weekly was when they got sick" do
# 	  		assert_current_node :what_was_average_weekly_pay?
# 	  	end

# 	  	context "avg weekly earnings £250.25" do
# 	  		setup {add_response 250.25}

# 	  		should "ask how many days they work" do
# 	  			assert_state_variable "under_eight_awe", 250.25
# 	  			assert_current_node :how_many_days_worked?
# 	  		end

# 				context "set normal work days taken as sick to 3" do
# 					setup {add_response 3}
					
# 					should "ask days taken as sick" do
# 						assert_current_node :normal_workdays_taken_as_sick?
# 						assert_state_variable "daily_rate", 28.62
# 					end

# 					should "pass to entitled outcome" do
# 	  				add_response 3
# 	  				assert_state_variable "ssp_payment", "0.00"
# 	  				assert_state_variable "normal_workdays_out", 3
# 	  				assert_current_node :entitled
# 	  			end
# 	  		end
# 	  	end

# 	  	should "return earnings too low outcome on 90.25" do
# 	  		add_response 90.25
# 	  		assert_current_node :not_earned_enough
# 	  	end

# 	  	context "avg weekly earnings £400.00" do
# 	  		setup {add_response '400'}

# 	  		should "ask how many days they work" do
# 	  			assert_current_node :how_many_days_worked?
# 	  		end

# 	  		context "4 days worked" do
# 	  			setup {add_response '4'}
	  			
# 	  			should "ask normal_workdays_taken_as_sick" do
# 	  				assert_current_node :normal_workdays_taken_as_sick?
# 	  			end

# 	  			should "NOT give ssp_payment -21.46 answer when provide 2 days" do
# 	  				add_response '2'
# 	  				assert_state_variable "ssp_payment", "0.00"
# 	  				assert_current_node :entitled
# 	  			end
# 	  		end
# 	  	end
# 	  end
# 	end
# end