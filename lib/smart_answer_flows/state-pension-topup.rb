module SmartAnswer
  class StatePensionTopupFlow < Flow
    def define
      name 'state-pension-topup'
      status :published
      satisfies_need "100865"

      calculator = Calculators::StatePensionTopupCalculator.new

      #Q1
      date_question :dob_age? do
        date_of_birth_defaults

        save_input_as :date_of_birth

        define_predicate(:age_limit_reached?) do |response|
          response < calculator.class::OLDEST_DOB
        end

        define_predicate(:too_young?) do |response|
          response > calculator.class::FEMALE_YOUNGEST_DOB
        end

        next_node_if(:outcome_age_limit_reached_birth, age_limit_reached?)
        next_node_if(:outcome_pension_age_not_reached, too_young?)
        next_node :gender?
      end

      #Q2
      multiple_choice :gender? do
        option :male
        option :female

        save_input_as :gender

        define_predicate(:male_and_too_young?) do |response|
          (response == "male") &
            (date_of_birth > calculator.class::MALE_YOUNGEST_DOB)
        end

        next_node_if(:outcome_pension_age_not_reached, male_and_too_young?)
        next_node :how_much_extra_per_week?
      end

      #Q3
      money_question :how_much_extra_per_week? do
        save_input_as :weekly_amount

        calculate :integer_value do |response|
          money = response.to_f
          if (money % 1 != 0) or (money > 25 or money < 1)
            raise SmartAnswer::InvalidResponse
          end
        end

        next_node :outcome_topup_calculations
      end

      use_outcome_templates

      #A1
      outcome :outcome_topup_calculations do
        precalculate :amounts_vs_ages do
          calculator.lump_sum_and_age(date_of_birth, weekly_amount, gender)
        end
      end
      #A2
      outcome :outcome_pension_age_not_reached
      #A3
      outcome :outcome_age_limit_reached_birth
    end
  end
end
