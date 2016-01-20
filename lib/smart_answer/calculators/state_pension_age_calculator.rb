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

    def state_pension_date(sp_gender = gender)
      StatePensionDateQuery.find(dob, sp_gender)
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

    def before_state_pension_date?
      Date.today < state_pension_date
    end

    def within_four_months_one_day_from_state_pension?
      Date.today > state_pension_date.months_ago(4)
    end

    def under_20_years_old?
      dob > 20.years.ago
    end

    def ni_start_date
      (dob + 19.years)
    end

    def ni_years_to_date_from_dob
      today = Date.today
      years = today.year - ni_start_date.year
      if (today.month < dob.month) || ((today.month == dob.month) && (today.day < dob.day))
        years = years - 1
      end
      years
    end

    def over_55?
      Date.today >= dob.advance(years: 55)
    end
  end
end
