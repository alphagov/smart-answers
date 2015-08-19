module SmartAnswer
  class MinimumWageCalculatorEmployersFlow < Flow
    def define
      name 'minimum-wage-calculator-employers'
      status :published
      satisfies_need "100145"

      use_shared_logic "minimum_wage"
    end
  end
end
