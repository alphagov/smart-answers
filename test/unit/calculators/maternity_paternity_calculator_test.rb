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
        assert_equal 11.weeks.ago(@due_date), @calculator.leave_earliest_start_date
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
        
        should "make the leave end date after the leave start date" do
          assert @calculator.leave_end_date > @calculator.leave_start_date, "Leave end date should come after leave start date"
        end
        
        should "make the pay start date the same date" do
          assert_equal @leave_start_date, @calculator.pay_start_date
        end
        
        should "make the pay end date 39 weeks from the start date" do
          assert_equal 39.weeks.since(@leave_start_date), @calculator.pay_end_date
        end
      end
      
      context "with a weekly income of 193.00" do
        setup do
          @calculator.average_weekly_earnings = 193.00
        end
        
        should "calculate the statutory maternity rate" do
          assert_equal (193.00 * 0.9).round(2), @calculator.statutory_maternity_rate
        end
        
        should "calculate the maternity pay at rate A" do
          assert_equal ((193.00 * 0.9).round(2) * 6).round(2), @calculator.statutory_maternity_pay_a
        end
        
        should "calculate the maternity pay at rate B using the base rate" do
          assert_equal (135.45 * 33).round(2), @calculator.statutory_maternity_pay_b
        end
        
        should "calculate the maternity pay at rate B using the percentage of weekly income" do
          @calculator.average_weekly_earnings = 135.40
          assert_equal ((135.40 * 0.9).round(2) * 33).round(2), @calculator.statutory_maternity_pay_b
        end
      end
      
    end
    
  end
end
