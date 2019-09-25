require "date"
require "ostruct"

module SmartAnswer::Calculators
  class HolidayEntitlement < OpenStruct
    # created for the holiday entitlement calculator
    STATUTORY_HOLIDAY_ENTITLEMENT_IN_WEEKS = 5.6
    MAXIMUM_STATUTORY_HOLIDAY_ENTITLEMENT_IN_DAYS = 28.0

    def full_time_part_time_days
      days = STATUTORY_HOLIDAY_ENTITLEMENT_IN_WEEKS * days_per_week
      days_cap = MAXIMUM_STATUTORY_HOLIDAY_ENTITLEMENT_IN_DAYS
      actual_days = days > days_cap ? days_cap : days
      (actual_days * fraction_of_year).round(10)
    end

    def full_time_part_time_hours
      hours = STATUTORY_HOLIDAY_ENTITLEMENT_IN_WEEKS * hours_per_week
      hours_in_day = hours_per_week.to_f / days_per_week
      hours_cap = MAXIMUM_STATUTORY_HOLIDAY_ENTITLEMENT_IN_DAYS * hours_in_day
      actual_hours = hours > hours_cap ? hours_cap : hours
      (actual_hours * fraction_of_year).round(10)
    end

    def full_time_part_time_hours_and_minutes
      (full_time_part_time_hours * 60).ceil.divmod(60).map(&:ceil)
    end

    def compressed_hours_entitlement
      minutes = STATUTORY_HOLIDAY_ENTITLEMENT_IN_WEEKS * hours_per_week * 60
      minutes.ceil.divmod(60).map(&:ceil)
    end

    def compressed_hours_daily_average
      minutes = hours_per_week.to_f / days_per_week * 60
      minutes.ceil.divmod(60).map(&:ceil)
    end

    def shift_entitlement
      (STATUTORY_HOLIDAY_ENTITLEMENT_IN_WEEKS * fraction_of_year * shifts_per_week).round(10)
    end

    def fraction_of_year
      return 1 if self.start_date.nil? && self.leaving_date.nil?

      days_divide = leave_year_range.leap? ? 366 : 365

      if start_date && leaving_date
        (leaving_date - start_date + 1.0) / days_divide
      elsif leaving_date
        (leaving_date - leave_year_range.begins_on + 1.0) / days_divide
      else
        (leave_year_range.ends_on - start_date + 1.0) / days_divide
      end
    end

    def formatted_fraction_of_year(decimals = 2)
      format_number(fraction_of_year, decimals)
    end

    def strip_zeros(number)
      number.to_s.sub(/\.0+$/, "")
    end

    # rubocop:disable Style/MissingRespondToMissing
    def method_missing(symbol, *args)
      # formatted_foo calls format_number on foo
      formatting_method = formatting_method(symbol)
      if formatting_method
        format_number(send(formatting_method), args.first || 1)
      else
        super
      end
    end
    # rubocop:enable Style/MissingRespondToMissing

    def respond_to?(symbol, include_all = false)
      formatting_method(symbol).present? || super
    end

  private

    def formatting_method(symbol)
      matches = symbol.to_s.match(/\Aformatted_(.*)\z/)
      matches ? matches[1].to_sym : nil
    end

    def leave_year_range
      leave_year_start = self.leave_year_start_date || "1 January"
      SmartAnswer::YearRange.resetting_on(leave_year_start).including(date_calc)
    end

    def shifts_per_week
      (shifts_per_shift_pattern.to_f / days_per_shift_pattern * 7).round(10)
    end

    def date_calc
      if self.start_date
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
