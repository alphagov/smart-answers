module SmartAnswer
  module Calculators
    class StatutorySickPayCalculator
      MINIMUM_NUMBER_OF_DAYS_IN_PERIOD_OF_INCAPACITY_TO_WORK = 4

      include ActiveModel::Model

      attr_accessor :sick_start_date, :sick_end_date, :days_of_the_week_worked
      attr_accessor :other_pay_types_received, :enough_notice_of_absence
      attr_accessor :has_linked_sickness
      attr_accessor :linked_sickness_start_date, :linked_sickness_end_date
      attr_accessor :relevant_period_to, :relevant_period_from
      attr_accessor :eight_weeks_earnings
      attr_accessor :pay_pattern
      attr_accessor :relevant_contractual_pay
      attr_accessor :total_earnings_before_sick_period
      attr_accessor :employee_average_weekly_earnings

      def prev_sick_days
        prior_sick_days
      end

      def waiting_days
        prev_sick_days >= 3 ? 0 : 3 - prev_sick_days
      end

      def pattern_days
        @days_of_the_week_worked.length
      end

      def normal_workdays_missed
        @normal_workdays_missed ||= init_normal_workdays_missed(@days_of_the_week_worked)
      end

      def normal_workdays
        normal_workdays_missed.length
      end

      def payable_days
        @payable_days ||= init_payable_days
      end

      def paternity_maternity_warning?
        (other_pay_types_received & %w{statutory_paternity_pay additional_statutory_paternity_pay statutory_adoption_pay}).any?
      end

      def already_getting_maternity_pay?
        (other_pay_types_received & %w{statutory_paternity_pay additional_statutory_paternity_pay statutory_adoption_pay none}).none?
      end

      def days_sick
        period = DateRange.new(begins_on: sick_start_date, ends_on: sick_end_date)
        period.number_of_days
      end

      def valid_last_sick_day?(value)
        period = DateRange.new(begins_on: sick_start_date, ends_on: value)
        period.number_of_days >= 1
      end

      def valid_linked_sickness_start_date?(value)
        sick_start_date > value
      end

      def within_eight_weeks_of_current_sickness_period?(value)
        furthest_allowed_date = sick_start_date - 8.weeks
        value > furthest_allowed_date
      end

      def at_least_1_day_before_first_sick_day?(value)
        value < sick_start_date - 1
      end

      def valid_period_of_incapacity_for_work?(value)
        period = DateRange.new(begins_on: linked_sickness_start_date, ends_on: value)
        period.number_of_days >= MINIMUM_NUMBER_OF_DAYS_IN_PERIOD_OF_INCAPACITY_TO_WORK
      end

      def valid_last_payday_before_sickness?(value)
        value < sick_start_date
      end

      def valid_last_payday_before_offset?(value)
        value <= pay_day_offset
      end

      def sick_start_date_for_awe
        linked_sickness_start_date || sick_start_date
      end

      def sick_end_date_for_awe
        linked_sickness_end_date || sick_end_date
      end

      def prior_sick_days
        return 0 unless has_linked_sickness
        prev_sick_days = Calculators::StatutorySickPayCalculator.dates_matching_pattern(
          from: linked_sickness_start_date,
          to: linked_sickness_end_date,
          pattern: days_of_the_week_worked
        )
        prev_sick_days.length
      end

      def pay_day_offset
        relevant_period_to - 8.weeks
      end

      def monthly_pattern_payments
        self.class.months_between(relevant_period_from, relevant_period_to)
      end

      def paid_at_least_8_weeks_of_earnings?
        eight_weeks_earnings == 'eight_weeks_more'
      end

      def paid_less_than_8_weeks_of_earnings?
        eight_weeks_earnings == 'eight_weeks_less'
      end

      def fell_sick_before_payday?
        eight_weeks_earnings == 'before_payday'
      end

      # define as static so we don't have to instantiate the calculator too early in the flow
      def self.lower_earning_limit_on(date)
        SmartAnswer::Calculators::RatesQuery.new('statutory_sick_pay').rates(date).lower_earning_limit_rate
      end

      def self.months_between(start_date, end_date)
        end_month = end_date.month
        current_month = start_date.next_month
        count = 0
        count += 1 if start_date.day < 17
        count += 1 if end_date.day > 15
        while current_month.month != end_month
          count += 1
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
          pay / (relevant_period_to - relevant_period_from).to_i * 7
        end
      end

      def daily_rate_from_weekly(weekly_rate, pattern_days)
        # we need to calculate the daily rate by truncating to four decimal places to match unrounded daily rates used by HMRC
        # doing .round(6) after multiplication to avoid float precision issues
        # Simply using .round(4) on ssp_weekly_rate/@pattern_days will be off by 0.0001 for 3 and 7 pattern days and lead to 1p difference in some statutory amount calculations
        pattern_days > 0 ? ((((weekly_rate / pattern_days) * 10000).round(6).floor) / 10000.0) : 0.0000
      end

      def days_paid
        [days_to_pay, days_that_can_be_paid_for_this_period].min
      end

      def days_that_can_be_paid_for_this_period
        [max_days_that_can_be_paid - days_paid_in_linked_period, 0].max
      end

      def formatted_sick_pay_weekly_amounts
        weekly_payments.map { |week|
          [week.first.strftime("%e %B %Y"), sprintf("£%.2f", week.second)].join("|")
        }.join("\n")
      end

      def ssp_payment
        BigDecimal.new(weekly_payments.map(&:last).sum.round(10).to_s).round(2, BigDecimal::ROUND_UP).to_f
      end

      def self.contractual_earnings_awe(pay, days_worked)
        (pay / BigDecimal.new(days_worked.to_s) * 7).round(2)
      end

      def self.total_earnings_awe(pay, days_worked)
        if days_worked % 7 == 0
          (pay / (days_worked / 7)).round(2)
        else
          (pay / BigDecimal.new(days_worked.to_s) * 7).round(2)
        end
      end

      def self.dates_matching_pattern(from:, to:, pattern:)
        dates = from..to
        # create an array of all dates that would have been normal workdays
        matching_dates = []
        dates.each do |d|
          matching_dates << d if pattern.include?(d.wday.to_s)
        end
        matching_dates
      end

    private

      def weekly_rate_on(date)
        SmartAnswer::Calculators::RatesQuery.new('statutory_sick_pay').rates(date).ssp_weekly_rate
      end

      def max_days_that_can_be_paid
        (28 * pattern_days).round(10)
      end

      def days_to_pay
        payable_days.length
      end

      def sick_pay_weekly_dates
        if @sick_end_date.sunday?
          ssp_week_end = @sick_end_date + 6
        else
          ssp_week_end = @sick_end_date.end_of_week - 1
        end
        (@sick_start_date..ssp_week_end).select { |day| day.wday == 6 }
      end

      def weekly_payments
        payments = sick_pay_weekly_dates.map { |date| [date, weekly_payment(date)] }
        payments.pop while payments.any? and payments.last.last == 0
        payments
      end

      def weekly_payment(week_start_date)
        pay = 0.0
        ((week_start_date - 6)..week_start_date).each do |date|
          pay += daily_rate_from_weekly(weekly_rate_on(date), pattern_days) if payable_days.include?(date)
        end
        BigDecimal.new(pay.round(10).to_s).round(2, BigDecimal::ROUND_UP).to_f
      end

      def days_paid_in_linked_period
        if prev_sick_days > 3
          prev_sick_days - 3
        else
          0
        end
      end

      def init_normal_workdays_missed(days_of_the_week_worked)
        self.class.dates_matching_pattern(
          from: @sick_start_date,
          to: @sick_end_date,
          pattern: days_of_the_week_worked
        )
      end

      def init_payable_days
        # copy not to modify the instance variable we need to keep
        payable_days_temp = normal_workdays_missed.dup
        ## 1. remove up to 3 first dates from the array if there are waiting days in this period
        payable_days_temp.shift(waiting_days)
        ## 2. return only the first days_that_can_be_paid_for_this_period
        payable_days_temp.shift(days_that_can_be_paid_for_this_period)
      end
    end
  end
end
