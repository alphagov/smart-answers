require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MaternityPaternityCalculatorTest < ActiveSupport::TestCase
    
    context MaternityPaternityCalculator do
      setup do
        @due_date = 4.months.since(Date.today)
        @start_of_week_in_four_months = @due_date - @due_date.wday
        @calculator = MaternityPaternityCalculator.new(@due_date)
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
        assert_equal 11.weeks.ago(@due_date), @calculator.max_leave_start_date
      end
      
      should "calculate the proof of pregnancy deadline" do
        assert_equal 13.weeks.ago(@due_date), @calculator.proof_of_pregnancy_date
      end
      
      context "with a requested leave date in one month's time" do
        setup do
          @leave_start_date = 1.month.since(Date.today)
          @calculator.leave_start_date = @leave_start_date
        end
        
        should "make the leave end date 52 weeks from the leave start date" do
          assert_equal 52.weeks.since(@leave_start_date), @calculator.leave_end_date
        end
        
        should "make the pay start date the same date" do
          assert_equal @leave_start_date, @calculator.pay_start_date
        end
        
        should "make the pay end date 39 weeks from the start date" do
          assert_equal 39.weeks.since(@leave_start_date), @calculator.pay_end_date
        end
      end
      
    end
    
  end
end
