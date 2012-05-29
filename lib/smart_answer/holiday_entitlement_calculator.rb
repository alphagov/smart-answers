require 'date'

module SmartAnswer
  class HolidayEntitlementCalculator
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
      (seconds_to_hash date1.to_time - date2.to_time)[:hh]
    end

    def fraction_of_year(date1, date2)
      days = (seconds_to_hash date1.to_time - date2.to_time)[:dd]
      days.to_f / (Date.today.leap? ? 366 : 365)
    end

    def format_number(number)
      # TODO: round decimal places?
      # TODO: clarify exact rounding with Simon Kaplan
      sprintf("%.1f", number)
    end
  end
end
