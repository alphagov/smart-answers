require_relative "../../test_helper"
require_relative "../../../lib/smart_answer/date_helper"

module SmartAnswer::Calculators
  class MaternityPaternityCalculatorTest < ActiveSupport::TestCase
    include DateHelper

    context MaternityPaternityCalculator do
      context "due date 4 months in future" do
        setup do
          @due_date = 4.months.since(Date.today)
          @start_of_week_in_four_months = @due_date - @due_date.wday
          @calculator = MaternityPaternityCalculator.new(@due_date)
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
          @dd = Date.parse("2012-10-12")
          @calculator = MaternityPaternityCalculator.new(@dd)
          @calculator.last_payday = @calculator.qualifying_week.last
          payday = @calculator.last_payday.julian - (7 * 9)
          @calculator.pre_offset_payday = payday
          assert_equal "Saturday, 15 April 2012 and Saturday, 30 June 2012", @calculator.formatted_relevant_period
        end

        should "calculate payday offset" do
          @calculator.last_payday = Date.parse("2012-03-28")
          assert_equal Date.parse("2012-02-02"), @calculator.payday_offset
        end

        should "calculate the ssp_stop date" do
          @calculator = MaternityPaternityCalculator.new(Date.parse("2012 Oct 12"))
          expected_week = @calculator.expected_week.first
          assert_equal expected_week.julian - (7 * 4), @calculator.ssp_stop
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
            @calculator.average_weekly_earnings = 193.00
            @calculator.leave_start_date = Date.new(2012, 1, 1)
          end

          should "calculate the statutory maternity rate" do
            assert_equal (193.00 * 0.9).round(2), @calculator.statutory_maternity_rate.round(2)
          end

          should "calculate the maternity pay at rate A" do
            assert_equal (193.00 * 0.9).round(2), @calculator.statutory_maternity_rate_a.round(2)
          end

          should "calculate the maternity pay at rate B using the base rate" do
            assert_equal 135.45, @calculator.statutory_maternity_rate_b
          end

          should "calculate the maternity pay at rate B using the percentage of weekly income" do
            @calculator.average_weekly_earnings = 135.40
            assert_equal 121.86, @calculator.statutory_maternity_rate_b.round(2)
          end

        end

        should "calculate the paternity rate as the standard rate" do
          @calculator.average_weekly_earnings = 500.55
          @calculator.leave_start_date = Date.new(2012, 1, 1)
          assert_equal 135.45, @calculator.statutory_paternity_rate
        end

        should "calculate the paternity rate as 90 percent of weekly earnings" do
          @calculator.average_weekly_earnings = 120.55
          @calculator.leave_start_date = Date.new(2012, 1, 1)
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
          @calculator = MaternityPaternityCalculator.new(@match_date, MaternityPaternityCalculator::LEAVE_TYPE_ADOPTION)
          assert_equal @calculator.lower_earning_limit, 107
        end

        should "return lower_earning_limit 102" do
          @match_date = Date.parse("31 March 2012")
          @calculator = MaternityPaternityCalculator.new(@match_date, MaternityPaternityCalculator::LEAVE_TYPE_ADOPTION)
          assert_equal @calculator.lower_earning_limit, 102
        end

        should "return lower_earning_limit 97" do
          @match_date = Date.parse("2 April 2011")
          @calculator = MaternityPaternityCalculator.new(@match_date, MaternityPaternityCalculator::LEAVE_TYPE_ADOPTION)
          assert_equal @calculator.lower_earning_limit, 97
        end
      end

      context "qualifying_week tests" do
        # due, qualifying_week, latest employment start, start of 11th week before due, start of 4th week
        # 08/04/12 to 14/04/12 25/12/11 to 31/12/11 09/07/2011 22/01/2012 11/03/2012
        should "due Monday 9th April 2012" do
          @due_date = Date.parse("2012 Apr 09")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal Date.parse("09 Apr 2012"), @calculator.employment_end
          assert_equal Date.parse("08 Apr 2012")..Date.parse("14 Apr 2012"), @calculator.expected_week
          assert_equal Date.parse("25 Dec 2011"), 15.weeks.ago(@calculator.expected_week.first)
          assert_equal Date.parse("31 Dec 2011"), 15.weeks.ago(@calculator.expected_week.first) + 6
          assert_equal Date.parse("25 Dec 2011")..Date.parse("31 Dec 2011"), @calculator.qualifying_week
          # assert_equal 26, (Date.parse(" Dec 2011").julian - Date.parse("09 Jul 2011").julian).to_i / 7
          # assert_equal 26, (Date.parse("14 Apr 2012").julian - Date.parse("15 Oct 2011").julian).to_i / 7
          # FIXME: this should work but 25 weeks rather than 26
          assert_equal Date.parse("09 Jul 2011"), @calculator.employment_start
          assert_equal Date.parse("22 Jan 2012"), @calculator.leave_earliest_start_date
          assert_equal Date.parse("11 Mar 2012"), @calculator.ssp_stop
        end
        # 15/07/12 to 21/07/12 01/04/12 to 07/04/12 15/10/2011 29/04/2012 17/06/2012
        should "due Wednesday 18 July 2012" do
          @due_date = Date.parse("2012 Jul 18")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal Date.parse("18 Jul 2012"), @calculator.employment_end
          assert_equal Date.parse("15 Jul 2012")..Date.parse("21 Jul 2012"), @calculator.expected_week
          assert_equal Date.parse("01 Apr 2012")..Date.parse("07 Apr 2012"), @calculator.qualifying_week
          # DEBUG test
          # assert_equal 26, (Date.parse("21 Jul 2012").julian - Date.parse("15 Oct 2011").julian).to_i / 7
          # FIXME: ...
          assert_equal Date.parse("15 Oct 2011"), @calculator.employment_start
          assert_equal Date.parse("29 Apr 2012"), @calculator.leave_earliest_start_date
          assert_equal Date.parse("17 Jun 2012"), @calculator.ssp_stop
        end
        # 09/09/12 to 15/09/12 27/05/12 to 02/06/12 10/12/2011 24/06/2012 12/08/2012
        should "due Wednesday 14 Sep 2012" do
          @due_date = Date.parse("2012 Sep 14")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal Date.parse("14 Sep 2012"), @calculator.employment_end
          assert_equal Date.parse("09 Sep 2012")..Date.parse("15 Sep 2012"), @calculator.expected_week
          assert_equal Date.parse("27 May 2012")..Date.parse("02 Jun 2012"), @calculator.qualifying_week
          assert_equal Date.parse("10 Dec 2011"), @calculator.employment_start
          assert_equal Date.parse("24 Jun 2012"), @calculator.leave_earliest_start_date
          assert_equal Date.parse("12 Aug 2012"), @calculator.ssp_stop
        end
        # 07/04/13 to 13/04/13 23/12/12 to 29/12/12 07/07/2012 20/01/2013 10/03/2013
        # 27/01/13 to 02/02/13 14/10/12 to 20/10/12 28/04/2012 11/11/2012 30/12/2012
        # 03/02/13 to 09/02/13 21/10/12 to 27/10/12 05/05/2012 18/11/2012 06/01/2013
      end

      context "adoption employment start tests" do
        # 27/05/12 to 02/06/12 10/12/11
        should "matched_date Monday 28th May 2012" do
          @matched_date = Date.parse("2012 May 28")
          @calculator = MaternityPaternityCalculator.new(@matched_date, MaternityPaternityCalculator::LEAVE_TYPE_ADOPTION)
          assert_equal Date.parse("2012 May 27")..Date.parse("2012 Jun 02"), @calculator.matched_week
          assert_equal Date.parse("2011 Dec 10"), @calculator.a_employment_start
        end
        # 15/07/12 to 21/07/12 28/01/12
        should "matched_date Wednesday 18th July 2012" do
          @matched_date = Date.parse("2012 Jul 18")
          @calculator = MaternityPaternityCalculator.new(@matched_date, MaternityPaternityCalculator::LEAVE_TYPE_ADOPTION)
          assert_equal Date.parse("2012 Jul 15")..Date.parse("2012 Jul 21"), @calculator.matched_week
          assert_equal Date.parse("2012 Jan 28"), @calculator.a_employment_start
          assert_equal 25, (Date.parse("2012 Jul 21").julian - Date.parse("2012 Jan 28").julian).to_i / 7
        end
        # 16/09/12 to 22/09/12 31/03/12
        # 09/12/12 to 15/12/12 23/06/12
        # 10/03/13 to 16/03/13 22/09/12
      end

      context "calculate_average_weekly_pay" do
        setup do
          @calculator = MaternityPaternityCalculator.new(4.months.since(Date.today))
        end

        should "make no calculation for a weekly pay pattern" do
          assert_equal 665.15, @calculator.calculate_average_weekly_pay("weekly", 5321.20)
        end

        should "work out the weekly average for a fortnightly pay pattern" do
          assert_equal 399.32, @calculator.calculate_average_weekly_pay("every_2_weeks", 3194.56)
        end

        should "work out the weekly average for a four week pay pattern" do
          assert_equal 382.06, @calculator.calculate_average_weekly_pay("every_4_weeks", 3056.48)
        end

        should "work out the weekly average for a monthly pay pattern" do
          assert_equal 1846.15385, @calculator.calculate_average_weekly_pay("monthly", 16000)
        end

        should "work out the weekly average for a irregular pay pattern" do
          @calculator.last_payday = 15.days.ago(Date.today)
          @calculator.pre_offset_payday = 55.days.ago(@calculator.last_payday)
          assert_equal 56, @calculator.pay_period_in_days
          assert_equal 974.82875, @calculator.calculate_average_weekly_pay("irregularly", 7798.63)
        end
      end
      context "HMRC scenarios" do
        setup do
          @calculator = MaternityPaternityCalculator.new(Date.parse("2013-02-22"))
        end

        should "calculate AWE for weekly pay patterns" do
          assert_equal 200, @calculator.calculate_average_weekly_pay("weekly", 1600)
          assert_equal 151, @calculator.calculate_average_weekly_pay("weekly", 1208)
          assert_equal 150, @calculator.calculate_average_weekly_pay("weekly", 1200)
        end

        should "calculate AWE for monthly pay patterns" do
          @calculator.last_payday = Date.parse("2012-10-31")
          assert_equal 184.61538, @calculator.calculate_average_weekly_pay("monthly", 1600)
          @calculator.last_payday = Date.parse("2012-10-26")
          assert_equal 144.31731, @calculator.calculate_average_weekly_pay("monthly", 1250.75)
        end

        should "calculate AWE for irregular pay patterns" do
          @calculator.last_payday = Date.parse("2012-11-06")
          @calculator.pre_offset_payday = Date.parse("2012-08-01")
          assert_equal 214.28571, @calculator.calculate_average_weekly_pay("irregularly", 3000)
        end
      end

      context "total_statutory_pay" do
        setup do
          @calculator = MaternityPaternityCalculator.new(Date.parse('3 August 2012'))
          @calculator.leave_start_date = Date.parse('12 July 2012')
          @calculator.pay_method = 'weekly_starting'
        end

        should "be statutory leave times statutory rates A and B" do
          @calculator.average_weekly_earnings = 120.40
          assert_equal 4226.43, @calculator.total_statutory_pay
        end

        should "be statutory leave times statutory higher rate A and statutory rate B" do
          @calculator.average_weekly_earnings = 235.40
          assert_equal 5741.01, @calculator.total_statutory_pay.round(2)
        end
      end

      context "pay dates for pay method from 12 August 2012" do
        setup do
          @calculator = MaternityPaternityCalculator.new(Date.parse('12 August 2012'))
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
          @calculator.work_days = [1,3,4]
          paydates = @calculator.paydates_last_working_day_of_the_month

          assert_equal '2012-07-30', paydates.first.to_s
          assert @calculator.work_days.include?(paydates.first.wday)
          assert_equal '2012-08-30', paydates.second.to_s
          assert_equal '2012-09-27', paydates.third.to_s
          assert_equal '2013-04-29', paydates.last.to_s
        end
        should "calculate the particular weekday of the month pay dates" do
          @calculator.pay_method = 'a_certain_week_day_each_month'
          @calculator.pay_week_in_month = "third"
          @calculator.pay_day_in_week = 3
          # Wednesday 3rd week in the month
          paydates = @calculator.paydates_a_certain_week_day_each_month.map(&:to_s)

          assert_equal '2012-07-18', paydates.first.to_s
          assert_equal '2012-08-15', paydates.second.to_s
          assert_equal '2012-09-19', paydates.third.to_s
          assert_equal '2012-10-17', paydates.fourth.to_s
          assert_equal '2013-04-17', paydates.last
        end
      end
      context "pay date on leave start date" do
        setup do
          @calculator = MaternityPaternityCalculator.new(Date.parse('21 March 2013'))
          @calculator.leave_start_date = Date.parse('1 March 2013')
          @calculator.pay_method = 'first_day_of_the_month'
          @calculator.average_weekly_earnings = 300.0

        end
        should "pay on the leave start date" do
          assert_equal '2013-03-01', @calculator.paydates_first_day_of_the_month.first.to_s
          assert_equal '2013-03-01', @calculator.paydates_and_pay.first[:date].to_s
          assert_equal 38.58, @calculator.paydates_and_pay.first[:pay]
          assert @calculator.paydates_and_pay.last[:date] > @calculator.pay_end_date, "Last paydate should be after SMP end date"
          assert @calculator.paydates_and_pay.last[:pay] > 0
        end
      end
      context "variable statutory pay rate" do
        setup do
          @calculator = MaternityPaternityCalculator.new(Date.parse('21 April 2013'))
          @calculator.leave_start_date = Date.parse('29 March 2013')

        end
        context "for 2012 rates" do
          should "give the correct rate for the period" do
            assert_equal 135.45, @calculator.statutory_rate(Date.parse('6 April 2012'))
          end
        end
        context "when uprating should start" do
          should "give the correct rate for the period" do
            assert_equal 136.78, @calculator.statutory_rate(Date.parse('12 April 2013'))
          end
        end
        context "for 2043 rates" do
          should "give a default rate for a date in the future" do
            assert_equal 136.78, @calculator.statutory_rate(Date.parse('6 April 2043'))
          end
        end
      end
      context "paydates and pay" do
        setup do
          @calculator = MaternityPaternityCalculator.new(Date.parse('21 January 2013'))
          @calculator.leave_start_date = Date.parse('03 January 2013')
        end
        should "calculate pay due for each pay date on a weekly cycle" do
          @calculator.pay_date = Date.parse('28 December 2012') # Friday before maternity leave/pay starts.
          @calculator.pay_method = 'weekly'
          @calculator.calculate_average_weekly_pay('weekly', 2000)

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
          @calculator.calculate_average_weekly_pay('weekly', 2000)

          paydates_and_pay = @calculator.paydates_and_pay

          assert_equal ["2013-01-03","2013-01-17","2013-01-31","2013-02-14","2013-02-28",
                        "2013-03-14","2013-03-28","2013-04-11","2013-04-25","2013-05-09",
                        "2013-05-23","2013-06-06","2013-06-20","2013-07-04","2013-07-18",
                        "2013-08-01","2013-08-15","2013-08-29","2013-09-12","2013-09-26",
                        "2013-10-10"], paydates_and_pay.map{ |p| p[:date].to_s }
          assert_equal 32.15, paydates_and_pay.first[:pay]
          assert_equal 450, paydates_and_pay.second[:pay]
          assert_equal 270.9, paydates_and_pay[4][:pay]
          assert_equal 117.24, paydates_and_pay.last[:pay]
        end
        should "calculate pay due for each pay date on a monthly cycle" do
          @calculator.pay_day_in_month = 5
          @calculator.pay_method = 'specific_date_each_month'
          @calculator.average_weekly_earnings = 250.0
          paydates_and_pay = @calculator.paydates_and_pay

          assert_equal 10, paydates_and_pay.size

          assert_equal '2013-01-05', paydates_and_pay.first[:date].to_s
          assert_equal 96.43, paydates_and_pay.first[:pay]
          assert_equal '2013-10-05', paydates_and_pay.last[:date].to_s
          assert_equal 527.59, paydates_and_pay.last[:pay]
        end
        should "calculate pay due on the first day of the month" do
          @calculator.pay_method = 'first_day_of_the_month'
          @calculator.average_weekly_earnings = 250.0
          paydates_and_pay = @calculator.paydates_and_pay

          assert_equal 10, paydates_and_pay.size
          assert_equal '2013-02-01', paydates_and_pay.first[:date].to_s
          assert_equal 964.29, paydates_and_pay.first[:pay]
          assert_equal '2013-11-01', paydates_and_pay.last[:date].to_s
          assert_equal 19.54, paydates_and_pay.last[:pay]
        end
        should "calculate pay due on the last day of the month" do
          @calculator.pay_method = 'last_day_of_the_month'
          @calculator.average_weekly_earnings = 250.0
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
          @calculator.average_weekly_earnings = 250.0

          paydates_and_pay = @calculator.paydates_and_pay

          assert_equal 10, paydates_and_pay.size
          assert_equal '2013-01-11', paydates_and_pay.first[:date].to_s
          assert_equal 289.29, paydates_and_pay.first[:pay]
          assert_equal '2013-10-11', paydates_and_pay.last[:date].to_s
          assert_equal 371.27, paydates_and_pay.last[:pay]
        end
        should "calculate pay due for the last working day of the month" do
          @calculator.pay_method = 'last_working_day_of_the_month'
          @calculator.pay_day_in_week = 5
          @calculator.work_days = [1,2,4]
          @calculator.average_weekly_earnings = 250.0

          paydates_and_pay = @calculator.paydates_and_pay
        end
      end
      context "HMRC test scenario for SMP Pay week offset" do
        setup do
          @calculator = MaternityPaternityCalculator.new(Date.parse('22 February 2013'))
          @calculator.leave_start_date = Date.parse('25 January 2013')
          @calculator.pay_method = 'weekly'
          @calculator.pay_date = Date.parse('25 January 2013')
          @calculator.average_weekly_earnings = 200
        end
        should "calculate pay on paydates with April 2013 uprating" do
          paydates_and_pay =  @calculator.paydates_and_pay

          assert_equal 25.72, paydates_and_pay.first[:pay]
          assert_equal 180.0, paydates_and_pay.second[:pay]
          assert_equal 173.64, paydates_and_pay[6][:pay]
          assert_equal 173.64, paydates_and_pay.find{ |p| p[:date].to_s == '2013-03-08' }[:pay]
          assert_equal 135.45, paydates_and_pay.find{ |p| p[:date].to_s == '2013-04-05' }[:pay]
          assert_equal 135.64, paydates_and_pay.find{ |p| p[:date].to_s == '2013-04-12' }[:pay]
          assert_equal 136.78, paydates_and_pay.find{ |p| p[:date].to_s == '2013-04-19' }[:pay]
        end
      end
      context "HMRC test scenario for SMP paid a certain day of the month" do
        setup do
          @calculator = MaternityPaternityCalculator.new(Date.parse('22 February 2013'))
          @calculator.leave_start_date = Date.parse('25 January 2013')
          @calculator.pay_method = 'a_certain_week_day_each_month'
          @calculator.pay_day_in_week = 5
          @calculator.pay_week_in_month = 'last'
          @calculator.average_weekly_earnings = 144.32
        end
        should "calculate pay on paydates with April 2013 uprating" do
          paydates_and_pay =  @calculator.paydates_and_pay
          assert_equal({ :date => Date.parse('25 January 2013'), :pay => 18.56 }, paydates_and_pay.first)
          assert_equal({ :date => Date.parse('29 March 2013'), :pay => 649.45 }, paydates_and_pay.third)
          assert_equal({ :date => Date.parse('31 May 2013'), :pay => 649.45 }, paydates_and_pay[4])
        end
      end
    end
  end
end
