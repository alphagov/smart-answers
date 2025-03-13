require_relative "../date_helper"

module SmartAnswer::Calculators
  class MaternityPayCalculator
    include SmartAnswer::DateHelper

    attr_reader :due_date,
                :expected_week,
                :qualifying_week,
                :employment_start,
                :notice_of_leave_deadline,
                :leave_earliest_start_date,
                :ssp_stop,
                :a_employment_start,
                :leave_type

    attr_accessor :employment_contract,
                  :leave_start_date,
                  :last_payday,
                  :monthly_pay_method,
                  :pre_offset_payday,
                  :pay_date,
                  :pay_day_in_month,
                  :pay_day_in_week,
                  :pay_week_in_month,
                  :period_calculation_method,
                  :work_days,
                  :date_of_birth,
                  :awe,
                  :pay_pattern,
                  :payment_option,
                  :earnings_for_pay_period,
                  :on_payroll

    attr_writer :pay_method, :not_entitled_to_pay_reason

    DAYS_OF_THE_WEEK = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze
    PAYMENT_OPTIONS = {
      weekly: {
        "8": "8 payments or fewer",
        "9": "9 payments",
        "10": "10 payments",
      },
      every_2_weeks: {
        "4": "4 payments or fewer",
        "5": "5 payments",
      },
      every_4_weeks: {
        "1": "1 payment",
        "2": "2 payments",
      },
      monthly: {
        "2": "1 or 2 payments",
        "3": "3 payments",
      },
    }.with_indifferent_access.freeze
    private_constant :PAYMENT_OPTIONS

    def initialize(due_date, leave_type = "maternity")
      expected_start = due_date - due_date.wday
      qualifying_start = 15.weeks.ago(expected_start)

      @due_date = due_date
      @leave_type = leave_type
      @expected_week = SmartAnswer::DateRange.new(
        begins_on: expected_start,
        ends_on: expected_start + 6.days,
      )
      @notice_of_leave_deadline = next_saturday(qualifying_start)
      @qualifying_week = SmartAnswer::DateRange.new(
        begins_on: qualifying_start,
        ends_on: qualifying_start + 6.days,
      )
      @employment_start = @qualifying_week.weeks_after(-25).ends_on
      @leave_earliest_start_date = @expected_week.weeks_after(-11).begins_on
      @ssp_stop = @expected_week.weeks_after(-4).begins_on
    end

    def self.payment_options
      PAYMENT_OPTIONS
    end

    def payment_options
      self.class.payment_options
    end

    def number_of_payments
      if valid_payment_option?
        if weekly? || monthly?
          payment_option.to_f
        elsif every_2_weeks?
          payment_option.to_f * 2
        elsif every_4_weeks?
          payment_option.to_f * 4
        end
      elsif monthly?
        2.0
      else
        8.0
      end
    end

    # monthly? every_2_weeks? every_4_weeks? weekly?
    PAYMENT_OPTIONS.each_key do |frequence|
      define_method "#{frequence}?" do
        pay_pattern == frequence
      end
    end

    def valid_pay_pattern?
      PAYMENT_OPTIONS.keys.map(&:to_s).include?(pay_pattern)
    end

    def format_date(date)
      date.to_fs(:govuk_date) if date
    end

    def format_date_day(date)
      date.to_fs(:govuk_date_with_day) if date
    end

    def payday_offset
      8.weeks.ago(last_payday) + 1
    end

    def relevant_period
      [pre_offset_payday, last_payday]
    end

    def formatted_relevant_period
      relevant_period.map { |p| format_date_day(p) }.join(" and ")
    end

    def leave_end_date
      52.weeks.since(leave_start_date) - 1
    end

    def pay_start_date
      leave_start_date
    end

    def pay_end_date
      pay_duration.weeks.since(pay_start_date) - 1
    end

    def pay_duration
      39
    end

    def notice_request_pay
      28.days.ago(pay_start_date)
    end

    def statutory_maternity_rate
      truncate((average_weekly_earnings.to_f / 100) * 90)
    end

    def round_up_to_nearest_penny(float)
      if truncate(float, decimal_places: 2) == truncate(float)
        float
      else
        truncate(truncate(float), decimal_places: 2, round_up: true)
      end
    end

    def truncate(float, decimal_places: 7, round_up: false)
      offset = "1#{'0' * decimal_places}".to_f # decimal_places: 7 -> 10_000_000.0

      if round_up
        (float * offset).ceil / offset
      else
        (float * offset).floor / offset
      end
    end

    def statutory_maternity_rate_a
      statutory_maternity_rate
    end

    def lower_earning_limit
      RatesQuery.from_file("maternity_paternity_birth").rates(relevant_week.last).lower_earning_limit_rate
    end

    def relevant_week
      @qualifying_week
    end

    def employment_end
      @due_date
    end

    def average_weekly_earnings
      truncate(
        case pay_pattern
        when "monthly"
          earnings_for_pay_period.to_f / number_of_payments * 12 / 52
        else
          earnings_for_pay_period.to_f / number_of_payments
        end,
      ) # HMRC-agreed truncation at 7 decimal places.
    end

    def total_statutory_pay
      paydates_and_pay.map { |h| h[:pay] }.sum.round(2)
    end

    def paydates_and_pay
      paydates = send(:"paydates_#{pay_method}")
      [].tap do |ary|
        last_paydate = pay_start_date
        paydates.each do |paydate|
          # Pay period includes the date of payment hence the range starts the day after.
          pay = pay_for_period(last_paydate, paydate)
          if pay > 0 # rubocop:disable Style/NumericPredicate
            ary << { date: paydate, pay: pay.round(2) }
            last_paydate = paydate + 1
          end
        end
      end
    end

    def paydates_every_2_weeks
      paydates_every_n_days(14)
    end

    def paydates_every_4_weeks
      paydates_every_n_days(28)
    end

    def paydates_first_day_of_the_month
      start_date = pay_start_date.day == 1 ? pay_start_date : (pay_start_date + 1.month).beginning_of_month
      end_date = (pay_end_date + 1.month).beginning_of_month

      [].tap do |ary|
        start_date.step(end_date) do |d|
          ary << d if d.day == 1
        end
      end
    end

    def paydates_last_day_of_the_month
      start_date = Date.civil(pay_start_date.year, pay_start_date.month, -1)
      end_date = Date.civil(pay_end_date.year, pay_end_date.month, -1)
      [].tap do |ary|
        start_date.step(end_date) do |d|
          ary << d if d.day == Date.new(d.year, d.month, -1).day
        end
      end
    end

    def paydates_last_working_day_of_the_month
      first_pay_day = last_working_day_of_the_month(pay_start_date)

      [first_pay_day].tap do |dates|
        while dates.last < pay_end_date
          date = dates.last + 1.month
          dates << Date.new(date.year, date.month, last_working_day_of_the_month_offset(date))
        end
      end
    end

    def last_working_day_of_the_month(date)
      Date.new(date.year, date.month, last_working_day_of_the_month_offset(date))
    end

    def paydates_monthly
      end_date = Date.civil(pay_end_date.year, pay_end_date.month, pay_day_in_month)
      end_date = 1.month.since(end_date) if pay_end_date.day > pay_day_in_month
      [].tap do |ary|
        pay_start_date.step(end_date) do |d|
          ary << d if d.day == pay_day_in_month
        end
      end
    end

    alias_method :paydates_specific_date_each_month, :paydates_monthly

    def paydates_weekly
      [].tap do |ary|
        pay_start_date.step(pay_end_date + 7) do |d|
          ary << d if d.wday == pay_date.wday
        end
      end
    end

    def paydates_weekly_starting
      [].tap do |ary|
        pay_start_date.step(pay_end_date) do |d|
          ary << d if d.wday == (pay_start_date - 1).wday && d > pay_start_date
        end
      end
    end

    def paydates_a_certain_week_day_each_month
      [].tap do |ary|
        months_between_dates(pay_start_date, pay_end_date).each do |date|
          weekdays = weekdays_for_month(date, pay_day_in_week)
          ary << weekdays.send(pay_week_in_month)
        end
        if ary.last && ary.last < pay_end_date
          weekdays = weekdays_for_month(1.month.since(pay_end_date), pay_day_in_week)
          ary << weekdays.send(pay_week_in_month)
        end
      end
    end

    def statutory_rate(date)
      rates = [
        { min: uprating_date(2012), max: uprating_date(2013), amount: 135.45 },
        { min: uprating_date(2013), max: uprating_date(2014), amount: 136.78 },
        { min: uprating_date(2014), max: uprating_date(2015), amount: 138.18 },
        { min: uprating_date(2014), max: uprating_date(2017), amount: 139.58 },
        { min: uprating_date(2017), max: uprating_date(2018), amount: 140.98 },
        { min: uprating_date(2018), max: uprating_date(2019), amount: 145.18 },
        { min: uprating_date(2019), max: uprating_date(2020), amount: 148.68 },
        { min: uprating_date(2020), max: uprating_date(2021), amount: 151.20 },
        { min: uprating_date(2021), max: uprating_date(2022), amount: 151.97 },
        { min: uprating_date(2022), max: uprating_date(2023), amount: 156.66 },
        { min: uprating_date(2023), max: uprating_date(2024), amount: 172.48 },
        { min: uprating_date(2024), max: uprating_date(2025), amount: 184.03 },
        { min: uprating_date(2025), max: uprating_date(2200), amount: 187.18 },
        ### Change year in future
      ]
      rate = rates.find { |r| r[:min] <= date && date < r[:max] } || rates.last
      rate[:amount]
    end

    def current_statutory_rate
      statutory_rate(Time.zone.today)
    end

    def average_weekly_earnings_under_lower_earning_limit?
      average_weekly_earnings < lower_earning_limit
    end

    def payday_offset_formatted
      format_date_day payday_offset
    end

    def above_lower_earning_limit
      average_weekly_earnings >= lower_earning_limit
    end

    def pay_dates_and_pay
      if above_lower_earning_limit
        lines = paydates_and_pay.map do |date_and_pay|
          %(#{date_and_pay[:date].strftime('%e %B %Y')}|£#{sprintf('%.2f', date_and_pay[:pay])})
        end
        lines.join("\n")
      end
    end

    def total_sap
      total_statutory_pay if above_lower_earning_limit
    end

    def total_spp
      total_statutory_pay if above_lower_earning_limit
    end

    def total_smp
      total_statutory_pay if not_entitled_to_pay_reason.blank?
    end

    def pay_method
      @pay_method ||= if monthly_pay_method
                        if monthly_pay_method == "specific_date_each_month" && pay_day_in_month > 28
                          "last_day_of_the_month"
                        else
                          monthly_pay_method
                        end
                      elsif period_calculation_method == "weekly_starting"
                        period_calculation_method
                      else
                        pay_pattern
                      end
    end

    def pay_below_threshold?
      earnings_for_pay_period && average_weekly_earnings_under_lower_earning_limit?
    end

    def not_entitled_to_pay_reason
      return :must_earn_over_threshold if pay_below_threshold?

      @not_entitled_to_pay_reason
    end

  private

    def valid_payment_option?
      valid_pay_pattern? && possible_payment_options.include?(payment_option)
    end

    def possible_payment_options
      @possible_payment_options ||= PAYMENT_OPTIONS.values.flat_map(&:keys)
    end

    def paydates_every_n_days(days)
      [].tap do |ary|
        (pay_date..40.weeks.since(pay_date)).step(days).each do |d|
          ary << d
        end
      end
    end

    def months_between_dates(start_date, end_date)
      start_date.beginning_of_month.step(end_date.beginning_of_month).select do |date|
        date.day == 1
      end
    end

    def within_pay_date_range?(day)
      pay_start_date <= day && day <= pay_end_date
    end

    def rate_changes?(week)
      rate_for(week.first) != rate_for(week.last)
    end

    def pay_for_period(start_date, end_date)
      pay = 0.0
      (start_date..end_date).each_slice(7) do |week|
        if week.size < 7 || !within_pay_date_range?(week.last) || rate_changes?(week)
          # When calculating a partial SMP pay week divide the weekly rate by 7
          # truncating the result at 7 decimal places and increment the total pay
          # for each day of the partial week
          week.each do |day|
            if within_pay_date_range?(day)
              pay += rate_for(day) / 7
            end
          end
        else
          pay += rate_for(week.first)
        end
      end

      round_up_to_nearest_penny(pay)
    end

    # Gives the weekly rate for a date.
    def rate_for(date)
      if date < 6.weeks.since(leave_start_date)
        statutory_maternity_rate_a
      else
        [statutory_rate(date), statutory_maternity_rate_a].min
      end
    end

    def first_sunday_in_month(month, year)
      weekdays_for_month(Date.civil(year, month, 1), 0).first
    end

    def uprating_date(year)
      date = first_sunday_in_month(4, year)
      date += leave_start_date.wday if leave_start_date
      date
    end

    def weekdays_for_month(date, weekday)
      date.beginning_of_month.step(date.end_of_month).select do |iter_date|
        weekday == iter_date.wday
      end
    end

    # Calculate the minus offset from the end of the month
    # for the last working day.
    def last_working_day_of_the_month_offset(date)
      ldm = Date.new(date.year, date.month, -1) # Last day of the month.
      ldm_index = ldm.wday
      offset = -1
      until work_days.include?(ldm_index)
        ldm_index.positive? ? ldm_index -= 1 : ldm_index = 6
        offset -= 1
      end
      offset
    end
  end
end
