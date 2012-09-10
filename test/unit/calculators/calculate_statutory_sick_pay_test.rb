require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CalculateStatutorySickPayTest < ActiveSupport::TestCase

  	context CalculateStatutorySickPay do
  		
  		context "prev_sick_days is 5" do
	  		setup do
	  			@calculator = CalculateStatutorySickPay.new(5)
	  			@calculator.set_normal_work_days(3)
	  			@calculator.set_daily_rate(4)	
	  		end


	  		should "return waiting_days of 0" do
	  			assert_equal @calculator.waiting_days, 0
	  		end

	  		should "return daily rate of 21.46" do
	  			assert_equal @calculator.daily_rate, 21.46
	  		end

	  		should "normal working days is 3" do
	  			assert_equal @calculator.normal_work_days, 3
	  		end


	  		should "return ssp_payment x" do
	  			assert_equal @calculator.ssp_payment, 64.38
	  		end


	  	end

	  	context "prev_sick_days is 3" do
	  		setup {@calculator = CalculateStatutorySickPay.new(3)}

	  		should "return waiting_days of 3" do
	  			assert_equal @calculator.waiting_days, 3
	  		end
	  	end
	  end

  end
end