
require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StatutorySickPayCalculatorTest < ActiveSupport::TestCase

  	context StatutorySickPayCalculator do
  		context "prev_sick_days is 5" do
	  		setup do
	  			@calculator = StatutorySickPayCalculator.new(5, Date.parse("1 October 2012"))
	  			@calculator.set_normal_work_days(3)
	  			@calculator.set_daily_rate(4)	
	  		end

	  		should "return waiting_days of 0" do
	  			assert_equal @calculator.waiting_days, 0
	  		end

	  		should "return daily rate of 21.4625" do
	  			assert_equal @calculator.daily_rate, 21.4625
	  		end

	  		should "normal working days is 3" do
	  			assert_equal @calculator.normal_work_days, 3
	  		end

	  		should "return ssp_payment x" do
	  			assert_equal @calculator.ssp_payment, 64.39
	  		end

	  		context "set daily rate to 3 " do
	  			should "return 28.6167" do
	  				@calculator.set_daily_rate(3)
	  				assert_equal @calculator.daily_rate, 28.6167 # should be 28.6166 according to HMRC table
	  				assert_equal @calculator.ssp_payment, 85.85
	  			end
	  		end

	  		context "set daily rate to 2 " do
	  			should "return 42.9250" do
	  				@calculator.set_daily_rate(2)
	  				assert_equal @calculator.daily_rate, 42.9250	
	  			end
	  		end

	  		context "set daily rate to 5 " do
	  			should "return 17.1700" do
	  				@calculator.set_daily_rate(5)
	  				assert_equal @calculator.daily_rate, 17.1700
	  			end
	  		end

	  		context "set daily rate to 6 " do
	  			should "return 14.3083" do
	  				@calculator.set_daily_rate(6)
	  				assert_equal @calculator.daily_rate, 14.3083
	  			end
	  		end

			context "set daily rate to 7 " do
	  			should "return 12.2643" do
	  				@calculator.set_daily_rate(7)
	  				assert_equal @calculator.daily_rate, 12.2643 # should be 12.2642 according to hmrc tables
	  			end
	  		end	  	
	  	end

	  	context "prev_sick_days is 3" do
	  		setup {@calculator = StatutorySickPayCalculator.new(3, Date.parse("6 April 2012"))}

	  		should "return waiting_days of 0" do
	  			assert_equal @calculator.waiting_days, 0
	  		end
	  	end

	  	context "prev_sick_days is 2" do
	  		setup {@calculator = StatutorySickPayCalculator.new(2, Date.parse("6 April 2012"))}

	  		should "return waiting_days of 1" do
	  			assert_equal @calculator.waiting_days, 1
	  		end
	  	end

		context "prev_sick_days is 1" do
	  		setup {@calculator = StatutorySickPayCalculator.new(1, Date.parse("6 April 2012"))}

	  		should "return waiting_days of 2" do
	  			assert_equal @calculator.waiting_days, 2
	  		end
	  	end


	  	context "prev_sick_days is 0" do
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(0, Date.parse("6 April 2012"))
	  		end

	  		should "return waiting_days of 3, ssp_payment of 0" do
	  			@calculator.set_normal_work_days(3)
	  			@calculator.set_daily_rate(3)
	  			assert_equal @calculator.waiting_days, 3
	  			assert_equal @calculator.normal_work_days, 3
  				assert_equal @calculator.daily_rate, 28.6167
	  			assert_equal @calculator.ssp_payment, 0.00
	  		end

	  		should "if normal_work_days and daily_rate set to 0" do
				@calculator.set_normal_work_days(0)
	  			@calculator.set_daily_rate(0)
				assert_equal @calculator.waiting_days, 3
	  			assert_equal @calculator.normal_work_days, 0
  				assert_equal @calculator.daily_rate, 0
	  			assert_equal @calculator.ssp_payment, 0.00
	  		end	  			
	  	end

	  	context "historic rate tests 1" do
	  		setup do
	  			@calculator = StatutorySickPayCalculator.new(0, Date.parse("5 April 2012"))
	  		end

	  		should "use ssp rate and lel for 2011-12" do
	  			assert_equal @calculator.lower_earning_limit, 102
	  			assert_equal @calculator.ssp_weekly_rate, 81.60
	  		end
	  	end

	  	# change this to Monday - Friday
	  	context "test scenario 1" do 
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(0, Date.parse("26 March 2012"))
	  			@calculator.set_daily_rate(5)
	  			@calculator.set_normal_work_days(15)
	  		end

	  		should "give correct ssp calculation" do  # 15 days with 3 waiting days, so 6 days at lower weekly rate, 6 days at higher rate
	  			assert_equal @calculator.daily_rate, 16.3200
	  			#assert_equal @calculator.ssp_payment, 200.94
	  		end
	  	end

	  	# change this to Tuesday to Friday
		context "test scenario 2" do 
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(7, Date.parse("28 February 2012"))
	  			@calculator.set_daily_rate(4)
	  			@calculator.set_normal_work_days(24)
	  		end

	  		should "give correct ssp calculation" do # 24 days with no waiting days, so 22 days at lower weekly rate, 2 days at higher rate
	  			assert_equal @calculator.daily_rate, 20.4000
	  			#assert_equal @calculator.ssp_payment, 490.67
	  		end
	  	end

	  	# Change this to Monday, Wednesday, Friday
		context "test scenario 3" do 
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(24, Date.parse("25 July 2012"))
	  			@calculator.set_daily_rate(3)
	  			@calculator.set_normal_work_days(18)
	  		end

	  		should "give correct ssp calculation" do # 18 days with no waiting days, all at 2012-13 daily rate
	  			assert_equal @calculator.daily_rate, 28.6167
	  			assert_equal @calculator.ssp_payment, 515.10
	  		end
	  	end

	  	# change this to Saturday and Sunday
	  	context "test scenario 4" do
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(0, Date.parse("23 November 2012"))
	  			@calculator.set_daily_rate(2)
	  			@calculator.set_normal_work_days(12)
	  		end

	  		should "give correct ssp calculation" do # 12 days with 3 waiting days, all at 2012-13 daily rate
	  			assert_equal @calculator.daily_rate, 42.9250
	  			assert_equal @calculator.ssp_payment, 386.33
	  		end
	  	end

	  	# change this to Monday - Thursday
	  	context "test scenario 5" do
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(99, Date.parse("29 March 2012"))
	  			@calculator.set_daily_rate(4)
	  			@calculator.set_normal_work_days(20)
	  		end

	  		should "give correct ssp calculation" do # max of 16 days that can still be paid with no waiting days, first four days at 2011-12,  2012-13 daily rate
	  			assert_equal @calculator.daily_rate, 20.4000
	  			assert_equal @calculator.ssp_payment, 326.40 # tests max of 16 days correctly. Should be 339.15 after calculation is fixed to include 12 days at higher rate
	  		end
	  	end


	  	# change this to Monday - Thursday
	  	context "test scenario 6" do
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(115, Date.parse("29 March 2012"))
	  			@calculator.set_daily_rate(4)
	  			@calculator.set_normal_work_days(20)
	  		end

	  		should "give correct ssp calculation" do # there should be no more days for which employee can receive pay
	  			assert_equal @calculator.ssp_payment, 0
	  		end
	  	end

	  	# change this to Wednesday
	  	context "test scenario 7" do
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(0, Date.parse("28 August 2012"))
	  			@calculator.set_daily_rate(1)
	  			@calculator.set_normal_work_days(6)
	  		end

	  		should "give correct ssp calculation" do # there should be no more days for which employee can receive pay
	  			assert_equal @calculator.daily_rate, 85.8500
	  			assert_equal @calculator.ssp_payment, 257.55
	  		end
	  	end

	  	# additional test scenarios
	  	context "test scenario 6a - 1 day max to pay" do
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(114, Date.parse("29 March 2012"))
	  			@calculator.set_daily_rate(4)
	  			@calculator.set_normal_work_days(20)
	  		end

	  		should "give correct ssp calculation" do # there should be max 1 day for which employee can receive pay
	  			assert_equal @calculator.daily_rate,  20.4000
	  			assert_equal @calculator.ssp_payment, 20.40
	  		end
	  	end

	  end
  end
end