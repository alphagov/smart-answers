class RedundancyPayFlow < SmartAnswer::Flow
  def define
    date_question :date_of_redundancy? do
      from { SmartAnswer::Calculators::RedundancyCalculator.first_selectable_date }
      to { SmartAnswer::Calculators::RedundancyCalculator.last_selectable_date }
      validate_in_range

      on_response do |response|
        self.rates = SmartAnswer::Calculators::RedundancyCalculator.redundancy_rates(response)
        self.ni_rates = SmartAnswer::Calculators::RedundancyCalculator.northern_ireland_redundancy_rates(response)
        self.rate = rates.rate
        self.ni_rate = ni_rates.rate
        self.max_amount = rates.max
        self.ni_max_amount = ni_rates.max
      end

      next_node do
        question :age_of_employee?
      end
    end

    value_question :age_of_employee?, parse: :to_i do
      on_response do |response|
        self.employee_age = response
        self.years_available = employee_age - 15
      end

      validate do
        employee_age.between?(16, 100)
      end

      next_node do
        question :years_employed?
      end
    end

    value_question :years_employed?, parse: Float do
      on_response do |response|
        self.years_employed = response.floor
      end

      validate do
        years_employed.to_i <= years_available
      end

      next_node do |response|
        if response.floor < 2
          outcome :done_no_statutory
        else
          question :weekly_pay_before_tax?
        end
      end
    end

    money_question :weekly_pay_before_tax? do
      on_response do |response|
        self.calculator = SmartAnswer::Calculators::RedundancyCalculator.new(rate, employee_age, years_employed, response)
        self.ni_calculator = SmartAnswer::Calculators::RedundancyCalculator.new(ni_rate, employee_age, years_employed, response)
        self.statutory_redundancy_pay = calculator.format_money(calculator.pay.to_f)
        self.statutory_redundancy_pay_ni = calculator.format_money(ni_calculator.pay.to_f)
        self.number_of_weeks_entitlement = calculator.number_of_weeks_entitlement
      end

      next_node do
        if years_employed < 2
          outcome :done_no_statutory
        else
          outcome :done
        end
      end
    end

    outcome :done_no_statutory
    outcome :done
  end
end
