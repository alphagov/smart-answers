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
      if self.start_date
        d = Date.parse(start_date)
        (d.end_of_year - d) / (d.leap? ? 366 : 365)
      elsif self.leaving_date
        d = Date.parse(leaving_date)
        (d - d.beginning_of_year) / (d.leap? ? 366 : 365)
      else
        1
      end
    end

    def formatted_fraction_of_year
      sprintf('%.2f', fraction_of_year)
    end

    def format_number(number)
      str = sprintf("%.1f", number)
      str.sub(/\.0$/, '')
    end

    def method_missing(*args)
      if args.first.to_s =~ /\Aformatted_(.*)\z/
        format_number self.send($1.to_sym)
      else
        super
      end
    end
  end
end
