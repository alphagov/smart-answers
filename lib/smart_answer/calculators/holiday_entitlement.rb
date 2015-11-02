require 'date'
require 'ostruct'

module SmartAnswer::Calculators
  class HolidayEntitlement < OpenStruct
    # created for the holiday entitlement calculator

    def full_time_part_time_days
      days = (5.6 * fraction_of_year * days_per_week).round(10)
      days > days_cap ? days_cap : days
    end

    def full_time_part_time_hours
      (5.6 * fraction_of_year * hours_per_week).round(10)
    end

    def full_time_part_time_hours_and_minutes
      (full_time_part_time_hours * 60).floor.divmod(60).map(&:floor)
    end

    def casual_irregular_entitlement
      minutes = (5.6 / 46.4 * total_hours * 60).round(10)
      minutes.floor.divmod(60).map(&:floor)
    end

    def annualised_hours_per_week
      (total_hours / 46.4).round(10)
    end

    def annualised_entitlement
      # These are the same at the moment
      casual_irregular_entitlement
    end

    def compressed_hours_entitlement
      minutes = (5.6 * hours_per_week * 60).round(10)
      minutes.floor.divmod(60).map(&:floor)
    end

    def compressed_hours_daily_average
      minutes = (hours_per_week / days_per_week * 60).round(10)
      minutes.floor.divmod(60).map(&:floor)
    end

    def shift_entitlement
      (5.6 * fraction_of_year * shifts_per_week).round(10)
    end

    def feb29th_in_range(start_date, end_date)
      iterator = start_date
      while iterator <= end_date
        return true if feb29th_in_year_range(iterator, start_date, end_date)
        iterator = iterator + 1.year
      end
      # Helps with edge conditions - e.g 2011-12-31 to 2012-12-30
      feb29th_in_year_range(end_date, start_date, end_date)
    end

    def fraction_of_year
      return 1 if self.start_date.nil? && self.leaving_date.nil?

      leave_year_start, leave_year_end = leave_year_start_end

      # TODO: Check if handling of leap years is correct
      # Currently divides by 366 days if there is a Feb 29th between the start and end of
      # the leave year, and 365 if not. This has the same effect as just checking for a leap
      # year when leave_year_start_date is not set, but should work a little bit better
      # when it is not set.
      days_divide = feb29th_in_range(leave_year_start, leave_year_end) ? 366 : 365

      if start_date && leaving_date
        (leaving_date - start_date + 1) / days_divide
      elsif leaving_date
        (leaving_date - leave_year_start + 1) / days_divide
      else
        (leave_year_end - start_date + 1) / days_divide
      end
    end

    def formatted_fraction_of_year(dp = 2)
      format_number(fraction_of_year, dp)
    end

    def strip_zeros(number)
      number.to_s.sub(/\.0+$/, '')
    end

    def method_missing(symbol, *args)
      # formatted_foo calls format_number on foo
      if formatting_method = formatting_method(symbol)
        format_number(send(formatting_method), args.first || 1)
      else
        super
      end
    end

    def respond_to?(symbol, include_all = false)
      formatting_method(symbol).present?
    end

  private

    def formatting_method(symbol)
      matches = symbol.to_s.match(/\Aformatted_(.*)\z/)
      matches ? matches[1].to_sym : nil
    end

    def leave_year_start_end
      if self.leave_year_start_date
        needs_offset = date_calc >= date_of_year(leave_year_start_date, date_calc.year)
        number_years = date_calc.year - (needs_offset ? 0 : 1)

        leave_year_start = date_of_year(leave_year_start_date, number_years)
        leave_year_end = leave_year_start + 1.years - 1.days
      else
        leave_year_start = date_calc.beginning_of_year
        leave_year_end = date_calc.end_of_year
      end

      [leave_year_start, leave_year_end]
    end

    def shifts_per_week
      (shifts_per_shift_pattern.to_f / days_per_shift_pattern.to_f * 7).round(10)
    end

    def date_calc
      if self.start_date
        start_date
      else
        leaving_date
      end
    end

    def feb29th_in_year_of_date(date)
      Date.new(date.year, 2, 29)
    end

    def feb29th_in_year_range(iterator, start_date, end_date)
      if iterator.leap?
        feb29th = feb29th_in_year_of_date(iterator)
        start_date <= feb29th && end_date >= feb29th
      else
        false
      end
    end

    def format_number(number, dp = 1)
      str = sprintf("%.#{dp}f", number)
      strip_zeros(str)
    end

    def date_of_year(date, year)
      date.advance(years: year - date.year)
    end

    def days_cap
      (28 * fraction_of_year).round(10)
    end
  end
end
