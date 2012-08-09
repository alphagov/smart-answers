require "data/state_pension_query"

module SmartAnswer::Calculators
  class StatePensionAmountCalculator
    attr_reader :gender, :dob, :qualifying_years

    def initialize(answers)
      @gender = answers[:gender].to_sym
      @dob = DateTime.parse(answers[:dob])
      @qualifying_years = answers[:qualifying_years].to_i
    end

    def current_weekly_rate
      107.45
    end

    def years_needed_limit
      {
        male:   Date.parse("6th April 1945"),
        female: Date.parse("6th April 1950")
      }[gender]
    end

    def years_needed_age
      dob < years_needed_limit ? :old : :new
    end

    def years_needed
      {
        male: {
          old: 44,
          new: 30
        },
        female: {
          old: 39,
          new: 44
        }
      }[gender][years_needed_age]
    end

    def current_year
      Date.today.year
    end

    def years_to_pension
      state_pension_year - current_year
    end

    def pension_loss
      current_weekly_rate - what_you_get
    end

    def what_you_get
      what_you_get_raw.round(2)
    end

    def what_you_get_raw
      if qualifying_years < years_needed
        qualifying_years.to_f / years_needed.to_f * current_weekly_rate
      else
        current_weekly_rate
      end
    end

    def you_get_future
      (current_weekly_rate * (1.025**years_to_pension)).round(2)
    end

    def state_pension_year
      state_pension_date.year
    end

    def state_pension_date
      StatePensionQuery.find(dob, gender)
    end

    def state_pension_age
      state_pension_date.year - dob.year
    end

    def before_state_pension_date?
      Date.today < state_pension_date
    end

    def under_20_years_old?
      dob > 20.years.ago
    end
  end
end