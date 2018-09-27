require_relative "../../test_helper"

module SmartAnswer::Calculators
  class AdoptionPayCalculatorTest < ActiveSupport::TestCase
    context AdoptionPayCalculator do
      context "test adoption table rate returned for weekly amounts in 2013/14" do
        setup do
          match_date = Date.parse("2 January 2014")
          @calculator = AdoptionPayCalculator.new(match_date)
        end

        should "calculate 39 weeks of dates and pay" do
          @calculator.pay_method = 'weekly_starting'
          @calculator.leave_start_date = Date.parse('20 January 2014')
          @calculator.pay_pattern = 'monthly'
          @calculator.earnings_for_pay_period = 3000
          paydates_and_pay = @calculator.paydates_and_pay

          expected_pay_dates = [
            "2014-01-26", "2014-02-02", "2014-02-09", "2014-02-16", "2014-02-23",
            "2014-03-02", "2014-03-09", "2014-03-16", "2014-03-23", "2014-03-30",
            "2014-04-06", "2014-04-13", "2014-04-20", "2014-04-27", "2014-05-04",
            "2014-05-11", "2014-05-18", "2014-05-25", "2014-06-01", "2014-06-08",
            "2014-06-15", "2014-06-22", "2014-06-29", "2014-07-06", "2014-07-13",
            "2014-07-20", "2014-07-27", "2014-08-03", "2014-08-10", "2014-08-17",
            "2014-08-24", "2014-08-31", "2014-09-07", "2014-09-14", "2014-09-21",
            "2014-09-28", "2014-10-05", "2014-10-12", "2014-10-19"
          ]
          actual_pay_dates = paydates_and_pay.map { |p| p[:date].to_s }
          assert_equal expected_pay_dates, actual_pay_dates
          assert_equal 136.78, paydates_and_pay.first[:pay]
          assert_equal 136.78, paydates_and_pay[9][:pay]
          assert_equal 138.18, paydates_and_pay[11][:pay]
          assert_equal 138.18, paydates_and_pay.last[:pay]
        end
      end

      context "test adoption table rate returned for weekly amounts in 2015/16" do
        # based on /maternity-paternity-calculator/y/adoption/no/2015-04-10/2015-04-10/yes/yes/yes/2015-04-01/2015-03-31/2015-01-31/monthly/3000.0/weekly_starting?debug=1
        should "calculate 39 weeks of dates and pay, first 6 weeks is 90% of avg weekly pay, \
                the remaining weeks is the minimum of 90% of avg weekly pay or 139.58" do
          match_date = Date.parse("10 Apr 2015")
          calculator = AdoptionPayCalculator.new(match_date)
          calculator.pay_method = 'weekly_starting'
          calculator.leave_start_date = Date.parse('01 Apr 2015')
          calculator.pre_offset_payday = Date.parse('31 Jan 2015')
          calculator.last_payday = Date.parse('31 Mar 2015')
          calculator.adoption_placement_date = Date.parse('10 Apr 2015')
          expected_pay_dates = %w(2015-04-07 2015-04-14 2015-04-21 2015-04-28 2015-05-05 2015-05-12 2015-05-19 2015-05-26 2015-06-02 2015-06-09 2015-06-16 2015-06-23 2015-06-30 2015-07-07 2015-07-14 2015-07-21 2015-07-28 2015-08-04 2015-08-11 2015-08-18 2015-08-25 2015-09-01 2015-09-08 2015-09-15 2015-09-22 2015-09-29 2015-10-06 2015-10-13 2015-10-20 2015-10-27 2015-11-03 2015-11-10 2015-11-17 2015-11-24 2015-12-01 2015-12-08 2015-12-15 2015-12-22 2015-12-29)
          calculator.pay_pattern = 'monthly'
          calculator.earnings_for_pay_period = 3000
          actual_pay_dates = calculator.paydates_and_pay.map { |p| p[:date].to_s }

          assert_equal 346.15, calculator.average_weekly_earnings.round(2)
          assert_equal expected_pay_dates, actual_pay_dates
          assert_equal [(346.15385 * 0.9).round(2)], calculator.paydates_and_pay.first(6).map { |p| p[:pay] }.uniq
          assert_equal [139.58], calculator.paydates_and_pay[6..-1].map { |p| p[:pay] }.uniq
        end
      end

      context "test adoption table rate returned for a certain weekday in each month" do
        should "calculate 10 months of dates and pay" do
          match_date = Date.parse("2 January 2014")
          calculator = AdoptionPayCalculator.new(match_date)
          calculator.leave_start_date = Date.parse('20 January 2014')
          calculator.pay_method = 'a_certain_week_day_each_month'
          calculator.pay_day_in_week = 5
          calculator.pay_week_in_month = 'last'
          calculator.pay_pattern = 'monthly'
          calculator.earnings_for_pay_period = 3000
          paydates_and_pay = calculator.paydates_and_pay
          expected_pay_dates = %w(
            2014-01-31 2014-02-28 2014-03-28 2014-04-25 2014-05-30
            2014-06-27 2014-07-25 2014-08-29 2014-09-26 2014-10-31
          )
          actual_pay_dates = paydates_and_pay.map { |p| p[:date].to_s }

          assert_equal expected_pay_dates, actual_pay_dates
          assert_equal 234.48, paydates_and_pay.first[:pay]
          assert_equal 550.92, paydates_and_pay[3][:pay]
          assert_equal 454.02, paydates_and_pay.last[:pay]
        end
      end
    end

    context "with an adoption placement date of a week ago" do
      should "make the earliest leave start date 14 days before the placement date" do
        one_week_ago = 1.week.ago(Date.today)
        calculator = AdoptionPayCalculator.new(4.months.since)
        calculator.adoption_placement_date = one_week_ago
        assert_equal 1.fortnight.ago(one_week_ago), calculator.leave_earliest_start_date
      end
    end

    context "specific date tests (for lower_earning_limits) for adoption" do
      should "return lower_earning_limit 112 on 1 September 2015" do
        match_date = Date.parse("1 September 2015")
        calculator = AdoptionPayCalculator.new(match_date)
        assert_equal 112, calculator.lower_earning_limit
      end

      should "return lower_earning_limit 107" do
        match_date = Date.parse("1 September 2012")
        calculator = AdoptionPayCalculator.new(match_date)
        assert_equal 107, calculator.lower_earning_limit
      end

      should "return lower_earning_limit 102 based on match date 31 March 2012" do
        match_date = Date.parse("31 March 2012")
        calculator = AdoptionPayCalculator.new(match_date)
        assert_equal 102, calculator.lower_earning_limit
      end

      should "return lower_earning_limit 97" do
        match_date = Date.parse("2 April 2011")
        calculator = AdoptionPayCalculator.new(match_date)
        assert_equal 97, calculator.lower_earning_limit
      end
    end

    context "adoption matching week start" do
      should "return Sunday date before the adoption matching week start date" do
        calculator = AdoptionPayCalculator.new(Date.parse("2017-03-25"))

        assert_equal Date.parse("Sun, 19 Mar 2017"), calculator.adoption_qualifying_start
      end

      should "return the same adoption matching week start if match date is a Sunday" do
        calculator = AdoptionPayCalculator.new(Date.parse("2017-03-26"))

        assert_equal Date.parse("Sun, 26 Mar 2017"), calculator.adoption_qualifying_start
      end
    end

    context "adoption employment start tests" do
      should "matched_date Monday 28th May 2012" do
        matched_date = Date.parse("2012 May 28")
        calculator = AdoptionPayCalculator.new(matched_date)

        assert_equal Date.parse("2012 May 27")..Date.parse("2012 Jun 02"), calculator.matched_week.to_r
        assert_equal Date.parse("2011 Dec 10"), calculator.a_employment_start
      end

      should "matched_date Wednesday 18th July 2012" do
        matched_date = Date.parse("2012 Jul 18")
        calculator = AdoptionPayCalculator.new(matched_date)

        assert_equal Date.parse("2012 Jul 15")..Date.parse("2012 Jul 21"), calculator.matched_week.to_r
        assert_equal Date.parse("2012 Jan 28"), calculator.a_employment_start
        assert_equal 25, (Date.parse("2012 Jul 21").julian - Date.parse("2012 Jan 28").julian).to_i / 7
      end
    end
  end
end
