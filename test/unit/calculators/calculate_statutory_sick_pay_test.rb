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

	  		context "set daily rate to 3 " do
	  			should "return 28.62" do
	  				@calculator.set_daily_rate(3)
	  				assert_equal @calculator.daily_rate, 28.62
	  				assert_equal @calculator.ssp_payment, 85.86
	  			end
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

	  	context "prev_sick_days is 0" do
	  		setup do 
	  			@calculator = CalculateStatutorySickPay.new(0)
	  		end

	  		should "return waiting_days of 3, ssp_payment of 0" do
	  			@calculator.set_normal_work_days(3)
	  			@calculator.set_daily_rate(3)
	  			assert_equal @calculator.waiting_days, 3
	  			assert_equal @calculator.normal_work_days, 3
  				assert_equal @calculator.daily_rate, 28.62
	  			assert_equal @calculator.ssp_payment, 0.00
	  		end

	  		should "if normal_work_days and daily_rate set to 0" do
					@calculator.set_normal_work_days(0)
	  			@calculator.set_daily_rate(0)
					assert_equal @calculator.waiting_days, 3
	  			assert_equal @calculator.normal_work_days, 0
  				assert_equal @calculator.daily_rate, 0 #28.62
	  			assert_equal @calculator.ssp_payment, 0.00
	  		end	  			
	  	end
	  end
  end
end