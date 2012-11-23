
require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StatutorySickPayCalculatorTest < ActiveSupport::TestCase

  	context StatutorySickPayCalculator do
  		context "prev_sick_days is 5, M-F, 7 days out" do
	  		setup do
	  			@calculator = StatutorySickPayCalculator.new(5, Date.parse("1 October 2012"), Date.parse("7 October 2012"), ['1', '2', '3', '4', '5'])
	  		end

	  		should "return waiting_days of 0" do
	  			assert_equal @calculator.waiting_days, 0
	  		end

	  		should "return daily rate of 17.1700" do
	  			assert_equal @calculator.daily_rate, 17.1700
	  		end

	  		should "normal working days missed is 5" do
	  			assert_equal @calculator.normal_workdays, 5
	  		end

	  		should "return correct ssp_payment" do
	  			assert_equal @calculator.ssp_payment, 85.85
	  		end
	  	end

	  	context "daily rate test for 3 days per week worked (M-W-F)" do
	  		setup do
	  			@calculator = StatutorySickPayCalculator.new(5, Date.parse("1 October 2012"), Date.parse("7 October 2012"), ['1', '3', '5'])
	  		end

	  		should "return daily rate of 28.6166" do
	  			assert_equal @calculator.daily_rate, 28.6166 # should be 28.6166 according to HMRC table
	  		end
	  	end

			context "daily rate test for 7 days per week worked" do
	  		setup do
	  			@calculator = StatutorySickPayCalculator.new(5, Date.parse("1 October 2012"), Date.parse("7 October 2012"), ['0','1', '2', '3', '4','5','6'])
	  		end

	  		should "return daily rate of 12.2642" do
	  			assert_equal @calculator.daily_rate, 12.2642 # matches the HMRC SSP daily rate table
	  		end
	  	end

			context "daily rate test for 6 days per week worked" do
	  		setup do
	  			@calculator = StatutorySickPayCalculator.new(5, Date.parse("1 October 2012"), Date.parse("7 October 2012"), ['1', '2', '3', '4','5','6'])
	  		end

	  		should "return daily rate of 14.3083" do
	  			assert_equal @calculator.daily_rate, 14.3083 
	  		end
	  	end

	  	context "daily rate test for 2 days per week worked" do
	  		setup do
	  			@calculator = StatutorySickPayCalculator.new(5, Date.parse("1 October 2012"), Date.parse("7 October 2012"), ['4','5'])
	  		end

	  		should "return daily rate of 42.9250" do
	  			assert_equal @calculator.daily_rate, 42.9250 
	  		end
	  	end

	  	context "waiting days if prev_sick_days is 2" do
	  		setup {@calculator = StatutorySickPayCalculator.new(2, Date.parse("6 April 2012"), Date.parse("6 May 2012"), ['1','2','3'])}

	  		should "return waiting_days of 1" do
	  			assert_equal @calculator.waiting_days, 1
	  		end
	  	end

			context "waiting days if prev_sick_days is 1" do
	  		setup {@calculator = StatutorySickPayCalculator.new(1, Date.parse("6 April 2012"), Date.parse("17 April 2012"), ['1','2','3'])}

	  		should "return waiting_days of 2" do
	  			assert_equal @calculator.waiting_days, 2
	  			assert_equal @calculator.normal_workdays, 5
	  			assert_equal @calculator.days_to_pay, 3
	  			
	  		end
	  	end

	  	context "waiting days if prev_sick_days is 0" do
	  		setup {@calculator = StatutorySickPayCalculator.new(0, Date.parse("6 April 2012"), Date.parse("12 April 2012"), ['1','2','3'])}

	  		should "return waiting_days of 3, ssp payment of 0" do
	  			assert_equal @calculator.waiting_days, 3
	  			assert_equal @calculator.days_to_pay, 0
	  			assert_equal @calculator.normal_workdays, 3	
	  			assert_equal @calculator.ssp_payment, 0.00
	  		end
	  	end


	  end # SSP calculator


	 #  	context "historic rate tests 1" do
	 #  		setup do
	 #  			@calculator = StatutorySickPayCalculator.new(0, Date.parse("5 April 2012"))
	 #  		end

	 #  		should "use ssp rate and lel for 2011-12" do
	 #  			assert_equal @calculator.lower_earning_limit, 102
	 #  			assert_equal @calculator.ssp_weekly_rate.to_f, 81.60
	 #  		end
	 #  	end

	 #  	# change this to Monday - Friday
	 #  	context "test scenario 1" do 
	 #  		setup do 
	 #  			@calculator = StatutorySickPayCalculator.new(0, Date.parse("26 March 2012"))
	 #  			@calculator.set_daily_rate(5)
	 #  			@calculator.set_normal_work_days(15)
	 #  		end

	 #  		should "give correct ssp calculation" do  # 15 days with 3 waiting days, so 6 days at lower weekly rate, 6 days at higher rate
	 #  			assert_equal @calculator.daily_rate, 16.3200
	 #  			#assert_equal @calculator.ssp_payment, 200.94
	 #  		end
	 #  	end

	 #  	# change this to Tuesday to Friday
		# context "test scenario 2" do 
	 #  		setup do 
	 #  			@calculator = StatutorySickPayCalculator.new(7, Date.parse("28 February 2012"))
	 #  			@calculator.set_daily_rate(4)
	 #  			@calculator.set_normal_work_days(24)
	 #  		end

	 #  		should "give correct ssp calculation" do # 24 days with no waiting days, so 22 days at lower weekly rate, 2 days at higher rate
	 #  			assert_equal @calculator.daily_rate, 20.4000
	 #  			#assert_equal @calculator.ssp_payment, 490.67
	 #  		end
	 #  	end

	 #  	# Change this to Monday, Wednesday, Friday
		# context "test scenario 3" do 
	 #  		setup do 
	 #  			@calculator = StatutorySickPayCalculator.new(24, Date.parse("25 July 2012"))
	 #  			@calculator.set_daily_rate(3)
	 #  			@calculator.set_normal_work_days(18)
	 #  		end

	 #  		should "give correct ssp calculation" do # 18 days with no waiting days, all at 2012-13 daily rate
	 #  			assert_equal @calculator.daily_rate, 28.6167
	 #  			assert_equal @calculator.ssp_payment, 515.10
	 #  		end
	 #  	end

	 #  	# change this to Saturday and Sunday
	 #  	context "test scenario 4" do
	 #  		setup do 
	 #  			@calculator = StatutorySickPayCalculator.new(0, Date.parse("23 November 2012"))
	 #  			@calculator.set_daily_rate(2)
	 #  			@calculator.set_normal_work_days(12)
	 #  		end

	 #  		should "give correct ssp calculation" do # 12 days with 3 waiting days, all at 2012-13 daily rate
	 #  			assert_equal @calculator.daily_rate, 42.9250
	 #  			assert_equal @calculator.ssp_payment, 386.33
	 #  		end
	 #  	end

	 #  	# change this to Monday - Thursday
	 #  	context "test scenario 5" do
	 #  		setup do 
	 #  			@calculator = StatutorySickPayCalculator.new(99, Date.parse("29 March 2012"))
	 #  			@calculator.set_daily_rate(4)
	 #  			@calculator.set_normal_work_days(20)
	 #  		end

	 #  		should "give correct ssp calculation" do # max of 16 days that can still be paid with no waiting days, first four days at 2011-12,  2012-13 daily rate
	 #  			assert_equal @calculator.daily_rate, 20.4000
	 #  			assert_equal @calculator.ssp_payment, 326.40 # tests max of 16 days correctly. Should be 339.15 after calculation is fixed to include 12 days at higher rate
	 #  		end
	 #  	end


	 #  	# change this to Monday - Thursday
	 #  	context "test scenario 6" do
	 #  		setup do 
	 #  			@calculator = StatutorySickPayCalculator.new(115, Date.parse("29 March 2012"))
	 #  			@calculator.set_daily_rate(4)
	 #  			@calculator.set_normal_work_days(20)
	 #  		end

	 #  		should "give correct ssp calculation" do # there should be no more days for which employee can receive pay
	 #  			assert_equal @calculator.ssp_payment, 0
	 #  		end
	 #  	end

	 #  	# change this to Wednesday
	 #  	context "test scenario 7" do
	 #  		setup do 
	 #  			@calculator = StatutorySickPayCalculator.new(0, Date.parse("28 August 2012"))
	 #  			@calculator.set_daily_rate(1)
	 #  			@calculator.set_normal_work_days(6)
	 #  		end

	 #  		should "give correct ssp calculation" do # there should be no more days for which employee can receive pay
	 #  			assert_equal @calculator.daily_rate.to_f, 85.8500
	 #  			assert_equal @calculator.ssp_payment.to_f, 257.55
	 #  		end
	 #  	end

	 #  	# additional test scenarios
	 #  	context "test scenario 6a - 1 day max to pay" do
	 #  		setup do 
	 #  			@calculator = StatutorySickPayCalculator.new(114, Date.parse("29 March 2012"))
	 #  			@calculator.set_daily_rate(4)
	 #  			@calculator.set_normal_work_days(20)
	 #  		end

	 #  		should "give correct ssp calculation" do # there should be max 1 day for which employee can receive pay
	 #  			assert_equal @calculator.daily_rate,  20.4000
	 #  			assert_equal @calculator.ssp_payment, 20.40
	 #  		end
	 #  	end

	 #  end
  end
end
