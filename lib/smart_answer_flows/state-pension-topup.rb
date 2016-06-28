module SmartAnswer
  class StatePensionTopupFlow < Flow
    def define
      content_id "8721750f-f0dc-4756-81be-1716c7d47844"
      name 'state-pension-topup'
      status :published
      satisfies_need "100865"

      #Q1
      date_question :dob_age? do
        date_of_birth_defaults

        on_response do |response|
          self.calculator = Calculators::StatePensionTopupCalculator.new
          calculator.date_of_birth = response
        end

        next_node_calculation(:too_young) do
          calculator.too_young?(calculator.date_of_birth)
        end

        next_node do
          if too_young
            outcome :outcome_pension_age_not_reached
          else
            question :gender?
          end
        end
      end

      #Q2
      multiple_choice :gender? do
        option :male
        option :female

        on_response do |response|
          calculator.gender = response
        end

        next_node_calculation(:male_and_too_young) do
          calculator.too_young?(calculator.date_of_birth, calculator.gender)
        end

        next_node do
          if male_and_too_young
            outcome :outcome_pension_age_not_reached
          else
            question :how_much_extra_per_week?
          end
        end
      end

      #Q3
      money_question :how_much_extra_per_week? do
        on_response do |response|
          calculator.weekly_amount = response
        end

        calculate :integer_value do |response|
          money = response.to_f
          if (money % 1 != 0) || (money > 25 || money < 1)
            raise SmartAnswer::InvalidResponse
          end
        end

        next_node do
          outcome :outcome_topup_calculations
        end
      end

      #A1
      outcome :outcome_topup_calculations do
        precalculate :weekly_amount do
          calculator.weekly_amount
        end

        precalculate :amounts_vs_ages do
          calculator.lump_sum_and_age
        end
      end
      #A2
      outcome :outcome_pension_age_not_reached
    end
  end
end
