require 'date'

module SmartAnswer::Calculators
  class AgriculturalHolidayEntitlementCalculator
    # created for the agricultural holiday entitlement calculator
    include ActiveModel::Model

    attr_accessor :days_worked_per_week
    attr_accessor :holiday_starts_on
    attr_accessor :total_days_worked
    attr_accessor :weeks_at_current_employer

    def holiday_entitlement_days
      # This is calculated as a flat number based on the days you work
      # per week
      if !days_worked_per_week.nil?
        days = holiday_days(days_worked_per_week)
      elsif !weeks_from_october_1.nil?
        days = holiday_days(total_days_worked.to_f / weeks_from_october_1.to_f).round(10)
      end
      if weeks_at_current_employer.nil?
        days
      else
        (days * (weeks_at_current_employer / 52.0)).round(10)
      end
    end

    def weeks_from_october_1
      weeks_worked(holiday_starts_on)
    end

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
      days_worked_per_week = days_worked_per_week.to_f
      if days_worked_per_week > 6
        38
      elsif days_worked_per_week > 5
        35
      elsif days_worked_per_week > 4
        31
      elsif days_worked_per_week > 3
        25
      elsif days_worked_per_week > 2
        20
      elsif days_worked_per_week > 1
        13
      else
        7.5
      end
    end
  end
end
