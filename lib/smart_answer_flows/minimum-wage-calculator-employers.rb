module SmartAnswer
  class MinimumWageCalculatorEmployersFlow < Flow
    def define
      content_id "cc25f6ca-0553-4400-9dba-a43294fee84b"
      name 'minimum-wage-calculator-employers'
      status :published
      satisfies_need "100145"

      # Q1
      multiple_choice :what_would_you_like_to_check? do
        option "current_payment"
        option "past_payment"

        calculate :calculator do |response|
          Calculators::MinimumWageCalculator.new(what_to_check: response)
        end

        calculate :accommodation_charge do
          nil
        end

        permitted_next_nodes = [
          :are_you_an_apprentice?,
          :past_payment_date?
        ]

        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'current_payment'
            :are_you_an_apprentice?
          when 'past_payment'
            :past_payment_date?
          end
        end
      end

      # Q3
      value_question :how_old_are_you?, parse: Integer do
        precalculate :age_title do
          "How old are you?"
        end

        validate do |response|
          calculator.valid_age?(response)
        end

        permitted_next_nodes = [
          :under_school_leaving_age,
          :how_often_do_you_get_paid?
        ]

        next_node(permitted: permitted_next_nodes) do |response|
          calculator.age = response
          if calculator.under_school_leaving_age?
            :under_school_leaving_age
          else
            :how_often_do_you_get_paid?
          end
        end
      end

      use_shared_logic "minimum_wage"
    end
  end
end
