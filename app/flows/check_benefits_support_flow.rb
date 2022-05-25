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

    radio :disability_or_health_condition do
      option :yes
      option :no

      on_response do |response|
        calculator.disability_or_health_condition = response
      end

      next_node do
        if calculator.disability_or_health_condition == "yes"
          question :disability_affecting_work
        else
          question :carer_disability_or_health_condition
        end
      end
    end

    radio :disability_affecting_work do
      option :yes_unable_to_work
      option :yes_limits_work
      option :no

      on_response do |response|
        calculator.disability_affecting_work = response
      end

      next_node do
        question :carer_disability_or_health_condition
      end
    end

    radio :carer_disability_or_health_condition do
      option :yes
      option :no

      on_response do |response|
        calculator.carer_disability_or_health_condition = response
      end

      next_node do
        if calculator.carer_disability_or_health_condition == "yes"
          question :unpaid_care_hours
        else
          question :children_living_with_you
        end
      end
    end
  end
end
