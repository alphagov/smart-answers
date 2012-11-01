require 'date'
require 'ostruct'

module SmartAnswer::Calculators
  class HolidayEntitlement < OpenStruct
    # created for the holiday entitlement calculator

    def full_time_part_time_days
      days = 5.6 * fraction_of_year * self.days_per_week
      days > days_cap ? days_cap : days
    end

    def full_time_part_time_hours
      5.6 * fraction_of_year * self.hours_per_week  
    end

    def full_time_part_time_hours_and_minutes
      (full_time_part_time_hours * 60).floor.divmod(60)
    end
  
    def days_cap
      28 * fraction_of_year
    end


    def casual_irregular_entitlement
      minutes = 5.6 / 46.4 * total_hours * 60
      minutes.floor.divmod(60)
    end

    def annualised_hours_per_week
      total_hours / 46.4
    end

    def annualised_entitlement
      # These are the same at the moment
      casual_irregular_entitlement
    end

    def compressed_hours_entitlement
      minutes = 5.6 * hours_per_week * 60
      minutes.floor.divmod(60)
    end

    def compressed_hours_daily_average
      minutes = hours_per_week / days_per_week * 60
      minutes.floor.divmod(60)
    end

    def shifts_per_week
      shifts_per_shift_pattern.to_f / days_per_shift_pattern.to_f * 7
    end

    def shift_entitlement
      5.6 * fraction_of_year * shifts_per_week
    end

    def date_calc
      if self.start_date
        Date.parse start_date
      else
        Date.parse leaving_date
      end
    end

    def feb29th_in_year_of_date(date)
      Date.new(date.year, 2, 29)
    end

    def feb29th_in_range(start_date, end_date)
      iterator = start_date
      while iterator <= end_date
        return true if feb29th_in_year_range iterator, start_date, end_date
        iterator = iterator + 1.year
      end
      # Helps with edge conditions - e.g 2011-12-31 to 2012-12-30
      feb29th_in_year_range end_date, start_date, end_date
    end

    def feb29th_in_year_range(iterator, start_date, end_date)
      if iterator.leap?
        feb29th = feb29th_in_year_of_date iterator
        start_date <= feb29th and end_date >= feb29th
      else
        false
      end
    end

    def leave_year_start_end
      if self.leave_year_start_date
        date_leave_year_start_date = Date.parse leave_year_start_date

        needs_offset = date_calc >= date_of_year(date_leave_year_start_date, date_calc.year)
        number_years = date_calc.year - (needs_offset ? 0 : 1)

        leave_year_start = date_of_year(date_leave_year_start_date, number_years)
        leave_year_end = leave_year_start + 1.years - 1.days
      else
        leave_year_start = date_calc.beginning_of_year
        leave_year_end = date_calc.end_of_year
      end

      [leave_year_start, leave_year_end]
    end

    def fraction_of_year
      return 1 if not self.start_date and not self.leaving_date

      leave_year_start, leave_year_end = leave_year_start_end

      # TODO: Check if handling of leap years is correct
      # Currently divides by 366 days if there is a Feb 29th between the start and end of
      # the leave year, and 365 if not. This has the same effect as just checking for a leap
      # year when leave_year_start_date is not set, but should work a little bit better
      # when it is not set.
      days_divide = feb29th_in_range(leave_year_start, leave_year_end) ? 366 : 365

      if self.start_date
        (leave_year_end - date_calc + 1) / days_divide
      else
        (date_calc - leave_year_start + 1) / days_divide
      end
    end

    def formatted_fraction_of_year(dp = 2)
      format_number fraction_of_year, dp
    end

    def format_number(number, dp = 1)
      str = sprintf("%.#{dp}f", number)
      strip_zeros(str)
    end

    def date_of_year(date, year)
      Date.civil(year, date.month, date.day)
    end

    def strip_zeros(number)
      number.to_s.sub(/\.0+$/, '')
    end

    def method_missing(*args)
      # formatted_foo calls format_number on foo
      if args.first.to_s =~ /\Aformatted_(.*)\z/
        format_number self.send($1.to_sym), args[1] || 1
      else
        super
      end
    end
  end
end
