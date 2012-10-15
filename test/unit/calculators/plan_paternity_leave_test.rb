require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PlanPaternityLeaveTest < ActiveSupport::TestCase

  	context PlanPaternityLeave do
  		setup do
  			@due_date = "2012-12-26"
  			@start_date = "2012-12-31" # 5 days
	      @calculator = PlanPaternityLeave.new(due_date: @due_date)
  		end

  		context "formatted due dates" do
		    should "show formatted due date" do
		    	assert_equal "Wednesday, 26 December 2012", @calculator.formatted_due_date
		    end
		  end
		  
		  context "start dates" do
		    should "format start date (weeks 02)" do
	  			@start_date = "2013-01-09" # 2 weeks
		      @calculator.enter_start_date(@start_date)
					assert_equal "09 January 2013", @calculator.formatted_start_date
		    end
		    should "format start date (days 05)" do
		      @calculator.enter_start_date(@start_date)
					assert_equal "31 December 2012", @calculator.formatted_start_date
		    end
		  end

		  context "test date range methods" do
	    	setup do
			    # /plan-paternity-leave/y/2013-03-14/weeks_2
	  			@start_date = "2013-01-09" # 2 weeks
		      @calculator = PlanPaternityLeave.new(due_date: "2013-03-14")
		      @calculator.enter_start_date(@start_date)
	    	end

	    	should "qualifying_week give last date of 1 December 2012" do
		      assert_equal Date.parse("1 December 2012"), @calculator.qualifying_week.last
		    end

	    	should "give range of 09 January 2013 to 22 January 2013" do
		      assert_equal "09 January 2013 to 22 January 2013", @calculator.format_date_range(@calculator.period_of_ordinary_leave)
		    end

	    	should "period_of_additional_leave give range of ..." do
		    	period_of_additional_leave = @calculator.period_of_additional_leave
		    	assert_equal "01 August 2013 to 29 January 2014", @calculator.format_date_range(period_of_additional_leave)
		    	assert_equal 25, (period_of_additional_leave.last.julian - period_of_additional_leave.first.julian).to_i / 7
		    	assert_equal 20, (period_of_additional_leave.first.julian - Date.parse("2013-03-14").julian).to_i / 7
		    end

		    should "period_of_potential_ordinary_leave give range of 14 March 2013 to 08 May 2013" do
		    	assert_equal "14 March 2013 to 08 May 2013", @calculator.format_date_range(@calculator.period_of_potential_ordinary_leave)
		    end
		  end

		  context "leave duration and potential leave tests" do
		  	should "potential leave = Wed, 26 Dec 2012..Wed, 06 Feb 2013 on 2 weeks leave requested" do
		  		@calculator.leave_duration(2)
		  		assert_equal Date.parse("Wed, 26 Dec 2012")..Date.parse("Wed, 06 Feb 2013"), @calculator.potential_leave
		  	end
		  	should "potential leave = Wed, 26 Dec 2012..Wed, 13 Feb 2013 on 2 weeks leave requested" do
		  		@calculator.leave_duration(1)
		  		assert_equal Date.parse("Wed, 26 Dec 2012")..Date.parse("Wed, 13 Feb 2013"), @calculator.potential_leave
		  	end
		  end
  	end
  end
end