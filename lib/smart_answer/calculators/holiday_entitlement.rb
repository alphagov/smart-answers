require "bigdecimal"
require "date"

module SmartAnswer::Calculators
  class HolidayEntitlement
    # created for the holiday entitlement calculator
    STATUTORY_HOLIDAY_ENTITLEMENT_IN_WEEKS = BigDecimal(5.6, 10)
    MAXIMUM_STATUTORY_DAYS_PER_WEEK = 5.to_d
    MAXIMUM_STATUTORY_HOLIDAY_ENTITLEMENT_IN_DAYS = 28.to_d
    MONTHS_PER_YEAR = 12.to_d
    DAYS_PER_YEAR = 365.to_d
    DAYS_PER_LEAP_YEAR = 366.to_d
    STANDARD_DAYS_PER_WEEK = 5.to_d

    attr_reader :days_per_week, :hours_per_week, :start_date, :leaving_date, :leave_year_start_date

    def initialize(days_per_week: 0, hours_per_week: 0, start_date: nil, leaving_date: nil, leave_year_start_date: nil)
      @days_per_week = BigDecimal(days_per_week, 10)
      @hours_per_week = BigDecimal(hours_per_week, 10)
      @start_date = start_date
      @leaving_date = leaving_date
      @leave_year_start_date = leave_year_start_date || calculate_leave_year_start_date
    end

    def full_time_part_time_days
      days = STATUTORY_HOLIDAY_ENTITLEMENT_IN_WEEKS * days_per_week
      actual_days = if left_before_year_end? || (days_per_week < STANDARD_DAYS_PER_WEEK)
                      days
                    else
                      [MAXIMUM_STATUTORY_HOLIDAY_ENTITLEMENT_IN_DAYS, days].min
                    end
      (actual_days * fraction_of_year).round(10)
    end

    def rounded_full_time_part_time_days
      if started_after_year_began? || worked_full_year?
        (full_time_part_time_days * 2).ceil / 2.00
      else
        full_time_part_time_days
      end
    end

    def formatted_full_time_part_time_days
      format_number(rounded_full_time_part_time_days)
    end

    def full_time_part_time_hours
      minimum_days_per_week = [days_per_week, MAXIMUM_STATUTORY_DAYS_PER_WEEK].min

      STATUTORY_HOLIDAY_ENTITLEMENT_IN_WEEKS * minimum_days_per_week * (hours_per_week / days_per_week)
    end

    def rounded_full_time_part_time_hours
      if started_after_year_began?
        (rounded_full_time_part_time_days * hours_per_week) / days_per_week
      else
        full_time_part_time_hours
      end
    end

    def formatted_full_time_part_time_hours
      if left_before_year_end? || worked_partial_year?
        format_number(pro_rated_hours, 2)
      else
        format_number(rounded_full_time_part_time_hours, 2)
      end
    end

    def pro_rated_hours
      fraction_of_year * rounded_full_time_part_time_hours
    end

    def fraction_of_year
      days_in_year = leave_year_range.leap? ? DAYS_PER_LEAP_YEAR : DAYS_PER_YEAR

      if started_after_year_began?
        months_worked / MONTHS_PER_YEAR
      elsif worked_partial_year?
        BigDecimal(leaving_date - start_date + 1.0, 10) / days_in_year
      elsif left_before_year_end?
        BigDecimal(leaving_date - leave_year_range.begins_on + 1, 10) / days_in_year
      else
        MONTHS_PER_YEAR / MONTHS_PER_YEAR
      end
    end

  private

    def calculate_leave_year_start_date
      leaving_date ? leaving_date.beginning_of_year : Date.today.beginning_of_year
    end

    def worked_full_year?
      start_date.nil? && leaving_date.nil?
    end

    def started_after_year_began?
      start_date.present? && leaving_date.nil?
    end

    def left_before_year_end?
      start_date.nil? && leaving_date.present?
    end

    def worked_partial_year?
      start_date.present? && leaving_date.present?
    end

    def months_worked
      year_difference = BigDecimal(leave_year_range.ends_on.year - start_date.year, 10)
      month_difference = MONTHS_PER_YEAR * year_difference + leave_year_range.ends_on.month - start_date.month
      leave_year_range.ends_on.day > start_date.day ? month_difference + 1 : month_difference
    end

    def leave_year_range
      SmartAnswer::YearRange.resetting_on(leave_year_start_date).including(date_calc)
    end

    def date_calc
      return leave_year_start_date if worked_full_year?

      return leaving_date if leaving_date

      start_date
    end

    def strip_zeros(number)
      number.to_s.sub(/\.0+$/, "")
    end

    def format_number(number, decimal_places = 1)
      rounded = (number * 10**decimal_places).ceil.to_f / 10**decimal_places
      str = sprintf("%.#{decimal_places}f", rounded)
      strip_zeros(str)
    end
  end
end
