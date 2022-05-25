class CheckBenefitsSupportFlow < SmartAnswer::Flow
  def define
    name "check-benefits-support"
    content_id "2de3ab4d-e2af-4803-b2e4-9972da293b00"
    status :draft

    radio :where_do_you_live do
      option :england
      option :wales
      option :scotland
      option :"northern-ireland"

      on_response do |response|
        self.calculator = SmartAnswer::Calculators::CheckBenefitsSupportCalculator.new
        calculator.where_do_you_live = response
      end

      next_node do
        question :over_state_pension_age
      end
    end
  end
end
