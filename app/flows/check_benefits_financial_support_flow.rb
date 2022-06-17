class CheckBenefitsFinancialSupportFlow < SmartAnswer::Flow
  def define
    name "check-benefits-financial-support"
    content_id "2de3ab4d-e2af-4803-b2e4-9972da293b00"
    status :draft

    radio :where_do_you_live do
      option :england
      option :wales
      option :scotland
      option :"northern-ireland"

      on_response do |response|
        self.calculator = SmartAnswer::Calculators::CheckBenefitsFinancialSupportCalculator.new
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
        question :children_living_with_you
      end
    end

    radio :children_living_with_you do
      option :yes
      option :no

      on_response do |response|
        calculator.children_living_with_you = response
      end

      next_node do
        if calculator.children_living_with_you == "yes"
          question :age_of_children
        else
          question :assets_and_savings
        end
      end
    end

    checkbox_question :age_of_children do
      option :"1_or_under"
      option :"2"
      option :"3_to_4"
      option :"5_to_11"
      option :"12_to_15"
      option :"16_to_17"
      option :"18_to_19"

      on_response do |response|
        calculator.age_of_children = response
      end

      next_node do
        question :children_with_disability
      end
    end

    radio :children_with_disability do
      option :yes
      option :no

      on_response do |response|
        calculator.children_with_disability = response
      end

      next_node do
        question :assets_and_savings
      end
    end

    radio :assets_and_savings do
      option :over_16000
      option :under_16000

      on_response do |response|
        calculator.assets_and_savings = response
      end

      next_node do
        outcome :results
      end
    end

    outcome :results
  end
end
