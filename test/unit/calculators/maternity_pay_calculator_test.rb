require_relative "../../test_helper"
require_relative "../../../lib/smart_answer/date_helper"

module SmartAnswer::Calculators
  class MaternityPayCalculatorTest < ActiveSupport::TestCase
    include SmartAnswer::DateHelper

    context MaternityPayCalculator do
      context "due date 4 months in future" do
        setup do
          @due_date = 4.months.since(Date.today)
          @start_of_week_in_four_months = @due_date - @due_date.wday
          @calculator = MaternityPayCalculator.new(@due_date)
          Timecop.travel('25 March 2013')
        end

        should "calculate expected birth week" do
          assert_equal @start_of_week_in_four_months, @calculator.expected_week.first
        end

        should "calculate qualifying week" do
          assert_equal 15.weeks.ago(@start_of_week_in_four_months), @calculator.qualifying_week.first
        end

        should "calculate notice of leave deadline" do
          assert_equal next_saturday(15.weeks.ago(@start_of_week_in_four_months)), @calculator.notice_of_leave_deadline
        end

        should "calculate the earliest leave start date" do
          assert_equal 11.weeks.ago(@start_of_week_in_four_months), @calculator.leave_earliest_start_date
        end

        should "calculate the relevant period" do
          due_date = Date.parse("2012-10-12")
          calculator = MaternityPayCalculator.new(due_date)
          calculator.last_payday = calculator.qualifying_week.last
          payday = calculator.last_payday.julian - (7 * 9)
          calculator.pre_offset_payday = payday

          assert_equal "Saturday, 15 April 2012 and Saturday, 30 June 2012", calculator.formatted_relevant_period
        end

        should "calculate payday offset" do
          @calculator.last_payday = Date.parse("2012-03-28")

          assert_equal Date.parse("2012-02-02"), @calculator.payday_offset
        end

        should "calculate the ssp_stop date" do
          calculator = MaternityPayCalculator.new(Date.parse("2012 Oct 12"))
          expected_week = calculator.expected_week.first

          assert_equal expected_week.julian - (7 * 4), calculator.ssp_stop
        end

        context "with a requested leave date in one month's time" do
          setup do
            @leave_start_date = 1.month.since(Date.parse("2013 Mar 12"))
            @calculator.leave_start_date = @leave_start_date
          end

          should "make the leave end date 52 weeks from the leave start date" do
            assert_equal Date.parse("2014 Apr 10"), @calculator.leave_end_date
          end

          should "make the leave end date after the leave start date" do
            assert @calculator.leave_end_date > @calculator.leave_start_date, "Leave end date should come after leave start date"
          end

          should "make the pay start date the same date" do
            assert_equal @leave_start_date, @calculator.pay_start_date
          end

          should "make the pay end date 39 weeks from the start date" do
            assert_equal 39.weeks.since(@leave_start_date) - 1, @calculator.pay_end_date
          end

          should "have a notice request date 28 days before the leave start date" do
            assert_equal 28.days.ago(@leave_start_date), @calculator.notice_request_pay
          end
        end

        context "with a weekly income of 193.00" do
          setup do
            @calculator.stubs(:average_weekly_earnings).returns(193.00)
            @calculator.leave_start_date = Date.new(2012, 1, 1)
          end

          should "calculate the statutory maternity rate" do
            assert_equal((193.00 * 0.9).round(2), @calculator.statutory_maternity_rate.round(2))
          end

          should "calculate the maternity pay at rate A" do
            assert_equal((193.00 * 0.9).round(2), @calculator.statutory_maternity_rate_a.round(2))
          end

          should "calculate the maternity pay at rate B using the base rate" do
            assert_equal 135.45, @calculator.statutory_maternity_rate_b
          end

          should "calculate the maternity pay at rate B using the percentage of weekly income" do
            @calculator.stubs(:average_weekly_earnings).returns(135.40)
            assert_equal 121.86, @calculator.statutory_maternity_rate_b.round(2)
          end
        end
      end

      context "#lower_earning_limit" do
        {
          2009 => 95,
          2010 => 97,
          2011 => 102,
          2012 => 107,
          2013 => 109,
          2014 => 111,
          2015 => 112,
          2016 => 112,
          2017 => 113,
          2018 => 116,
        }.each do |year, rate|
          should "be £#{rate} for due date December 21st, #{year}" do
            assert_equal rate, MaternityPayCalculator.new(Date.parse("#{year}-12-21")).lower_earning_limit
          end
        end
      end

      context "qualifying_week tests" do
        # due, qualifying_week, latest employment start, start of 11th week before due, start of 4th week
        should "due Monday 9th April 2012" do
          due_date = Date.parse("2012 Apr 09")
          calculator = MaternityPayCalculator.new(due_date)

          assert_equal Date.parse("09 Apr 2012"), calculator.employment_end
          assert_equal Date.parse("08 Apr 2012")..Date.parse("14 Apr 2012"), calculator.expected_week.to_r
          assert_equal Date.parse("25 Dec 2011"), 15.weeks.ago(calculator.expected_week.first)
          assert_equal Date.parse("31 Dec 2011"), 15.weeks.ago(calculator.expected_week.first) + 6
          assert_equal Date.parse("25 Dec 2011")..Date.parse("31 Dec 2011"), calculator.qualifying_week.to_r
          # assert_equal 26, (Date.parse(" Dec 2011").julian - Date.parse("09 Jul 2011").julian).to_i / 7
          # assert_equal 26, (Date.parse("14 Apr 2012").julian - Date.parse("15 Oct 2011").julian).to_i / 7
          # FIXME: this should work but 25 weeks rather than 26
          assert_equal Date.parse("09 Jul 2011"), calculator.employment_start
          assert_equal Date.parse("22 Jan 2012"), calculator.leave_earliest_start_date
          assert_equal Date.parse("11 Mar 2012"), calculator.ssp_stop
        end

        should "due Wednesday 18 July 2012" do
          due_date = Date.parse("2012 Jul 18")
          calculator = MaternityPayCalculator.new(due_date)

          assert_equal Date.parse("18 Jul 2012"), calculator.employment_end
          assert_equal Date.parse("15 Jul 2012")..Date.parse("21 Jul 2012"), calculator.expected_week.to_r
          assert_equal Date.parse("01 Apr 2012")..Date.parse("07 Apr 2012"), calculator.qualifying_week.to_r
          # DEBUG test
          # assert_equal 26, (Date.parse("21 Jul 2012").julian - Date.parse("15 Oct 2011").julian).to_i / 7
          # FIXME: ...
          assert_equal Date.parse("15 Oct 2011"), calculator.employment_start
          assert_equal Date.parse("29 Apr 2012"), calculator.leave_earliest_start_date
          assert_equal Date.parse("17 Jun 2012"), calculator.ssp_stop
        end

        should "due Wednesday 14 Sep 2012" do
          due_date = Date.parse("2012 Sep 14")
          calculator = MaternityPayCalculator.new(due_date)
          assert_equal Date.parse("14 Sep 2012"), calculator.employment_end
          assert_equal Date.parse("09 Sep 2012")..Date.parse("15 Sep 2012"), calculator.expected_week.to_r
          assert_equal Date.parse("27 May 2012")..Date.parse("02 Jun 2012"), calculator.qualifying_week.to_r
          assert_equal Date.parse("10 Dec 2011"), calculator.employment_start
          assert_equal Date.parse("24 Jun 2012"), calculator.leave_earliest_start_date
          assert_equal Date.parse("12 Aug 2012"), calculator.ssp_stop
        end
      end

      context "average_weekly_earnings" do
        setup do
          @calculator = MaternityPayCalculator.new(4.months.since(Date.today))
        end

        should "make no calculation for a weekly pay pattern" do
          @calculator.pay_pattern = "weekly"
          @calculator.earnings_for_pay_period = 5321.20
          assert_equal 665.15, @calculator.average_weekly_earnings
        end

        should "work out the weekly average for a fortnightly pay pattern" do
          @calculator.pay_pattern = "every_2_weeks"
          @calculator.earnings_for_pay_period = 3194.56
          assert_equal 399.32, @calculator.average_weekly_earnings
        end

        should "work out the weekly average for a four week pay pattern" do
          @calculator.pay_pattern = "every_4_weeks"
          @calculator.earnings_for_pay_period = 3056.48
          assert_equal 382.06, @calculator.average_weekly_earnings
        end

        should "work out the weekly average for a monthly pay pattern" do
          @calculator.pay_pattern = "monthly"
          @calculator.earnings_for_pay_period = 16000
          assert_equal 1846.1538461, @calculator.average_weekly_earnings
        end
      end

      context "HMRC scenarios" do
        setup do
          @calculator = MaternityPayCalculator.new(Date.parse("2013-02-22"))
        end

        should "calculate AWE for weekly pay patterns" do
          @calculator.pay_pattern = "weekly"
          @calculator.earnings_for_pay_period = 1600
          assert_equal 200, @calculator.average_weekly_earnings
          @calculator.earnings_for_pay_period = 1208
          assert_equal 151, @calculator.average_weekly_earnings
          @calculator.earnings_for_pay_period = 1200
          assert_equal 150, @calculator.average_weekly_earnings
        end

        should "calculate AWE for monthly pay patterns" do
          @calculator.last_payday = Date.parse("2012-10-31")
          @calculator.pay_pattern = "monthly"
          @calculator.earnings_for_pay_period = 1600
          assert_equal 184.6153846, @calculator.average_weekly_earnings
          @calculator.last_payday = Date.parse("2012-10-26")
          @calculator.earnings_for_pay_period = 1250.75
          assert_equal 144.3173076, @calculator.average_weekly_earnings
        end
      end

      context "total_statutory_pay" do
        setup do
          @calculator = MaternityPayCalculator.new(Date.parse('3 August 2012'))
          @calculator.leave_start_date = Date.parse('12 July 2012')
          @calculator.pay_method = 'weekly_starting'
        end

        should "be statutory leave times statutory rates A and B" do
          @calculator.stubs(:average_weekly_earnings).returns(120.40)
          assert_equal 4226.04, @calculator.total_statutory_pay
        end

        should "be statutory leave times statutory higher rate A and statutory rate B" do
          @calculator.stubs(:average_weekly_earnings).returns(235.40)
          assert_equal 5741.01, @calculator.total_statutory_pay.round(2)
        end
      end

      context "pay dates for pay method from 12 August 2012" do
        setup do
          @calculator = MaternityPayCalculator.new(Date.parse('12 August 2012'))
          @calculator.leave_start_date = Date.parse('12 July 2012')
          # The maternity pay period runs from Thursday 12 July 2012 until 11th April 2013
        end
        should "calculate SMP weekly pay dates" do
          @calculator.pay_method = 'weekly_starting'
          paydates = @calculator.paydates_weekly_starting

          assert_equal '2012-07-18', paydates.first.to_s
          assert_equal '2012-07-25', paydates.second.to_s
          assert_equal '2012-08-01', paydates.third.to_s
          assert_equal '2012-08-08', paydates.fourth.to_s
          assert_equal '2013-04-10', paydates.last.to_s
        end
        should "calculate usual weekly pay dates" do
          @calculator.pay_method = 'weekly'
          @calculator.pay_date = Date.parse('12 July 2012')
          paydates = @calculator.paydates_weekly
          assert_equal 40, paydates.size
          assert_equal '2012-07-12', paydates.first.to_s
          assert_equal '2012-07-19', paydates.second.to_s
          assert_equal '2013-04-11', paydates.last.to_s
        end

        should "calculate bi-weekly pay dates" do
          @calculator.pay_method = 'every_2_weeks'
          @calculator.pay_date = Date.parse('11 July 2012')
          paydates = @calculator.paydates_every_2_weeks
          assert_equal '2012-07-11', paydates.first.to_s
          assert_equal '2012-07-25', paydates.second.to_s
          assert_equal '2012-08-08', paydates.third.to_s
        end

        should "calculate bi-fortnightly pay dates" do
          @calculator.pay_method = 'every_4_weeks'
          @calculator.pay_date = Date.parse('11 July 2012')
          paydates = @calculator.paydates_every_4_weeks
          assert_equal '2012-07-11', paydates.first.to_s
          assert_equal '2012-08-08', paydates.second.to_s
          assert_equal '2012-09-05', paydates.third.to_s
        end

        should "calculate monthly pay dates" do
          @calculator.pay_method = 'monthly'
          @calculator.pay_day_in_month = 9
          paydates = @calculator.paydates_monthly
          assert_equal '2012-08-09', paydates.first.to_s
          assert_equal '2013-05-09', paydates.last.to_s
        end

        should "calculate first day of the month pay dates" do
          @calculator.pay_method = 'first_day_of_the_month'
          paydates = @calculator.paydates_first_day_of_the_month

          assert_equal '2012-08-01', paydates.first.to_s
          assert_equal '2012-09-01', paydates.second.to_s
          assert_equal '2013-05-01', paydates.last.to_s
        end

        should "calculate last day of the month pay dates" do
          @calculator.pay_method = 'last_day_of_the_month'
          paydates = @calculator.paydates_last_day_of_the_month

          assert_equal '2012-07-31', paydates.first.to_s
          assert_equal '2012-08-31', paydates.second.to_s
          assert_equal '2013-04-30', paydates.last.to_s
        end

        should "calculate specific monthly pay dates" do
          @calculator.pay_method = 'specific_date_each_month'
          @calculator.pay_day_in_month = 5
          paydates = @calculator.paydates_specific_date_each_month
          assert_equal '2012-08-05', paydates.first.to_s
          assert_equal '2013-05-05', paydates.last.to_s
        end

        should "calculate last working day of the month pay dates" do
          @calculator.pay_method = 'last_working_day_of_the_month'
          @calculator.pay_day_in_week = 3 # Paid last Wednesday in the month
          @calculator.work_days = [1, 3, 4]
          paydates = @calculator.paydates_last_working_day_of_the_month

          assert_equal '2012-07-30', paydates.first.to_s
          assert @calculator.work_days.include?(paydates.first.wday)
          assert_equal '2012-08-30', paydates.second.to_s
          assert_equal '2012-09-27', paydates.third.to_s
          assert_equal '2013-04-29', paydates.last.to_s
        end

        should "calculate the particular weekday of the month pay dates" do
          @calculator.pay_method = 'a_certain_week_day_each_month'
          @calculator.pay_week_in_month = "second"
          @calculator.pay_day_in_week = 1
          # Monday 2nd week in the month
          paydates = @calculator.paydates_a_certain_week_day_each_month.map(&:to_s)

          assert_equal '2012-07-09', paydates.first.to_s
          assert_equal '2012-08-13', paydates.second.to_s
          assert_equal '2012-09-10', paydates.third.to_s
          assert_equal '2012-10-08', paydates.fourth.to_s
          assert_equal '2013-05-13', paydates.last
        end
      end

      context "pay date on leave start date" do
        should "pay on the leave start date" do
          calculator = MaternityPayCalculator.new(Date.parse('21 March 2013'))
          calculator.leave_start_date = Date.parse('1 March 2013')
          calculator.pay_method = 'first_day_of_the_month'
          calculator.stubs(:average_weekly_earnings).returns(300.0)

          assert_equal '2013-03-01', calculator.paydates_first_day_of_the_month.first.to_s
          assert_equal '2013-03-01', calculator.paydates_and_pay.first[:date].to_s
          assert_equal 38.58, calculator.paydates_and_pay.first[:pay]
          assert calculator.paydates_and_pay.last[:date] > calculator.pay_end_date, "Last paydate should be after SMP end date"
          assert calculator.paydates_and_pay.last[:pay].positive?
        end
      end

      context "statutory pay rate for given year" do
        {
          2018 => 145.18,
          2017 => 140.98,
          2016 => 139.58,
          2015 => 139.58,
          2014 => 138.18,
          2013 => 136.78,
          2012 => 135.45,
        }.each do |year, rate|

          should "be £#{rate} for #{year}/#{year + 1}" do
            date = Date.parse("21 April #{year}")
            calculator = MaternityPayCalculator.new(date)
            calculator.leave_start_date = date
            assert_equal rate, calculator.statutory_rate(date)
          end
        end
      end

      context "paydates and pay" do
        setup do
          @calculator = MaternityPayCalculator.new(Date.parse('21 January 2013'))
          @calculator.leave_start_date = Date.parse('03 January 2013')
        end

        should "calculate pay due for each pay date on a weekly cycle" do
          @calculator.pay_date = Date.parse('28 December 2012') # Friday before maternity leave/pay starts.
          @calculator.pay_method = 'weekly'
          @calculator.pay_pattern = 'weekly'
          @calculator.earnings_for_pay_period = 2000

          paydates_and_pay = @calculator.paydates_and_pay

          assert_equal 40, paydates_and_pay.size
          assert paydates_and_pay.first[:date].friday?, "Paydates should all be fridays"
          assert_equal 64.29, paydates_and_pay.first[:pay]
          assert_equal '2013-01-04', paydates_and_pay.first[:date].to_s
          assert_equal 225, paydates_and_pay.second[:pay]
          assert_equal '2013-01-11', paydates_and_pay.second[:date].to_s
          assert_equal 97.7, paydates_and_pay.last[:pay]
          assert_equal '2013-10-04', paydates_and_pay.last[:date].to_s
        end

        should "calculate pay due for each pay date on a bi-weekly cycle" do
          @calculator.pay_date = Date.parse('03 January 2013')
          @calculator.pay_method = 'every_2_weeks'
          @calculator.pay_pattern = 'weekly'
          @calculator.earnings_for_pay_period = 2000

          paydates_and_pay = @calculator.paydates_and_pay

          expected_pay_dates = %w(
            2013-01-03 2013-01-17 2013-01-31 2013-02-14 2013-02-28
            2013-03-14 2013-03-28 2013-04-11 2013-04-25 2013-05-09
            2013-05-23 2013-06-06 2013-06-20 2013-07-04 2013-07-18
            2013-08-01 2013-08-15 2013-08-29 2013-09-12 2013-09-26
            2013-10-10
          )
          actual_pay_dates = paydates_and_pay.map { |p| p[:date].to_s }

          assert_equal expected_pay_dates, actual_pay_dates
          assert_equal 32.15, paydates_and_pay.first[:pay]
          assert_equal 450, paydates_and_pay.second[:pay]
          assert_equal 270.9, paydates_and_pay[4][:pay]
          assert_equal 117.24, paydates_and_pay.last[:pay]
        end

        should "calculate pay due for each pay date on a monthly cycle" do
          @calculator.pay_day_in_month = 5
          @calculator.pay_method = 'specific_date_each_month'
          @calculator.stubs(:average_weekly_earnings).returns(250.0)
          paydates_and_pay = @calculator.paydates_and_pay

          assert_equal 10, paydates_and_pay.size
          assert_equal '2013-01-05', paydates_and_pay.first[:date].to_s
          assert_equal 96.43, paydates_and_pay.first[:pay]
          assert_equal '2013-10-05', paydates_and_pay.last[:date].to_s
          assert_equal 527.58, paydates_and_pay.last[:pay]
        end

        should "calculate pay due on the first day of the month" do
          @calculator.pay_method = 'first_day_of_the_month'
          @calculator.stubs(:average_weekly_earnings).returns(250.0)
          paydates_and_pay = @calculator.paydates_and_pay

          assert_equal 10, paydates_and_pay.size
          assert_equal '2013-02-01', paydates_and_pay.first[:date].to_s
          assert_equal 964.29, paydates_and_pay.first[:pay]
          assert_equal '2013-11-01', paydates_and_pay.last[:date].to_s
          assert_equal 19.54, paydates_and_pay.last[:pay]
        end

        should "calculate pay due on the last day of the month" do
          @calculator.pay_method = 'last_day_of_the_month'
          @calculator.stubs(:average_weekly_earnings).returns(250.0)
          paydates_and_pay = @calculator.paydates_and_pay

          assert_equal 10, paydates_and_pay.size
          assert_equal '2013-01-31', paydates_and_pay.first[:date].to_s
          assert_equal 932.15, paydates_and_pay.first[:pay]
          assert_equal '2013-10-31', paydates_and_pay.last[:date].to_s
          assert_equal 39.08, paydates_and_pay.last[:pay]
        end

        should "calculate pay due for a certain weekday each month" do
          @calculator.pay_method = 'a_certain_week_day_each_month'
          @calculator.pay_day_in_week = 5
          @calculator.pay_week_in_month = "second" # 2nd Friday of the month
          @calculator.stubs(:average_weekly_earnings).returns(250.0)

          paydates_and_pay = @calculator.paydates_and_pay

          assert_equal 10, paydates_and_pay.size
          assert_equal '2013-01-11', paydates_and_pay.first[:date].to_s
          assert_equal 289.29, paydates_and_pay.first[:pay]
          assert_equal '2013-10-11', paydates_and_pay.last[:date].to_s
          assert_equal 371.26, paydates_and_pay.last[:pay]
        end
      end

      context "End of SMP period falls between payday and end of calendar month" do
        should "calculate pay due on the last working day of the month" do
          calculator = MaternityPayCalculator.new(Date.parse('8 October 2017'))
          calculator.leave_start_date = Date.parse('1 October 2017')
          calculator.work_days = [1, 2, 3, 4, 5]
          calculator.pay_method = 'last_working_day_of_the_month'
          calculator.stubs(:average_weekly_earnings).returns(203.0769)
          paydates_and_pay = calculator.paydates_and_pay

          assert_equal 10, paydates_and_pay.size
          assert_equal '2017-10-31', paydates_and_pay.first[:date].to_s
          assert_equal 809.41, paydates_and_pay.first[:pay] # uses 2017/2018 rate
          assert_equal '2018-07-31', paydates_and_pay.last[:date].to_s
          assert_equal 20.74, paydates_and_pay.last[:pay] # uses 2018/2019 rate
        end
      end

      context "HMRC test scenario for SMP Pay week offset" do
        should "calculate pay on paydates with April 2013 uprating" do
          calculator = MaternityPayCalculator.new(Date.parse('22 February 2013'))
          calculator.leave_start_date = Date.parse('25 January 2013')
          calculator.pay_method = 'weekly'
          calculator.pay_date = Date.parse('25 January 2013')
          calculator.stubs(:average_weekly_earnings).returns(200)
          paydates_and_pay =  calculator.paydates_and_pay

          assert_equal 25.72, paydates_and_pay.first[:pay]
          assert_equal 180.0, paydates_and_pay.second[:pay]
          assert_equal 173.64, paydates_and_pay[6][:pay]
          assert_equal 173.64, paydates_and_pay.find { |p| p[:date].to_s == '2013-03-08' }[:pay]
          assert_equal 135.45, paydates_and_pay.find { |p| p[:date].to_s == '2013-04-05' }[:pay]
          assert_equal 135.64, paydates_and_pay.find { |p| p[:date].to_s == '2013-04-12' }[:pay]
          assert_equal 136.78, paydates_and_pay.find { |p| p[:date].to_s == '2013-04-19' }[:pay]
        end
      end
      context "HMRC test scenario for SMP paid a certain day of the month" do
        should "calculate pay on paydates with April 2013 uprating" do
          calculator = MaternityPayCalculator.new(Date.parse('22 February 2013'))
          calculator.leave_start_date = Date.parse('25 January 2013')
          calculator.pay_method = 'a_certain_week_day_each_month'
          calculator.pay_day_in_week = 5
          calculator.pay_week_in_month = 'last'
          calculator.stubs(:average_weekly_earnings).returns(144.32)
          paydates_and_pay = calculator.paydates_and_pay

          assert_equal({ date: Date.parse('25 January 2013'), pay: 18.56 }, paydates_and_pay.first)
          assert_equal({ date: Date.parse('29 March 2013'), pay: 649.44 }, paydates_and_pay.third)
          assert_equal({ date: Date.parse('31 May 2013'), pay: 649.44 }, paydates_and_pay[4])
        end
      end

      context "pay date starting month is December" do
        should "produce a list of the paydates adjust one month forward" do
          Timecop.travel("26 Jul 2013")

          calculator = MaternityPayCalculator.new(Date.parse("14 January 2014"))
          calculator.leave_start_date = Date.parse("12 December 2013")
          calculator.pay_method = "monthly"
          calculator.pay_date = Date.parse("1 December 2013")
          calculator.stubs(:average_weekly_earnings).returns(200)

          assert_equal ["Wed, 01 Jan 2014", "Sat, 01 Feb 2014", "Sat, 01 Mar 2014",
                        "Tue, 01 Apr 2014", "Thu, 01 May 2014", "Sun, 01 Jun 2014",
                        "Tue, 01 Jul 2014", "Fri, 01 Aug 2014", "Mon, 01 Sep 2014",
                        "Wed, 01 Oct 2014"].map { |s| Date.parse(s) },
                       calculator.paydates_first_day_of_the_month
        end
      end

      context "payment_options" do
        should "return weekly payment options when supplied with weekly" do
          weekly = MaternityPayCalculator.payment_options("weekly")

          assert_equal %w(8 9 10), weekly.keys
          assert_equal ["8 payments or fewer", "9 payments", "10 payments"], weekly.values
        end

        should "return monthly payment options when supplied with monthly" do
          monthly = MaternityPayCalculator.payment_options("monthly")

          assert_equal %w(2 3), monthly.keys
          assert_equal ["1 or 2 payments", "3 payments"], monthly.values
        end

        should "return 2 weeks payment options when supplied with every 2 weeks" do
          every_2_weeks = MaternityPayCalculator.payment_options("every_2_weeks")

          assert_equal %w(4 5), every_2_weeks.keys
          assert_equal ["4 payments or fewer", "5 payments"], every_2_weeks.values
        end

        should "return 4 weeks payment options when supplied with every 4 weeks" do
          every_4_weeks = MaternityPayCalculator.payment_options("every_4_weeks")

          assert_equal %w(1 2), every_4_weeks.keys
          assert_equal ["1 payment", "2 payments"], every_4_weeks.values
        end
      end

      context "#number_of_payments" do
        setup do
          @calculator = MaternityPayCalculator.new(Date.parse("04 Sept 2017"))
        end

        should "return supplied payment_option when pay pattern is monthly" do
          @calculator.pay_pattern = "monthly"
          @calculator.payment_option = "3"

          assert_equal 3, @calculator.number_of_payments
        end

        should "return supplied payment_option when pay pattern is weekly" do
          @calculator.pay_pattern = "weekly"
          @calculator.payment_option = "9"

          assert_equal 9, @calculator.number_of_payments
        end

        should "return 2 when pay pattern is monthly and payment_option is set to non Numeric value" do
          @calculator.pay_pattern = "monthly"
          @calculator.payment_option = "invalid_numeral"

          assert_equal 2, @calculator.number_of_payments
        end

        should "return 8 when pay pattern is weekly and payment_option is set to non Numeric value" do
          @calculator.pay_pattern = "weekly"
          @calculator.payment_option = "invalid_numeral"

          assert_equal 8, @calculator.number_of_payments
        end

        should "return 8 when pay pattern is every_2_weeks and payment_option is set to non Numeric value" do
          @calculator.pay_pattern = "every_2_weeks"
          @calculator.payment_option = "invalid_numeral"

          assert_equal 8, @calculator.number_of_payments
        end

        should "return 8 when pay pattern is every_4_weeks and payment_option is set to non Numeric value" do
          @calculator.pay_pattern = "every_4_weeks"
          @calculator.payment_option = "invalid_numeral"

          assert_equal 8, @calculator.number_of_payments
        end

        should "return 2 when pay pattern is monthly and payment_option isn't set" do
          @calculator.pay_pattern = "monthly"
          @calculator.payment_option = nil

          assert_equal 2, @calculator.number_of_payments
        end

        should "return 8 when pay pattern is weekly and payment_option isn't set" do
          @calculator.pay_pattern = "weekly"
          @calculator.payment_option = nil

          assert_equal 8, @calculator.number_of_payments
        end

        should "return 8 when pay pattern is every_2_weeks and payment_option isn't set" do
          @calculator.pay_pattern = "every_2_weeks"
          @calculator.payment_option = nil

          assert_equal 8, @calculator.number_of_payments
        end

        should "return 8 when pay pattern is every_4_weeks and payment_option isn't set" do
          @calculator.pay_pattern = "every_4_weeks"
          @calculator.payment_option = nil

          assert_equal 8, @calculator.number_of_payments
        end
      end
    end
  end
end
