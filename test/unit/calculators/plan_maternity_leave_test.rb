require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PlanMaternityLeaveTest < ActiveSupport::TestCase

    context "formatted due dates" do
	    should "show formatted due date" do
	      @calculator = PlanMaternityLeave.new(due_date: "2012-12-26", start_date: 'days_05')
	    	assert_equal "26 December 2012", @calculator.formatted_due_date
	    end
	  end
	  
	  context "start dates" do
	    should "format start date (weeks 02)" do
	      @calculator = PlanMaternityLeave.new(due_date: "2012-12-26", start_date: 'weeks_02')
				assert_equal "12 December 2012", @calculator.formatted_start_date
	    end
	    should "format start date (days 05)" do
	      @calculator = PlanMaternityLeave.new(due_date: "2012-12-26", start_date: 'days_05')
				assert_equal "21 December 2012", @calculator.formatted_start_date
	    end
	  end

	  context "distance from start dates" do
	    should "distance from start (days 05)" do
	      @calculator = PlanMaternityLeave.new(due_date: "2012-12-26", start_date: 'days_05')
				assert_equal "5 days", @calculator.distance_start('days_5')
	    end
	    should "distance from start (weeks 02)" do
	      @calculator = PlanMaternityLeave.new(due_date: "2012-12-26", start_date: 'days_05')
				assert_equal "2 weeks", @calculator.distance_start('weeks_2')
	    end
    end
  end
end