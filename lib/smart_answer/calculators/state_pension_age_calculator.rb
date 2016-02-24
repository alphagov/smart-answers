require "data/state_pension_date_query"

module SmartAnswer::Calculators
  class StatePensionAgeCalculator
    include FriendlyTimeDiff

    attr_reader :dob
    attr_accessor :gender

    def initialize(answers)
      @dob = answers[:dob]
      @gender = answers[:gender] ? answers[:gender].to_sym : nil
    end

    def state_pension_date
      StatePensionDateQuery.state_pension_date(dob, gender)
    end

    def state_pension_age
      if birthday_on_feb_29?
        friendly_time_diff(dob, state_pension_date - 1.day)
      else
        friendly_time_diff(dob, state_pension_date)
      end
    end

    def birthday_on_feb_29?
      dob.month == 2 && dob.day == 29
    end

    def before_state_pension_date?(days: 0)
      Date.today < state_pension_date - days.days
    end

    def bus_pass_qualification_date
      StatePensionDateQuery.bus_pass_qualification_date(dob)
    end

    def pension_credit_date
      StatePensionDateQuery.pension_credit_date(dob)
    end

    def before_pension_credit_date?(days: 0)
      Date.today < pension_credit_date - days.days
    end

    def old_state_pension?
      state_pension_date < Date.parse('6 April 2016')
    end

    def over_16_years_old?
      dob < 16.years.ago
    end
  end
end
