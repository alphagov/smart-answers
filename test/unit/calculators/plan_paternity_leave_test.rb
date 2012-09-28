require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PlanPaternityLeaveTest < ActiveSupport::TestCase

  	context PlanPaternityLeave do

  		context "formatted due dates" do
		    should "show formatted due date" do
		      @calculator = PlanPaternityLeave.new(due_date: "2012-12-26", start_date: 'days_05')
		    	assert_equal "26 December 2012", @calculator.formatted_due_date
		    end
		  end
		  
		  context "start dates" do
		    should "format start date (weeks 02)" do
		      @calculator = PlanPaternityLeave.new(due_date: "2012-12-26", start_date: 'weeks_02')
					assert_equal "12 December 2012", @calculator.formatted_start_date
		    end
		    should "format start date (days 05)" do
		      @calculator = PlanPaternityLeave.new(due_date: "2012-12-26", start_date: 'days_05')
					assert_equal "21 December 2012", @calculator.formatted_start_date
		    end
		  end

		  context "distance from start dates" do
		    setup do
		      @calculator = PlanPaternityLeave.new(due_date: "2012-12-26", start_date: 'days_05')
		    end
		    should "distance from start (days 05)" do
					assert_equal "5 days", @calculator.distance_start('days_5')
		    end
		    should "distance from start (weeks 02)" do
					assert_equal "2 weeks", @calculator.distance_start('weeks_2')
		    end
	    end

	    context "test date range methods" do
	    	setup do
			    # /plan-paternity-leave/y/2013-03-14/weeks_2
		      @calculator = PlanPaternityLeave.new(
		      	due_date: "2013-03-14", start_date: 'weeks_2')
	    	end

	    	should "qualifying_week give last date of 1 December 2012" do
		      assert_equal Date.parse("1 December 2012"), @calculator.qualifying_week.last
		    end

	    	should "give range of 28 February 2013 - 13 March 2013" do
		      assert_equal "28 February 2013 - 13 March 2013", @calculator.format_date_range(@calculator.period_of_ordinary_leave)
		    end

	    	should "period_of_additional_leave give range of 14 March 2013 - 08 May 2013" do
		    	assert_equal "25 July 2013 - 22 January 2014", @calculator.format_date_range(@calculator.period_of_additional_leave)
		    end

		    should "period_of_potential_ordinary_leave give range of 25 July 2013 - 22 January 2014" do
		    	assert_equal "14 March 2013 - 08 May 2013", @calculator.format_date_range(@calculator.period_of_potential_ordinary_leave)
		    end
		  end

  	end
  end
end