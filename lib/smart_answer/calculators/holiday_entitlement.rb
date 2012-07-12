require 'date'
require 'ostruct'

module SmartAnswer::Calculators
  class HolidayEntitlement < OpenStruct
    # created for the holiday entitlement calculator

    def full_time_part_time_days
      days = 5.6 * fraction_of_year * self.days_per_week
      days > 28 ? 28 : days
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

    def fraction_of_year
      return 1 if not self.start_date and not self.leaving_date

      if self.start_date
        d_d = Date.parse start_date
      else
        d_d = Date.parse leaving_date
      end

      if self.leave_year_start_date
        d_leave_year_start_date = Date.parse leave_year_start_date

        needs_offset = d_d >= date_of_year(d_leave_year_start_date, d_d.year)
        n_year = d_d.year - (needs_offset ? 0 : 1)
        leave_year_start = date_of_year(d_leave_year_start_date, n_year)
        leave_year_end = leave_year_start + (leave_year_start.leap? ? 365.days : 364.days)
      else
        leave_year_start = Date.today.beginning_of_year
        leave_year_end = Date.today.end_of_year
      end

      if self.start_date
        d = Date.parse start_date
        (leave_year_end - d) / (d.leap? ? 366 : 365)
      elsif self.leaving_date
        d = Date.parse leaving_date
        (d - leave_year_start) / (d.leap? ? 366 : 365)
      else
        1
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
2
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
