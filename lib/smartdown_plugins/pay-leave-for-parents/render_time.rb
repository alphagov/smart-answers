require 'smartdown/model/answer/money'
require 'smartdown/model/answer/date'

module SmartdownPlugins
  module PayLeaveForParents
    #Uprate helpers

    def self.lower_earnings_amount(due_date)
      start_date = lower_earnings_start_date(due_date)
      if in_2013_2014_fin_year?(start_date)
        build_money_answer(109)
      elsif in_2014_2015_fin_year?(start_date)
        build_money_answer(111)
      elsif in_2015_2016_fin_year?(start_date)
        build_money_answer(112)
      else
        build_money_answer(112)
      end
    end

    def self.in_2013_2014_fin_year?(date)
      (Date.new(2013, 05, 06)..Date.new(2014, 05, 05)).cover?(date.value)
    end

    def self.in_2014_2015_fin_year?(date)
      (Date.new(2014, 05, 06)..Date.new(2015, 05, 05)).cover?(date.value)
    end

    def self.in_2015_2016_fin_year?(date)
      (Date.new(2015, 05, 06)..Date.new(2016, 05, 05)).cover?(date.value)
    end

    def self.range_in_2013_2014_fin_year?(date)
      date_in_39_week_range?(2013, 2014, date)
    end

    def self.range_in_2014_2015_fin_year?(date)
      date_in_39_week_range?(2014, 2015, date)
    end

    def self.range_in_2015_2016_fin_year?(date)
      date_in_39_week_range?(2015, 2016, date)
    end

    #Flow helpers

    #Continuity test
    def self.continuity(job_before, job_after)
      job_before == "yes" && job_after == "yes"
    end

    #Lower earnings test: person has earned more than
    #the lower earnings limit
    def self.lower_earnings(lel)
      lel == "yes"
    end

    #Earnings and employment test
    def self.earnings_employment(earnings_employment, work_employment)
      earnings_employment == "yes" && work_employment == "yes"
    end

    #Date calculations

    def self.continuity_start_date(date)
      build_date_answer(saturday_before(date.value - 39.weeks))
    end

    def self.continuity_end_date(date)
      build_date_answer(sunday_before(date.value - 15.weeks))
    end

    def self.lower_earnings_start_date(date)
      build_date_answer(saturday_before(date.value - 22.weeks))
    end

    def self.lower_earnings_end_date(date)
      build_date_answer(saturday_before(date.value - 14.weeks))
    end

    def self.earnings_employment_start_date(date)
      build_date_answer(sunday_before(date.value - 66.weeks))
    end

    def self.earnings_employment_end_date(date)
      build_date_answer(saturday_before(date.value))
    end

    def self.earliest_start_mat_leave(date)
      build_date_answer(sunday_before(date.value - 11.weeks))
    end

    def self.end_of_additional_paternity_leave(date)
      build_date_answer(date.value + 1.year)
    end

    def self.end_of_shared_parental_leave(date)
      build_date_answer(date.value + 1.year)
    end

    def self.latest_pat_leave(date)
      build_date_answer(date.value + 56.days)
    end

    def self.maternity_leave_notice_date(date)
      build_date_answer(saturday_before(date.value - 14.weeks))
    end

    def self.paternity_leave_notice_date(date)
      build_date_answer(saturday_before(date.value - 14.weeks))
    end

    def self.start_of_additional_paternity_leave(date)
      build_date_answer(date.value + 20.weeks)
    end

    def self.start_of_maternity_allowance(date)
      build_date_answer(sunday_before(date.value - 11.weeks))
    end

    #Money calculations

    def self.rate_of_maternity_allowance(salary_1_66_weeks, due_date)
      build_money_answer(nine_tenths_weekly_salary_capped(salary_1_66_weeks, due_date))
    end

    def self.rate_of_maternity_allowance_2013_2014(salary)
      rate_of_maternity_allowance(salary, build_date_answer(Smartdown::Model::Answer::Date.new("2014-1-1")))
    end

    def self.rate_of_maternity_allowance_2014_2015(salary)
      rate_of_maternity_allowance(salary, build_date_answer(Smartdown::Model::Answer::Date.new("2015-1-1")))
    end

    def self.rate_of_maternity_allowance_2015_2016(salary)
      rate_of_maternity_allowance(salary, build_date_answer(Smartdown::Model::Answer::Date.new("2016-1-1")))
    end

    def self.rate_of_paternity_pay(salary_2, due_date)
      build_money_answer(nine_tenths_weekly_salary_capped(salary_2, due_date))
    end

    def self.rate_of_paternity_pay_2013_2014(salary)
      rate_of_paternity_pay(salary, build_date_answer(Smartdown::Model::Answer::Date.new("2014-1-1")))
    end

    def self.rate_of_paternity_pay_2014_2015(salary)
      rate_of_paternity_pay(salary, build_date_answer(Smartdown::Model::Answer::Date.new("2015-1-1")))
    end

    def self.rate_of_paternity_pay_2015_2016(salary)
      rate_of_paternity_pay(salary, build_date_answer(Smartdown::Model::Answer::Date.new("2016-1-1")))
    end

    def self.rate_of_shpp(salary, due_date)
      build_money_answer(nine_tenths_weekly_salary_capped(salary, due_date))
    end

    def self.rate_of_shpp_2013_2014(salary)
      rate_of_shpp(salary, build_date_answer(Smartdown::Model::Answer::Date.new("2014-1-1")))
    end

    def self.rate_of_shpp_2014_2015(salary)
      rate_of_shpp(salary, build_date_answer(Smartdown::Model::Answer::Date.new("2015-1-1")))
    end

    def self.rate_of_shpp_2015_2016(salary)
      rate_of_shpp(salary, build_date_answer(Smartdown::Model::Answer::Date.new("2016-1-1")))
    end

    def self.rate_of_smp_6_weeks(salary_1)
      build_money_answer((salary_1.value / 52) * 0.9)
    end

    def self.rate_of_smp_33_weeks(salary_1, due_date)
      start_date = build_date_answer(due_date.value + 6.weeks)
      build_money_answer(nine_tenths_weekly_salary_capped(salary_1, start_date))
    end

    def self.rate_of_smp_33_weeks_2013_2014(salary_1)
      rate_of_smp_33_weeks(salary_1, build_date_answer(Smartdown::Model::Answer::Date.new("2014-1-1")))
    end

    def self.rate_of_smp_33_weeks_2014_2015(salary_1)
      rate_of_smp_33_weeks(salary_1, build_date_answer(Smartdown::Model::Answer::Date.new("2015-1-1")))
    end

    def self.rate_of_smp_33_weeks_2015_2016(salary_1)
      rate_of_smp_33_weeks(salary_1, build_date_answer(Smartdown::Model::Answer::Date.new("2016-1-1")))
    end

    def self.total_aspp(salary, due_date)
      date = due_date.value
      pay = 0
      # Calculate pay for each week of the 39 week duration
      39.times do
        if (Date.new(2013, 05, 06)..Date.new(2014, 05, 05)).cover?(date)
          pay += rate_of_paternity_pay_2013_2014(salary).value
        elsif (Date.new(2013, 05, 06)..Date.new(2014, 05, 05)).cover?(date)
          pay += rate_of_paternity_pay_2014_2015(salary).value
        elsif (Date.new(2013, 05, 06)..Date.new(2014, 05, 05)).cover?(date)
          pay += rate_of_paternity_pay_2015_2016(salary).value
        else
          pay += rate_of_paternity_pay_2015_2016(salary).value
        end
        date += 1.week
      end
      build_money_answer(pay)
    end

    def self.total_maternity_allowance(salary_1_66_weeks, due_date)
      date = due_date.value
      pay = 0
      # Calculate pay for each week of the 39 week duration
      39.times do
        if (Date.new(2013, 05, 06)..Date.new(2014, 05, 05)).cover?(date)
          pay += rate_of_maternity_allowance_2013_2014(salary_1_66_weeks).value
        elsif (Date.new(2013, 05, 06)..Date.new(2014, 05, 05)).cover?(date)
          pay += rate_of_maternity_allowance_2014_2015(salary_1_66_weeks).value
        elsif (Date.new(2013, 05, 06)..Date.new(2014, 05, 05)).cover?(date)
          pay += rate_of_maternity_allowance_2015_2016(salary_1_66_weeks).value
        else
          pay += rate_of_maternity_allowance_2015_2016(salary_1_66_weeks).value
        end
        date += 1.week
      end
      build_money_answer(pay)
    end

    def self.total_smp(salary_1, due_date)
      date = due_date.value
      initial_pay = (rate_of_smp_6_weeks(salary_1) * 6)
      week_pay = 0
      # Calculate pay for each week of the 33 week duration
      33.times do
        if (Date.new(2013, 05, 06)..Date.new(2014, 05, 05)).cover?(date)
          week_pay += rate_of_smp_33_weeks_2013_2014(salary_1).value
        elsif (Date.new(2013, 05, 06)..Date.new(2014, 05, 05)).cover?(date)
          week_pay += rate_of_smp_33_weeks_2014_2015(salary_1).value
        elsif (Date.new(2013, 05, 06)..Date.new(2014, 05, 05)).cover?(date)
          week_pay += rate_of_smp_33_weeks_2015_2016(salary_1).value
        else
          week_pay += rate_of_smp_33_weeks_2015_2016(salary_1).value
        end
        date += 1.week
      end
      build_money_answer(initial_pay + week_pay)
    end

  private

    def self.date_in_39_week_range?(range_start, range_end, date)
      start_date = date.value
      end_date = start_date + 39.weeks
      (Date.new(range_start, 05, 06)..Date.new(range_end, 05, 05)).cover?(start_date) ||
        (Date.new(range_start, 05, 06)..Date.new(range_end, 05, 05)).cover?(end_date)
    end

    def self.build_date_answer(date)
      Smartdown::Model::Answer::Date.new(date.to_s)
    end

    def self.build_money_answer(amount)
      Smartdown::Model::Answer::Money.new(amount)
    end

    def self.sunday_before(date)
      date - date.wday
    end

    def self.saturday_before(date)
      (date - date.wday) - 1.day
    end

    def self.nine_tenths_weekly_salary_capped(salary, start_date)
      if in_2013_2014_fin_year?(start_date)
        max_rate = 136.78
      elsif in_2014_2015_fin_year?(start_date)
        max_rate = 138.18
      elsif in_2015_2016_fin_year?(start_date)
        max_rate = 139.58
      else
        max_rate = 139.58
      end

      weekly_salary = salary.value / 52
      rate = weekly_salary * 0.9
      [rate, max_rate].min
    end
  end
end
