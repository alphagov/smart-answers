require 'ostruct'

module SmartAnswer::Calculators
  class NightWorkHours < OpenStruct

    def total_hours
      if work_cycle == 7
        weeks_worked * 7 / work_cycle * nights_in_cycle * hours_per_shift + overtime_hours
      else
        weeks_worked * nights_in_cycle * hours_per_shift + overtime_hours
      end
    end

    def average_hours
      total_hours / 2
    end

    def potential_days
      weeks_worked * 7
    end
  end
end
