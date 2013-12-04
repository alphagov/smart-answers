# -*- coding: utf-8 -*-
module SmartAnswer::Calculators
  class StatutorySickPayCalculatorV2
    attr_reader :waiting_days, :normal_workdays, :pattern_days

    # LEL changes on 6 April each year
    # the two constants below are meant as 'safety' if the calculator gets a query for future dates past the latest known
    # and should be updated to the latest known rate
    LOWER_EARNING_LIMIT = 109.00
    SSP_WEEKLY_RATE = 86.70

    def initialize(prev_sick_days, sick_start_date, sick_end_date, days_of_the_week_worked)
      @prev_sick_days = prev_sick_days
      @waiting_days = (@prev_sick_days >= 3 ? 0 : 3 - @prev_sick_days)
      @sick_start_date = sick_start_date
      @sick_end_date = sick_end_date
      @pattern_days = days_of_the_week_worked.length
      @normal_workdays_missed = init_normal_workdays_missed(days_of_the_week_worked)
      @normal_workdays = @normal_workdays_missed.length
      @payable_days = init_payable_days
    end

    def self.earning_limit_rates
      [
        {min: Date.parse("6 April 2010"), max: Date.parse("5 April 2011"), lower_earning_limit_rate: 97},
        {min: Date.parse("6 April 2011"), max: Date.parse("5 April 2012"), lower_earning_limit_rate: 102},
        {min: Date.parse("6 April 2012"), max: Date.parse("5 April 2013"), lower_earning_limit_rate: 107},
        {min: Date.parse("6 April 2013"), max: Date.parse("5 April 2014"), lower_earning_limit_rate: 109}
      ]
    end

    # define as static so we don't have to instantiate the calculator too early in the flow
    def self.lower_earning_limit_on(date)
      earning_limit_rate = earning_limit_rates.find { |c| c[:min] <= date and c[:max] >= date }
      (earning_limit_rate ? earning_limit_rate[:lower_earning_limit_rate] : LOWER_EARNING_LIMIT)
    end

    def self.months_between(start_date, end_date)
      end_month = end_date.month
      current_month = start_date.next_month
      count = 0
      count += 1 if start_date.day < 17
      count += 1 if end_date.day > 15
      while current_month.month != end_month
        count +=1
        current_month = current_month.next_month
      end
      count
    end

    def self.average_weekly_earnings(args)
      pay, pay_pattern, monthly_pattern_payments = args.values_at(:pay, :pay_pattern, :monthly_pattern_payments)
      case pay_pattern
      when "weekly", "fortnightly", "every_4_weeks"
        pay / 8.0
      when "monthly"
        pay / monthly_pattern_payments * 12.0 / 52
      when "irregularly"
        relevant_period_to, relevant_period_from = args.values_at(:relevant_period_to, :relevant_period_from)
        pay / (Date.parse(relevant_period_to) - Date.parse(relevant_period_from)).to_i * 7
      end
    end

    # ssp weekly rate changes on 6 April each year
    def ssp_rates
      [
        {min: Date.parse("6 April 2011"), max: Date.parse("5 April 2012"), ssp_weekly_rate: 81.60},
        {min: Date.parse("6 April 2012"), max: Date.parse("5 April 2013"), ssp_weekly_rate: 85.85},
        {min: Date.parse("6 April 2013"), max: Date.parse("5 April 2014"), ssp_weekly_rate: 86.70}
      ]
    end

    def weekly_rate_on(date)
      rate = ssp_rates.find { |c| c[:min] <= date and c[:max] >= date }
      rate ? rate[:ssp_weekly_rate] : SSP_WEEKLY_RATE
    end

    def daily_rate_from_weekly(weekly_rate, pattern_days)
      # we need to calculate the daily rate by truncating to four decimal places to match unrounded daily rates used by HMRC
      # doing .round(6) after multiplication to avoid float precision issues
      # Simply using .round(4) on ssp_weekly_rate/@pattern_days will be off by 0.0001 for 3 and 7 pattern days and lead to 1p difference in some statutory amount calculations
      pattern_days > 0 ? ((((weekly_rate / pattern_days) * 10000).round(6).floor)/10000.0) : 0.0000
    end

    def max_days_that_can_be_paid
      (28 * @pattern_days).round(10)
    end

    def days_paid_in_linked_period
      if @prev_sick_days > 3
        @prev_sick_days - 3
      else
        0
      end
    end

    def days_paid
      [days_to_pay, days_that_can_be_paid_for_this_period].min
    end

    def days_that_can_be_paid_for_this_period
      [max_days_that_can_be_paid - days_paid_in_linked_period, 0].max
    end

    def days_to_pay
      @payable_days.length
    end

    def sick_pay_weekly_dates
      last_saturday = @sick_end_date.end_of_week - 1
      (@sick_start_date..last_saturday).select { |day| day.wday == 6 }
    end

    def formatted_sick_pay_weekly_amounts
      weekly_payments.map { |week|
        [week.first.strftime("%e %B %Y"), sprintf("£%.2f", week.second)].join("|")
      }.join("\n")
    end

    def ssp_payment
      BigDecimal.new(weekly_payments.map(&:last).sum.round(10).to_s).round(2, BigDecimal::ROUND_UP).to_f
    end

    def weekly_payments
      payments = sick_pay_weekly_dates.map { |date| [date, weekly_payment(date)] }
      payments.pop while payments.any? and payments.last.last == 0
      payments
    end

    def weekly_payment(week_start_date)
      pay = 0.0
      ((week_start_date - 6)..week_start_date).each do |date|
        pay += daily_rate_from_weekly(weekly_rate_on(date), @pattern_days) if @payable_days.include?(date)
      end
      BigDecimal.new(pay.round(10).to_s).round(2, BigDecimal::ROUND_UP).to_f
    end

    def self.contractual_earnings_awe(pay, days_worked)
      (pay / BigDecimal.new(days_worked.to_s) * 7).round(2)
    end

    def self.total_earnings_awe(pay, number_of_weeks, days_worked)
      if %w(7 14 21 28 35 42 49 56).include?(number_of_weeks)
        (pay / number_of_weeks).round(2)
      else
        (pay / BigDecimal.new(days_worked.to_s) * 7).round(2)
      end
    end

    private
    def init_normal_workdays_missed(days_of_the_week_worked)
      dates = @sick_start_date..@sick_end_date
      # create an array of all dates that would have been normal workdays
      normal_workdays_missed = []
      dates.each do |d|
        if days_of_the_week_worked.include?(d.wday.to_s)
          normal_workdays_missed << d
        end
      end
      normal_workdays_missed
    end

    def init_payable_days
      # copy not to modify the instance variable we need to keep
      payable_days_temp = @normal_workdays_missed
      ## 1. remove up to 3 first dates from the array if there are waiting days in this period
      payable_days_temp.shift(@waiting_days)
      ## 2. return only the first days_that_can_be_paid_for_this_period
      payable_days_temp.shift(days_that_can_be_paid_for_this_period)
    end

    def find_6th_april_after(date)
      year = date.year
      if (date.month > 4) or (date.month == 4 and date.day > 6)
        year +=1
      end
      Date.new(year, 4, 6)
    end
  end
end
