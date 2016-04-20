module SmartAnswer
  class BenefitCapCalculatorFlow < Flow
    def define
      content_id "ffe22070-123b-4390-8cc4-51f9d5b5cc74"
      name 'benefit-cap-calculator'
      status :published
      satisfies_need "100696"

      # Routing question
      multiple_choice :choose_cap_to_calculate? do
        option :current

        next_node do
          question :receive_housing_benefit?
        end
      end

      use_shared_logic('benefit-cap-calculator-pre-2016')
    end
  end
end
