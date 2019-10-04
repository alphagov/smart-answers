require "bigdecimal"
require "date"

module SmartAnswer::Calculators
  class HolidayEntitlement
    # created for the holiday entitlement calculator
    STATUTORY_HOLIDAY_ENTITLEMENT_IN_WEEKS = BigDecimal(5.6, 10)
    MAXIMUM_STATUTORY_HOLIDAY_ENTITLEMENT_IN_DAYS = 28.to_d
    MONTHS_PER_YEAR = 12.to_d
    DAYS_PER_YEAR = 365.to_d
    DAYS_PER_LEAP_YEAR = 366.to_d
    STANDARD_DAYS_PER_WEEK = 5.to_d

    attr_reader :days_per_week, :start_date, :leaving_date, :leave_year_start_date

    def initialize(days_per_week: 0, start_date: nil, leaving_date: nil, leave_year_start_date: Date.today.beginning_of_year)
      @days_per_week = BigDecimal(days_per_week, 10)
      @start_date = start_date
      @leaving_date = leaving_date
      @leave_year_start_date = leave_year_start_date
    end

    def full_time_part_time_days
      days = STATUTORY_HOLIDAY_ENTITLEMENT_IN_WEEKS * days_per_week
      actual_days = if left_before_year_end || (days_per_week < STANDARD_DAYS_PER_WEEK)
                      days
                    else
                      [MAXIMUM_STATUTORY_HOLIDAY_ENTITLEMENT_IN_DAYS, days].min
                    end
      (actual_days * fraction_of_year).round(10)
    end

    def formatted_full_time_part_time_days
      if started_after_year_began || worked_full_year
        rounded_days = (full_time_part_time_days * 2).ceil / 2.00
        format_number(rounded_days)
      else
        format_number(full_time_part_time_days)
      end
    end

    def months_worked
      year_difference = BigDecimal(leave_year_range.ends_on.year - start_date.year, 10)
      month_difference = MONTHS_PER_YEAR * year_difference + leave_year_range.ends_on.month - start_date.month

      leave_year_range.ends_on.day > start_date.day ? month_difference + 1 : month_difference
    end

    def fraction_of_year
      if started_after_year_began || worked_partial_year
        months_worked / MONTHS_PER_YEAR
      elsif left_before_year_end
        days_in_year = leave_year_range.leap? ? DAYS_PER_LEAP_YEAR : DAYS_PER_YEAR
        (leaving_date - leave_year_range.begins_on + 1) / days_in_year
      else
        MONTHS_PER_YEAR / MONTHS_PER_YEAR
      end
    end

    private

    def worked_full_year
      !start_date && !leaving_date
    end

    def started_after_year_began
      start_date && !leaving_date
    end

    def left_before_year_end
      !start_date && leaving_date
    end

    def worked_partial_year
      start_date && leaving_date
    end

    def strip_zeros(number)
      number.to_s.sub(/\.0+$/, "")
    end

    def leave_year_range
      SmartAnswer::YearRange.resetting_on(leave_year_start_date).including(date_calc)
    end

    def date_calc
      if start_date
        start_date
      else
        leaving_date
      end
    end

    def format_number(number, decimal_places = 1)
      rounded = (number * 10**decimal_places).ceil.to_f / 10**decimal_places
      str = sprintf("%.#{decimal_places}f", rounded)
      strip_zeros(str)
    end
  end
end
