require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class StatutorySickPayCalculatorTest < ActiveSupport::TestCase
      context "period of incapacity for work" do
        context "qualifying_days" do
          should "return dates matching working days pattern" do
            pattern = %w[Sunday Tuesday Thursday].map { |d| Date::DAYNAMES.index(d).to_s }
            piw = StatutorySickPayCalculator::PeriodOfIncapacityForWork.new(
              begins_on: Date.parse("Sun, 04 Jan 2015"),
              ends_on: Date.parse("Wed, 14 Jan 2015"),
            )
            dates = piw.qualifying_days(pattern)
            assert_equal [
              Date.parse("Sun, 04 Jan 2015"),
              Date.parse("Tue, 06 Jan 2015"),
              Date.parse("Thu, 08 Jan 2015"),
              Date.parse("Sun, 11 Jan 2015"),
              Date.parse("Tue, 13 Jan 2015"),
            ],
                         dates
          end
        end
      end

      context "valid_last_sick_day?" do
        setup do
          @date = Date.parse("2015-01-02")
          @calculator = StatutorySickPayCalculator.new(sick_start_date: @date)
        end

        should "be valid if current PIW would not be empty" do
          @calculator.sick_end_date = @date
          assert @calculator.valid_last_sick_day?
        end

        should "not be valid if current PIW would be empty" do
          @calculator.sick_end_date = @date - 1
          assert_not @calculator.valid_last_sick_day?
        end
      end

      context "valid_linked_sickness_start_date?" do
        setup do
          @date = Date.parse("2015-01-01")
          @calculator = StatutorySickPayCalculator.new(sick_start_date: @date)
        end

        should "be valid if linked PIW begins before current PIW" do
          @calculator.linked_sickness_start_date = @date - 1
          assert @calculator.valid_linked_sickness_start_date?
        end

        should "not be valid if linked PIW begins on same day as current PIW" do
          @calculator.linked_sickness_start_date = @date
          assert_not @calculator.valid_linked_sickness_start_date?
        end
      end

      context "within_eight_weeks_of_current_sickness_period?" do
        setup do
          @date = Date.parse("2015-01-01")
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: @date,
            linked_sickness_start_date: @date - 9.weeks,
          )
        end

        should "be valid if gap between linked PIW and current PIW is 8 weeks or less" do
          @calculator.linked_sickness_end_date = @date - 8.weeks - 1.day
          assert @calculator.within_eight_weeks_of_current_sickness_period?
        end

        should "not be valid if gap between linked PIW and current PIW is more than 8 weeks" do
          @calculator.linked_sickness_end_date = @date - 8.weeks - 2.days
          assert_not @calculator.within_eight_weeks_of_current_sickness_period?
        end
      end

      context "at_least_1_day_before_first_sick_day?" do
        setup do
          @date = Date.parse("2015-01-01")
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: @date,
            linked_sickness_start_date: @date - 1.week,
          )
        end

        should "be valid if gap between linked PIW and current PIW is at least 1 day" do
          @calculator.linked_sickness_end_date = @date - 2.days
          assert @calculator.at_least_1_day_before_first_sick_day?
        end

        should "not be valid if there is no gap between linked PIW and current PIW" do
          @calculator.linked_sickness_end_date = @date - 1.day
          assert_not @calculator.at_least_1_day_before_first_sick_day?
        end
      end

      context "valid_period_of_incapacity_for_work?" do
        setup do
          @date = Date.parse("2015-01-01")
        end

        should "be valid if current PIW is at least 4 days long" do
          calculator = StatutorySickPayCalculator.new(
            sick_start_date: @date,
            sick_end_date: @date + 3.days,
          )
          assert calculator.valid_period_of_incapacity_for_work?
        end

        should "not be valid if current PIW is less than 4 days long" do
          calculator = StatutorySickPayCalculator.new(
            sick_start_date: @date,
            sick_end_date: @date + 2.days,
          )
          assert_not calculator.valid_period_of_incapacity_for_work?
        end
      end

      context "valid_linked_period_of_incapacity_for_work?" do
        setup do
          @date = Date.parse("2015-01-01")
          @calculator = StatutorySickPayCalculator.new(
            linked_sickness_start_date: @date,
          )
        end

        should "be valid if linked PIW is at least 4 days long" do
          @calculator.linked_sickness_end_date = @date + 3.days
          assert @calculator.valid_linked_period_of_incapacity_for_work?
        end

        should "not be valid if current PIW is less than 4 days long" do
          @calculator.linked_sickness_end_date = @date + 2.days
          assert_not @calculator.valid_linked_period_of_incapacity_for_work?
        end
      end

      context "valid_last_payday_before_sickness?" do
        setup do
          @date = Date.parse("2015-01-02")
          @calculator = StatutorySickPayCalculator.new(sick_start_date: @date)
        end

        should "be valid if last payday is before current PIW" do
          @calculator.relevant_period_to = @date - 1.day
          assert @calculator.valid_last_payday_before_sickness?
        end

        should "not be valid if last payday is not before current PIW" do
          @calculator.relevant_period_to = @date
          assert_not @calculator.valid_last_payday_before_sickness?
        end
      end

      context "valid_last_payday_before_offset?" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            relevant_period_to: Date.parse("2015-01-02"),
          )
        end

        should "be valid if last payday is one day after offset date" do
          @calculator.relevant_period_from = @calculator.pay_day_offset + 1.day
          assert @calculator.valid_last_payday_before_offset?
        end

        should "not be valid if last payday is more than one day after offset date" do
          @calculator.relevant_period_from = @calculator.pay_day_offset + 2.days
          assert_not @calculator.valid_last_payday_before_offset?
        end
      end

      context "valid_contractual_days_covered_by_earnings?" do
        setup do
          @date = Date.parse("2015-01-01")
          @calculator = StatutorySickPayCalculator.new(sick_start_date: @date)
        end

        should "be valid if a number" do
          @calculator.contractual_days_covered_by_earnings = "4"
          assert @calculator.valid_contractual_days_covered_by_earnings?
        end

        should "not be valid if it includes letters" do
          @calculator.contractual_days_covered_by_earnings = "4 weeks"
          assert_not @calculator.valid_contractual_days_covered_by_earnings?
        end
      end

      context ".months_between" do
        should "calculate number of months between dates" do
          months = StatutorySickPayCalculator.months_between(Date.parse("04/02/2012"), Date.parse("17/05/2012"))
          assert_equal 4, months
        end

        should "not count the first month if it's later than the 17th" do
          months = StatutorySickPayCalculator.months_between(Date.parse("18/02/2012"), Date.parse("17/05/2012"))
          assert_equal 3, months
        end

        should "not count the last month if it's before the 15th" do
          months = StatutorySickPayCalculator.months_between(Date.parse("13/02/2012"), Date.parse("14/05/2012"))
          assert_equal 3, months
        end
      end # end .months_between

      context ".average_weekly_earnings" do
        should "calculate AWE for weekly pay patterns" do
          assert_equal 100, StatutorySickPayCalculator.average_weekly_earnings(pay: 800, pay_pattern: "weekly")
          assert_equal 100, StatutorySickPayCalculator.average_weekly_earnings(pay: 800, pay_pattern: "fortnightly")
          assert_equal 100, StatutorySickPayCalculator.average_weekly_earnings(pay: 800, pay_pattern: "every_4_weeks")
        end
        should "calculate AWE for monthly pay patterns" do
          assert_equal 92.31,
                       StatutorySickPayCalculator.average_weekly_earnings(
                         pay: 1200, pay_pattern: "monthly", monthly_pattern_payments: 3,
                       ).round(2)
        end
        should "calculate AWE for irregular pay patterns" do
          assert_equal 700,
                       StatutorySickPayCalculator.average_weekly_earnings(
                         pay: 1000, pay_pattern: "irregularly", relevant_period_to: Date.parse("31 December 2013"), relevant_period_from: Date.parse("21 December 2013"),
                       )
        end
      end # end .average_weekly_earnings

      context "0 days per week worked" do
        setup do
          @days_worked = []
          @start_date = Date.parse("1 October 2012")
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: @start_date,
            sick_end_date: Date.parse("7 October 2012"),
            days_of_the_week_worked: @days_worked,
            has_linked_sickness: false,
          )
          assert_equal @calculator.prev_sick_days, 0
        end

        should "return daily rate of 0.0" do
          @weekly_rate = @calculator.send(:weekly_rate_on, @start_date)
          assert_equal @calculator.daily_rate_from_weekly(@weekly_rate, @days_worked.length), 0.0
        end
      end

      context "prev_sick_days is 5, M-F, 7 days out" do
        setup do
          @start_date = Date.parse("1 October 2012")
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: @start_date,
            sick_end_date: Date.parse("7 October 2012"),
            days_of_the_week_worked: %w[1 2 3 4 5],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Sat, 1 Sep 2012"),
            linked_sickness_end_date: Date.parse("Fri, 7 Sep 2012"),
          )
          assert_equal @calculator.prev_sick_days, 5
        end

        should "return number_of_waiting_days_not_in_linked_piw of 0" do
          assert_equal @calculator.number_of_waiting_days_not_in_linked_piw, 0
        end

        should "return daily rate of 17.1700" do
          @weekly_rate = @calculator.send(:weekly_rate_on, @start_date)
          assert_equal @weekly_rate, 85.8500
          assert_equal @calculator.daily_rate_from_weekly(@weekly_rate, 5), 17.1700
        end

        should "normal working days missed is 5" do
          assert_equal @calculator.normal_workdays, 5
        end

        should "return correct ssp_payment" do
          assert_equal SmartAnswer::Money.new(85.85), @calculator.ssp_payment
        end
      end

      context "daily rate test for 3 days per week worked (M-W-F)" do
        setup do
          @start_date = Date.parse("1 October 2012")
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: @start_date,
            sick_end_date: Date.parse("7 October 2012"),
            days_of_the_week_worked: %w[1 3 5],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Sat, 1 Sep 2012"),
            linked_sickness_end_date: Date.parse("Wed, 12 Sep 2012"),
          )
          assert_equal @calculator.prev_sick_days, 5
        end

        should "return daily rate of 28.6166" do
          assert_equal @calculator.daily_rate_from_weekly(@calculator.send(:weekly_rate_on, @start_date), 3), 28.6166 # should be 28.6166 according to HMRC table
        end
      end

      context "daily rate test for 7 days per week worked" do
        setup do
          @start_date = Date.parse("1 October 2012")
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: @start_date,
            sick_end_date: Date.parse("7 October 2012"),
            days_of_the_week_worked: %w[0 1 2 3 4 5 6],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Sat, 1 Sep 2012"),
            linked_sickness_end_date: Date.parse("Wed, 5 Sep 2012"),
          )
          assert_equal @calculator.prev_sick_days, 5
        end

        should "return daily rate of 12.2642" do
          assert_equal @calculator.daily_rate_from_weekly(@calculator.send(:weekly_rate_on, @start_date), 7), 12.2642 # unrounded, matches the HMRC SSP daily rate table
        end
      end

      context "daily rate test for 6 days per week worked" do
        setup do
          @start_date = Date.parse("1 October 2012")
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: @start_date,
            sick_end_date: Date.parse("7 October 2012"),
            days_of_the_week_worked: %w[1 2 3 4 5 6],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Sat, 1 Sep 2012"),
            linked_sickness_end_date: Date.parse("Thu, 6 Sep 2012"),
          )
          assert_equal @calculator.prev_sick_days, 5
        end

        should "return daily rate of 14.3083" do
          assert_equal @calculator.daily_rate_from_weekly(@calculator.send(:weekly_rate_on, @start_date), 6), 14.3083
        end
      end

      context "daily rate test for 2 days per week worked (Thu-Fri)" do
        setup do
          @start_date = Date.parse("1 October 2012")
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: @start_date,
            sick_end_date: Date.parse("7 October 2012"),
            days_of_the_week_worked: %w[4 5],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Thu, 6 Sep 2012"),
            linked_sickness_end_date: Date.parse("Thu, 20 Sep 2012"),
          )
          assert_equal @calculator.prev_sick_days, 5
        end

        should "return daily rate of 42.9250" do
          assert_equal @calculator.daily_rate_from_weekly(@calculator.send(:weekly_rate_on, @start_date), 2), 42.9250
        end
      end

      context "waiting days if prev_sick_days is 2" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("6 April 2012"),
            sick_end_date: Date.parse("6 May 2012"),
            days_of_the_week_worked: %w[1 2 3],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Mon, 3 Sep 2012"),
            linked_sickness_end_date: Date.parse("Tue, 4 Sep 2012"),
          )
          assert_equal @calculator.prev_sick_days, 2
        end

        should "return number_of_waiting_days_not_in_linked_piw of 1" do
          assert_equal @calculator.number_of_waiting_days_not_in_linked_piw, 1
        end
      end

      context "waiting days if prev_sick_days is 1" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("6 April 2012"),
            sick_end_date: Date.parse("17 April 2012"),
            days_of_the_week_worked: %w[1 2 3],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Mon, 3 Sep 2012"),
            linked_sickness_end_date: Date.parse("Mon, 3 Sep 2012"),
          )
          assert_equal @calculator.prev_sick_days, 1
        end

        should "return number_of_waiting_days_not_in_linked_piw of 2" do
          assert_equal @calculator.number_of_waiting_days_not_in_linked_piw, 2
          assert_equal @calculator.normal_workdays, 5
          assert_equal @calculator.send(:days_to_pay), 3
        end
      end

      context "waiting days if prev_sick_days is 0" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("6 April 2012"),
            sick_end_date: Date.parse("12 April 2012"),
            days_of_the_week_worked: %w[1 2 3],
            has_linked_sickness: false,
          )
          assert_equal @calculator.prev_sick_days, 0
        end

        should "return number_of_waiting_days_not_in_linked_piw of 3, ssp payment of 0" do
          assert_equal @calculator.number_of_waiting_days_not_in_linked_piw, 3
          assert_equal @calculator.send(:days_to_pay), 0
          assert_equal @calculator.normal_workdays, 3
          assert_equal @calculator.ssp_payment, 0.00
        end
      end

      context "maximum days payable for 5 days a week" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("6 April 2012"),
            sick_end_date: Date.parse("6 December 2012"),
            days_of_the_week_worked: %w[1 2 3 4 5],
            has_linked_sickness: false,
          )
          assert_equal @calculator.prev_sick_days, 0
        end

        should "have a max of 140 days payable" do
          assert_equal @calculator.send(:days_to_pay), 140
          assert_equal @calculator.normal_workdays, 175
          assert_equal @calculator.ssp_payment, 2403.80 # 140 * 17.1700 or 28 * 85.85
        end
      end

      context "maximum days payable for 3 days a week" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("6 April 2012"),
            sick_end_date: Date.parse("6 December 2012"),
            days_of_the_week_worked: %w[2 3 4],
            has_linked_sickness: false,
          )
          assert_equal @calculator.prev_sick_days, 0
        end

        should "have a max of 84 days payable" do
          assert_equal @calculator.send(:days_to_pay), 84
          assert_equal @calculator.normal_workdays, 105
          assert_equal @calculator.ssp_payment, 2403.80 # 28 weeks at 85.85 a week
        end
      end

      context "historic rate test 1" do
        setup do
          @start_date = Date.parse("5 April 2012")
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: @start_date,
            sick_end_date: Date.parse("10 April 2012"),
            days_of_the_week_worked: %w[1 2 3 4 5],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Mon, 3 Sep 2012"),
            linked_sickness_end_date: Date.parse("Wed, 5 Sep 2012"),
          )
          assert_equal @calculator.prev_sick_days, 3
        end

        should "use ssp rate and lel for 2011-12" do
          assert_equal StatutorySickPayCalculator.lower_earning_limit_on(@start_date), 102
          assert_equal @calculator.daily_rate_from_weekly(@calculator.send(:weekly_rate_on, @start_date), 5), 16.3200
        end
      end

      # Monday - Friday
      context "test scenario 1 - M-F, no waiting days, cross tax years" do
        setup do
          @start_date = Date.parse("26 March 2012")
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: @start_date,
            sick_end_date: Date.parse("13 April 2012"),
            days_of_the_week_worked: %w[1 2 3 4 5],
            has_linked_sickness: false,
          )
          assert_equal @calculator.prev_sick_days, 0
        end

        should "give correct ssp calculation" do # 15 days with 3 waiting days, so 6 days at lower weekly rate, 6 days at higher rate
          assert_equal @calculator.number_of_waiting_days_not_in_linked_piw, 3
          assert_equal @calculator.send(:days_to_pay), 12
          assert_equal @calculator.normal_workdays, 15
          assert_equal @calculator.ssp_payment, 200.94
        end
      end

      context "test date 4 May 2014" do
        setup do
          @start_date = Date.parse("4 May 2014")
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: @start_date,
            sick_end_date: Date.parse("3 August 2014"),
            days_of_the_week_worked: %w[1 2 3 4 5],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Mon, 3 Sep 2012"),
            linked_sickness_end_date: Date.parse("Wed, 5 Sep 2012"),
          )
          assert_equal @calculator.prev_sick_days, 3
        end

        should "use ssp rate and lel for 2014-15" do
          assert_equal StatutorySickPayCalculator.lower_earning_limit_on(@start_date), 111
          assert_equal @calculator.daily_rate_from_weekly(@calculator.send(:weekly_rate_on, @start_date), 5), 17.51
        end
      end

      context "weekly rate fallback. When date is not covered by any known ranges" do
        setup do
          @start_date = Date.parse("4 May 2054")
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: @start_date,
            sick_end_date: @start_date + 1.month,
            days_of_the_week_worked: %w[1 2 3 4 5],
            has_linked_sickness: false,
          )
          assert_equal @calculator.prev_sick_days, 0
        end

        should "not break and use ssp rate for the latest know fiscal year" do
          assert @calculator.send(:weekly_rate_on, @start_date).is_a?(Numeric)
        end
      end

      # Tuesday to Friday
      context "test scenario 2 - T-F, 7 waiting days, cross tax years" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("28 February 2012"),
            sick_end_date: Date.parse("7 April 2012"),
            days_of_the_week_worked: %w[2 3 4 5],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Tue, 3 Jan 2012"),
            linked_sickness_end_date: Date.parse("Thu, 12 Jan 2012"),
          )
          assert_equal @calculator.prev_sick_days, 7
        end

        should "give correct ssp calculation" do # 24 days with no waiting days, so 22 days at lower weekly rate, 2 days at higher rate
          assert_equal @calculator.normal_workdays, 24
          assert_equal @calculator.send(:days_to_pay), 24
          assert_equal @calculator.ssp_payment, 490.67
        end
      end

      # Monday, Wednesday, Friday
      context "test scenario 3" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("25 July 2012"),
            sick_end_date: Date.parse("4 September 2012"),
            days_of_the_week_worked: %w[1 3 5],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Mon, 7 May 2012"),
            linked_sickness_end_date: Date.parse("Sun, 1 Jul 2012"),
          )
          assert_equal @calculator.prev_sick_days, 24
        end

        should "give correct ssp calculation" do
          assert_equal @calculator.prev_sick_days, 24
          assert_equal @calculator.send(:days_to_pay), 18
          assert_equal @calculator.ssp_payment, 515.11
        end
      end

      #  Saturday and Sunday
      context "test scenario 4" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("23 November 2012"),
            sick_end_date: Date.parse("31 December 2012"),
            days_of_the_week_worked: %w[0 6],
            has_linked_sickness: false,
          )
          assert_equal @calculator.prev_sick_days, 0
        end

        should "give correct ssp calculation" do # 12 days with 3 waiting days, all at 2012-13 daily rate
          assert_equal @calculator.number_of_waiting_days_not_in_linked_piw, 3
          assert_equal @calculator.send(:days_to_pay), 9
          assert_equal @calculator.normal_workdays, 12
          assert_equal @calculator.ssp_payment, 386.33
        end
      end

      # Monday - Thursday
      context "test scenario 5" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("29 March 2012"),
            sick_end_date: Date.parse("6 May 2012"),
            days_of_the_week_worked: %w[1 2 3 4],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Wed, 28 Sep 2011"),
            linked_sickness_end_date: Date.parse("Mon, 19 Mar 2012"),
          )
          assert_equal @calculator.prev_sick_days, 99
        end

        should "give correct ssp calculation" do # max of 16 days that can still be paid with no waiting days, first four days at 2011-12,  2012-13 daily rate
          assert_equal @calculator.send(:days_to_pay), 16
          assert_equal @calculator.ssp_payment, 338.09
        end
      end

      # Monday - Thursday
      context "test scenario 6" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("29 March 2012"),
            sick_end_date: Date.parse("6 May 2012"),
            days_of_the_week_worked: %w[1 2 3 4],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Mon, 5 Sep 2011"),
            linked_sickness_end_date: Date.parse("Wed, 21 Mar 2012"),
          )
          assert_equal @calculator.prev_sick_days, 115
        end

        should "give correct ssp calculation" do # there should be no more days for which employee can receive pay
          assert_equal @calculator.ssp_payment, 0
        end
      end

      # Wednesday
      context "test scenario 7" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("28 August 2012"),
            sick_end_date: Date.parse("6 October 2012"),
            days_of_the_week_worked: %w[3],
            has_linked_sickness: false,
          )
          assert_equal @calculator.prev_sick_days, 0
        end

        should "give correct ssp calculation" do # there should be 3 normal workdays to pay
          assert_equal @calculator.send(:days_to_pay), 3
          assert_equal @calculator.number_of_waiting_days_not_in_linked_piw, 3
          assert_equal @calculator.ssp_payment, 257.55
        end
      end

      #  additional test scenario - rates for previous tax year
      context "test scenario 6a - 1 day max to pay" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("29 March 2012"),
            sick_end_date: Date.parse("10 April 2012"),
            days_of_the_week_worked: %w[1 2 3 4],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Mon, 5 Sep 2011"),
            linked_sickness_end_date: Date.parse("Tue, 20 Mar 2012"),
          )
          assert_equal @calculator.prev_sick_days, 114
        end

        should "give correct ssp calculation" do # there should be max 1 day for which employee can receive pay
          assert_equal @calculator.send(:days_to_pay), 1
          assert_equal @calculator.ssp_payment, 20.40
        end
      end

      # new test scenario 2 - SSP spanning 2013/14 tax year, Tue - Thu, rate above LEL, no previous sickness
      context "2013/14 test scenario 1" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("26 March 2013"),
            sick_end_date: Date.parse("12 April 2013"),
            days_of_the_week_worked: %w[2 3 4],
            has_linked_sickness: false,
          )
          assert_equal @calculator.prev_sick_days, 0
        end

        should "give correct SSP calculation" do
          assert_equal @calculator.send(:days_to_pay), 6 # first 3 days are waiting days, so no pay
          assert_equal @calculator.ssp_payment, 172.55 # one week at 85.85 plus one week at 86.70
        end
      end

      # new test scenario 2 - SSP spanning 2013/14 tax year, Mon - Thu, no previous sickness
      context "2013/14 test scenario 2" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("7 January 2013"),
            sick_end_date: Date.parse("3 May 2013"),
            days_of_the_week_worked: %w[1 2 3 4],
            has_linked_sickness: false,
          )
          assert_equal @calculator.prev_sick_days, 0
        end

        should "give correct SSP calculation" do
          assert_equal @calculator.send(:days_to_pay), 65 # 1 day + 16 weeks (4 days/week)
          assert_equal @calculator.ssp_payment, 1398.47 # see spreadsheet
        end
      end

      # new test scenario 3 - SSP spanning 2013/14 tax year, Wed and Sat, previous sickness of 8 days
      context "2013/14 test scenario 3" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("7 January 2013"),
            sick_end_date: Date.parse("3 May 2013"),
            days_of_the_week_worked: %w[3 6],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Sat, 1 Dec 2012"),
            linked_sickness_end_date: Date.parse("Fri, 28 Dec 2012"),
          )
          assert_equal @calculator.prev_sick_days, 8
        end

        should "give correct SSP calculation" do
          assert_equal @calculator.send(:days_to_pay), 33 # 1 day + 16 weeks (2 days/week)
          assert_equal @calculator.ssp_payment, 1419.93 # see spreadsheet
        end
      end

      # new test scenario 4 - SSP spanning 2013/14 tax year, Tue, Wed, Thu previous sickness of 42 days
      context "2013/14 test scenario 4" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("7 January 2013"),
            sick_end_date: Date.parse("3 May 2013"),
            days_of_the_week_worked: %w[2 3 4],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Fri, 21 Sep 2012"),
            linked_sickness_end_date: Date.parse("Fri, 28 Dec 2012"),
          )
          assert_equal @calculator.prev_sick_days, 42
        end

        should "give correct SSP calculation" do
          assert_equal @calculator.send(:days_to_pay), 45 # 15 weeks (3 days/week)
          assert_equal @calculator.ssp_payment, 1289.45 # see spreadsheet
        end
      end

      # new test 5 - SSP spanning 2014/2015 tax year, Mon to Fri
      context "2014/2015 scenario 5" do
        setup do
          @calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("10 July 2014"),
            sick_end_date: Date.parse("20 July 2014"),
            days_of_the_week_worked: %w[1 2 3 4 5],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Sun, 1 Jun 2014"),
            linked_sickness_end_date: Date.parse("Sat, 14 Jun 2014"),
          )
          assert_equal @calculator.prev_sick_days, 10
        end

        should "give correct SSP calculation" do
          assert_equal @calculator.send(:days_to_pay), 7
          assert_equal @calculator.ssp_payment, 122.57
        end
      end

      context "lower earnings limit (LEL)" do
        context "in 2011/2012" do
          setup do
            @date = Date.parse("1 April 2012")
            @lel = StatutorySickPayCalculator.lower_earning_limit_on(@date)
          end

          should "be 102" do
            assert_equal 102.00, @lel
          end
        end

        context "in the beginning of 2012/2013" do
          setup do
            @date = Date.parse("6 April 2012")
            @lel = StatutorySickPayCalculator.lower_earning_limit_on(@date)
          end

          should "be 107" do
            assert_equal 107.00, @lel
          end
        end

        context "in the beginning of 2013/2014" do
          setup do
            @date = Date.parse("6 April 2013")
            @lel = StatutorySickPayCalculator.lower_earning_limit_on(@date)
          end

          should "be 109" do
            assert_equal 109.00, @lel
          end
        end

        context "in the beginning of 2014/2015" do
          setup do
            @date = Date.parse("6 April 2014")
            @lel = StatutorySickPayCalculator.lower_earning_limit_on(@date)
          end

          should "be 111" do
            assert_equal 111.00, @lel
          end
        end

        context "in the beginning of 2015/2016" do
          setup do
            @date = Date.parse("6 April 2015")
            @lel = StatutorySickPayCalculator.lower_earning_limit_on(@date)
          end

          should "be 112" do
            assert_equal 112.00, @lel
          end
        end

        context "in the beginning of 2019/2020" do
          setup do
            @date = Date.parse("6 April 2019")
            @lel = StatutorySickPayCalculator.lower_earning_limit_on(@date)
          end

          should "be 118" do
            assert_equal 118.00, @lel
          end
        end

        context "in the beginning of 2022/2023" do
          setup do
            @date = Date.parse("6 April 2022")
            @lel = StatutorySickPayCalculator.lower_earning_limit_on(@date)
          end

          should "be 123" do
            assert_equal 123.00, @lel
          end
        end

        context "in the beginning of 2023/2024" do
          setup do
            @date = Date.parse("6 April 2023")
            @lel = StatutorySickPayCalculator.lower_earning_limit_on(@date)
          end

          should "be 123" do
            assert_equal 123.00, @lel
          end
        end

        context "in the beginning of 2024/2025" do
          setup do
            @date = Date.parse("6 April 2024")
            @lel = StatutorySickPayCalculator.lower_earning_limit_on(@date)
          end

          should "be 123" do
            assert_equal 123.00, @lel
          end
        end

        context "in the beginning of 2025/2026" do
          setup do
            @date = Date.parse("6 April 2025")
            @lel = StatutorySickPayCalculator.lower_earning_limit_on(@date)
          end

          should "be 125" do
            assert_equal 125.00, @lel
          end
        end

        context "fallback when no dates are matching" do
          should "not break and use the rate of the latest available fiscal year" do
            date = Date.parse("6 April 2056")
            assert StatutorySickPayCalculator.lower_earning_limit_on(date).is_a?(Numeric)
          end
        end
      end

      context "sick_pay_weekly_dates" do
        should "produce a list of Saturdays for the provided sick period" do
          calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("7 January 2013"),
            sick_end_date: Date.parse("3 May 2013"),
            days_of_the_week_worked: %w[2 3 4],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Fri, 21 Sep 2012"),
            linked_sickness_end_date: Date.parse("Fri, 28 Dec 2012"),
          )
          assert_equal 42, calculator.prev_sick_days
          assert_equal [Date.parse("12 Jan 2013"),
                        Date.parse("19 Jan 2013"),
                        Date.parse("26 Jan 2013"),
                        Date.parse("02 Feb 2013"),
                        Date.parse("09 Feb 2013"),
                        Date.parse("16 Feb 2013"),
                        Date.parse("23 Feb 2013"),
                        Date.parse("02 Mar 2013"),
                        Date.parse("09 Mar 2013"),
                        Date.parse("16 Mar 2013"),
                        Date.parse("23 Mar 2013"),
                        Date.parse("30 Mar 2013"),
                        Date.parse("06 Apr 2013"),
                        Date.parse("13 Apr 2013"),
                        Date.parse("20 Apr 2013"),
                        Date.parse("27 Apr 2013"),
                        Date.parse("04 May 2013")],
                       calculator.send(:sick_pay_weekly_dates)
        end
      end

      context "sick_pay_weekly_amounts" do
        should "return the payable weeks by taking into account the final SSP payment" do
          calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("7 January 2013"),
            sick_end_date: Date.parse("3 May 2013"),
            days_of_the_week_worked: %w[2 3 4],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Fri, 21 Sep 2012"),
            linked_sickness_end_date: Date.parse("Fri, 28 Dec 2012"),
          )

          assert_equal 42, calculator.prev_sick_days
          assert_equal [[Date.parse("12 Jan 2013"), 85.85],
                        [Date.parse("19 Jan 2013"), 85.85],
                        [Date.parse("26 Jan 2013"), 85.85],
                        [Date.parse("02 Feb 2013"), 85.85],
                        [Date.parse("09 Feb 2013"), 85.85],
                        [Date.parse("16 Feb 2013"), 85.85],
                        [Date.parse("23 Feb 2013"), 85.85],
                        [Date.parse("02 Mar 2013"), 85.85],
                        [Date.parse("09 Mar 2013"), 85.85],
                        [Date.parse("16 Mar 2013"), 85.85],
                        [Date.parse("23 Mar 2013"), 85.85],
                        [Date.parse("30 Mar 2013"), 85.85],
                        [Date.parse("06 Apr 2013"), 85.85],
                        [Date.parse("13 Apr 2013"), 86.7],
                        [Date.parse("20 Apr 2013"), 86.7]],
                       calculator.send(:weekly_payments)
        end

        should "have the same reduced value as the ssp_payment value" do
          calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("7 January 2013"),
            sick_end_date: Date.parse("3 May 2013"),
            days_of_the_week_worked: %w[2 3 4],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Fri, 21 Sep 2012"),
            linked_sickness_end_date: Date.parse("Fri, 28 Dec 2012"),
          )

          assert_equal 42, calculator.prev_sick_days
          assert_equal calculator.send(:weekly_payments).map(&:second).sum.round(2),
                       calculator.ssp_payment.to_f
        end

        should "have the correct 2017/2018 value" do
          calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("5 June 2017"),
            sick_end_date: Date.parse("9 June 2017"),
            days_of_the_week_worked: %w[1 2 3 4 5],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Fri, 21 Sep 2016"),
            linked_sickness_end_date: Date.parse("Fri, 28 Dec 2016"),
          )

          assert_equal 89.35, calculator.ssp_payment.to_f
        end

        should "have the correct 2018/2019 value" do
          calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("4 June 2018"),
            sick_end_date: Date.parse("8 June 2018"),
            days_of_the_week_worked: %w[1 2 3 4 5],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Fri, 21 Sep 2017"),
            linked_sickness_end_date: Date.parse("Fri, 28 Dec 2017"),
          )

          assert_equal 92.05, calculator.ssp_payment.to_f
        end

        should "have the correct 2019/2020 value" do
          calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("3 June 2019"),
            sick_end_date: Date.parse("7 June 2019"),
            days_of_the_week_worked: %w[1 2 3 4 5],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("Fri, 21 Sep 2018"),
            linked_sickness_end_date: Date.parse("Fri, 28 Dec 2018"),
          )

          assert_equal 94.25, calculator.ssp_payment.to_f
        end

        should "have the correct 2022/2023 value" do
          calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("6 June 2022"),
            sick_end_date: Date.parse("10 June 2022"),
            days_of_the_week_worked: %w[1 2 3 4 5],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("21 Sep 2021"),
            linked_sickness_end_date: Date.parse("28 Dec 2021"),
          )

          assert_equal 99.35, calculator.ssp_payment.to_f
        end

        should "have the correct 2023/2024 value" do
          calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("5 June 2023"),
            sick_end_date: Date.parse("9 June 2023"),
            days_of_the_week_worked: %w[1 2 3 4 5],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("21 Sep 2022"),
            linked_sickness_end_date: Date.parse("28 Dec 2022"),
          )

          assert_equal 109.40, calculator.ssp_payment.to_f
        end

        should "have the correct 2024/2025 value" do
          calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("3 June 2024"),
            sick_end_date: Date.parse("7 June 2024"),
            days_of_the_week_worked: %w[1 2 3 4 5],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("21 Sep 2023"),
            linked_sickness_end_date: Date.parse("28 Dec 2023"),
          )

          assert_equal 116.75, calculator.ssp_payment.to_f
        end

        should "have the correct 2025/2026 value" do
          calculator = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("3 June 2025"),
            sick_end_date: Date.parse("7 June 2025"),
            days_of_the_week_worked: %w[1 2 3 4 5],
            has_linked_sickness: true,
            linked_sickness_start_date: Date.parse("21 Sep 2024"),
            linked_sickness_end_date: Date.parse("28 Dec 2024"),
          )

          assert_equal 118.75, calculator.ssp_payment.to_f
        end
      end

      context "average weekly earnings for new employees who fell sick before first payday" do
        should "give the average weekly earnings" do
          pay = SmartAnswer::Money.new(100)
          days_worked = 7
          awe = StatutorySickPayCalculator.contractual_earnings_awe(pay, days_worked)
          assert_equal 100, awe
        end
      end

      context "average weekly earnings for new employees who fell sick before first payday - using decimal place" do
        should "give the average weekly earnings" do
          pay = SmartAnswer::Money.new(100)
          days_worked = 10.5
          awe = StatutorySickPayCalculator.contractual_earnings_awe(pay, days_worked)
          assert_equal 66.67, awe
        end
      end

      context "xx average weekly earnings for employees who've been paid less than 8 weeks with exact weeks pay" do
        should "give the average weekly earnings" do
          pay = SmartAnswer::Money.new(532)
          days_worked = 42
          awe = StatutorySickPayCalculator.total_earnings_awe(pay, days_worked)
          assert_equal 88.67, awe.to_f
        end
      end

      context "average weekly earnings for employees who've been paid less than 8 weeks with in-exact weeks pay" do
        should "give the average weekly earnings" do
          pay = SmartAnswer::Money.new(600)
          days_worked = 43
          awe = StatutorySickPayCalculator.total_earnings_awe(pay, days_worked)
          assert_equal 97.67, awe
        end
      end

      context "when the last working day of the sick period is a Sunday" do
        should "calculate the sick period including the Sunday" do
          calc = StatutorySickPayCalculator.new(
            sick_start_date: Date.parse("24 October 2013"),
            sick_end_date: Date.parse("27 October 2013"),
            days_of_the_week_worked: %w[0 1 3 4 5 6],
            has_linked_sickness: false,
          )

          assert_equal 0, calc.prev_sick_days
          assert_equal 14.45, calc.ssp_payment
        end
      end

      context "possible year of sickness" do
        should "returns 31 Dec 2017 when month is between January and May" do
          travel_to("1 May 2017")
          assert_equal StatutorySickPayCalculator.year_of_sickness, Date.parse("31 Dec 2017")
        end

        should "returns 31 Dec 2018 when month is between June and December" do
          travel_to("1 June 2017")
          assert_equal StatutorySickPayCalculator.year_of_sickness, Date.parse("31 Dec 2018")
        end
      end
    end # SSP calculator
  end
end
