require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MaternityPaternityCalculatorTest < ActiveSupport::TestCase
    
    context MaternityPaternityCalculator do
      context "due date 4 months in future" do
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
            assert_equal (193.00 * 0.9).round(2), @calculator.statutory_maternity_rate_a
          end
          
          should "calculate the maternity pay at rate B using the base rate" do
            assert_equal 135.45, @calculator.statutory_maternity_rate_b
          end
          
          should "calculate the maternity pay at rate B using the percentage of weekly income" do
            @calculator.average_weekly_earnings = 135.40
            assert_equal (135.40 * 0.9).round(2), @calculator.statutory_maternity_rate_b
          end

        end

        should "calculate the paternity rate as the standard rate" do
          @calculator.average_weekly_earnings = 500.55
          assert_equal 135.45, @calculator.statutory_paternity_rate 
        end

        should "calculate the paternity rate as 90 percent of weekly earnings" do
          @calculator.average_weekly_earnings = 120.55
          assert_equal ((120.55 * 0.9).to_f).round(2), @calculator.statutory_paternity_rate 
        end
        
        context "with an adoption placement date of a week ago" do
          setup do
            @one_week_ago = 1.week.ago(Date.today)
            @calculator.adoption_placement_date = @one_week_ago
          end
          
          should "make the earliest leave start date 14 days before the placement date" do
            assert_equal 1.fortnight.ago(@one_week_ago), @calculator.leave_earliest_start_date
          end
        end
      end

      context "specific date tests (for lower_earning_limits) for birth" do
        should "return lower_earning_limit 107" do
          @due_date = Date.parse("1 January 2013")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal @calculator.lower_earning_limit, 107
        end
        should "return lower_earning_limit 107" do
          @due_date = Date.parse("15 July 2012")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal @calculator.lower_earning_limit, 107
        end
        should "return lower_earning_limit 102" do
          @due_date = Date.parse("14 July 2012")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal @calculator.lower_earning_limit, 102
        end
        should "return lower_earning_limit 102" do
          @due_date = Date.parse("1 January 2012")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal @calculator.lower_earning_limit, 102
        end
        should "return lower_earning_limit 97" do
          @due_date = Date.parse("1 January 2011")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal @calculator.lower_earning_limit, 97
        end
        should "return lower_earning_limit 95" do
          @due_date = Date.parse("1 January 2010")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal @calculator.lower_earning_limit, 95
        end
      end

      context "specific date tests (for lower_earning_limits) for adoption" do
        should "return lower_earning_limit 107" do
          @match_date = Date.parse("1 April 2012")
          @calculator = MaternityPaternityCalculator.new(@match_date, "adoption")
          assert_equal @calculator.lower_earning_limit, 107
        end
        should "return lower_earning_limit 102" do
          @match_date = Date.parse("31 March 2012")
          @calculator = MaternityPaternityCalculator.new(@match_date, "adoption")
          assert_equal @calculator.lower_earning_limit, 102
        end
        should "return lower_earning_limit 97" do
          @match_date = Date.parse("2 April 2011")
          @calculator = MaternityPaternityCalculator.new(@match_date, "adoption")
          assert_equal @calculator.lower_earning_limit, 97
        end
      end
    end    
  end
end
