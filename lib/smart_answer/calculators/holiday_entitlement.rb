require 'date'
require 'ostruct'

module SmartAnswer::Calculators
  class HolidayEntitlement < OpenStruct
    # created for the holiday entitlement calculator

    def hours_as_seconds(hours)
      hours * 3600
    end

    def seconds_to_hash(seconds)
      mm, ss = seconds.divmod(60)
      hh, mm = mm.divmod(60)
      dd, hh = hh.divmod(24)
      {dd: dd, hh: hh, mm: mm, ss: ss}
    end

    def hours_between_date(date1, date2)
      hash = seconds_to_hash date1.to_datetime.to_i - date2.to_datetime.to_i
      hash[:dd] * 24 + hash[:hh]
    end

    def fraction_of_year(date1, date2)
      days = (seconds_to_hash date1.to_datetime.to_i - date2.to_datetime.to_i)[:dd]
      days.to_f / (Date.today.leap? ? 366 : 365)
    end

    def format_number(number)
      # TODO: round decimal places?
      # TODO: clarify exact rounding with Simon Kaplan
      sprintf("%.1f", number)
    end

    def format_days(days)
      str = sprintf('%.1f', days)
      str.sub(/\.0$/, '')
    end

    def full_time_part_time_days
      days = 5.6 * _fraction_of_year * self.days_per_week
      days > 28 ? 28 : days
    end

    def formatted_full_time_part_time_days
      format_days full_time_part_time_days
    end

    private

    def _fraction_of_year
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
  end
end
