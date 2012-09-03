require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MaternityPaternityCalculatorTest < ActiveSupport::TestCase
    
    context MaternityPaternityCalculator do
      setup do
        @one_month_from_now = 1.month.since(Date.today)
        @start_of_week_in_one_month = @one_month_from_now - @one_month_from_now.wday
        @calculator = MaternityPaternityCalculator.new(@one_month_from_now)
      end
      
      should "calculate expected birth week" do
        assert_equal @start_of_week_in_one_month, @calculator.expected_week.first
      end
      
      should "calculate qualifying week" do
        assert_equal 15.weeks.ago(@start_of_week_in_one_month), @calculator.qualifying_week.first
      end
      
      should "calculate start date of employment for elligibility" do
        assert_equal 26.weeks.ago(@start_of_week_in_one_month), @calculator.employment_start
      end 
      
    end
    
  end
end
