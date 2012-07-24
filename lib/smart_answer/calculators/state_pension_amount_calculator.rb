module SmartAnswer::Calculators
  class StatePensionAmountCalculator
    attr_reader :gender, :dob, :qualifying_years

    def initialize(answers)
      @gender = answers[:gender]
      @dob = Date.parse(answers[:dob])
      @qualifying_years = answers[:qualifying_years].to_i
    end

    def current_weekly_rate
      107.45
    end

    def years_needed
      44
    end

    def current_year
      Date.today.year
    end

    def years_to_pension
      state_pension_year - current_year
    end

    def what_you_get
      qualifying_years / years_needed * current_weekly_rate
    end

    def you_get_future
      (current_weekly_rate * (1.025**years_to_pension)).round(2)
    end

    def state_pension_year
      60.years.since(dob).year
    end
  end  
end