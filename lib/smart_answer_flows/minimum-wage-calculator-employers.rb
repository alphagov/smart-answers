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

        permitted_next_nodes = [
          :are_you_an_apprentice?,
          :past_payment_date?
        ]

        calculate :calculator do
          Calculators::MinimumWageCalculator.new
        end

        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'current_payment'
            :are_you_an_apprentice?
          when 'past_payment'
            :past_payment_date?
          end
        end
      end

      use_shared_logic "minimum_wage"
    end
  end
end
