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

    radio :over_state_pension_age do
      option :yes
      option :no

      on_response do |response|
        calculator.over_state_pension_age = response
      end

      next_node do
        question :are_you_working
      end
    end

    radio :are_you_working do
      option :yes_over_16_hours_per_week
      option :yes_under_16_hours_per_week
      option :no

      on_response do |response|
        calculator.are_you_working = response
      end

      next_node do
        question :disability_or_health_condition
      end
    end
  end
end
