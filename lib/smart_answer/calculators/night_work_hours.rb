require 'ostruct'

module SmartAnswer::Calculators
  class NightWorkHours < OpenStruct
    def total_hours
      potential_days / work_cycle * nights_in_cycle * hours_per_shift + overtime_hours
    end

    def average_hours
      total_hours / 2
    end

    def potential_days
      weeks_worked * 7
    end
  end
end
