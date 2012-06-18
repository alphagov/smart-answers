require 'date'

module SmartAnswer
  class AgriculturalHolidayEntitlementCalculator
    # created for the agricultural holiday entitlement calculator

    def calculation_period
      # Agricultural holiday calculations run from Oct 1 - Oct 1
      this_year_period = Date.civil(Date.today.year, 10, 1)
      if Date.today > this_year_period
        this_year_period
      else
        # last year's Oct 1
        Date.civil(Date.today.year.to_i - 1, 10, 1)
      end
    end

    def weeks_worked(holiday_start)
      days = (holiday_start.to_datetime - calculation_period.to_datetime).to_i
      days / 7
    end

    def available_days
      (Date.today.to_datetime - calculation_period.to_datetime).to_i
    end

    def holiday_days(days_worked_per_week)
      if days_worked_per_week > 6
        38
      elsif days_worked_per_week <= 6 && days_worked_per_week > 5
        35
      elsif days_worked_per_week <= 5 && days_worked_per_week > 4
        31
      elsif days_worked_per_week <= 4 && days_worked_per_week > 3
        25
      elsif days_worked_per_week <= 3 && days_worked_per_week > 2
        20
      elsif days_worked_per_week <= 2 && days_worked_per_week > 1
        13
      else
        7.5
      end
    end
  end
end
