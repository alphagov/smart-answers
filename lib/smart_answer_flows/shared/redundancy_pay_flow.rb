module SmartAnswer
  module Shared
    class RedundancyPayFlow < Flow
      def define
        date_question :date_of_redundancy? do
          from { Date.civil(2012, 1, 1) }
          to { Date.today.end_of_year }
          validate_in_range

          calculate :rates do |response|
            Calculators::RedundancyCalculator.redundancy_rates(response)
          end

          calculate :ni_rates do |response|
            Calculators::RedundancyCalculator.northern_ireland_redundancy_rates(response)
          end

          calculate :rate do
            rates.rate
          end

          calculate :ni_rate do
            ni_rates.rate
          end

          calculate :max_amount do
            rates.max
          end

          calculate :ni_max_amount do
            ni_rates.max
          end

          next_node do
            question :age_of_employee?
          end
        end

        value_question :age_of_employee?, parse: :to_i do
          calculate :employee_age do |response|
            age = response
            raise InvalidResponse if age < 16 || age > 100
            age
          end
          calculate :years_available do
            employee_age - 15
          end
          next_node do
            question :years_employed?
          end
        end

        value_question :years_employed?, parse: Float do
          save_input_as :years_employed
          calculate :years_employed do |response|
            ye = response.floor
            raise InvalidResponse if ye.to_i > years_available
            ye
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
          calculate :calculator do |response|
            Calculators::RedundancyCalculator.new(rate, employee_age, years_employed, response)
          end

          calculate :ni_calculator do |response|
            Calculators::RedundancyCalculator.new(ni_rate, employee_age, years_employed, response)
          end

          calculate :statutory_redundancy_pay do
            calculator.format_money(calculator.pay.to_f)
          end

          calculate :statutory_redundancy_pay_ni do
            calculator.format_money(ni_calculator.pay.to_f)
          end

          calculate :number_of_weeks_entitlement do
            calculator.number_of_weeks_entitlement
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
  end
end
