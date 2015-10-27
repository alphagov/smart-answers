module SmartAnswer
  class AmIGettingMinimumWageFlow < Flow
    def define
      content_id "111e006d-2b22-4b1f-989a-56bb61355d68"
      name 'am-i-getting-minimum-wage'
      status :published
      satisfies_need "100145"

      # Q1
      multiple_choice :what_would_you_like_to_check? do
        option "current_payment"
        option "past_payment"
        option "current_payment_april_2016"

        permitted_next_nodes = [
          :are_you_an_apprentice?,
          :past_payment_date?
        ]

        calculate :calculator do |response|
          Calculators::MinimumWageCalculator.new(check: response)
        end

        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'current_payment', 'current_payment_april_2016'
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
