require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MaternityPaternityCalculatorTest < ActiveSupport::TestCase
    
    context MaternityPaternityCalculator do
      setup do
        @four_months_from_now = 4.months.since(Date.today)
        @start_of_week_in_four_months = @four_months_from_now - @four_months_from_now.wday
        @calculator = MaternityPaternityCalculator.new(@four_months_from_now)
      end
      
      should "calculate expected birth week" do
        assert_equal @start_of_week_in_four_months, @calculator.expected_week.first
      end
      
      should "calculate qualifying week" do
        assert_equal 15.weeks.ago(@start_of_week_in_four_months), @calculator.qualifying_week.first
      end
      
      should "calculate start date of employment for elligibility" do
        assert_equal 26.weeks.ago(@start_of_week_in_four_months), @calculator.employment_start
      end 
      
      should "calculate notice of leave deadline" do
        assert_equal 15.weeks.ago(@start_of_week_in_four_months), @calculator.notice_of_leave_deadline
      end
      
      should "calculate the earliest leave start date" do
        assert_equal 11.weeks.ago(@four_months_from_now), @calculator.max_leave_start_date
      end
      
      context "with a requested leave date in one month's time" do
        setup do
          @calculator.leave_start_date = 1.month.since(Date.today)
        end
        
        should "make the leave end date 52 weeks from the leave start date" do
          assert_equal 52.weeks.since(@calculator.leave_start_date), @calculator.leave_end_date
        end
      end
      
    end
    
  end
end
