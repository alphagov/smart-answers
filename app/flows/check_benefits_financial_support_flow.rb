class CheckBenefitsFinancialSupportFlow < SmartAnswer::Flow
  def define
    name "check-benefits-financial-support"
    content_id "2de3ab4d-e2af-4803-b2e4-9972da293b00"
    status :published

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
      option :yes
      option :no
      option :no_retired

      on_response do |response|
        calculator.are_you_working = response
      end

      next_node do
        if calculator.are_you_working == "yes"
          question :how_many_paid_hours_work
        else
          question :disability_or_health_condition
        end
      end
    end

    radio :how_many_paid_hours_work do
      option :sixteen_or_more_per_week
      option :sixteen_or_less_per_week

      on_response do |response|
        calculator.how_many_paid_hours_work = response
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
          question :disability_affecting_daily_tasks
        else
          question :carer_disability_or_health_condition
        end
      end
    end

    radio :disability_affecting_daily_tasks do
      option :yes
      option :no

      on_response do |response|
        calculator.disability_affecting_daily_tasks = response
      end

      next_node do
        question :disability_affecting_work
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
          question :on_benefits
        end
      end
    end

    checkbox_question :age_of_children do
      option :pregnant
      option :"1_or_under"
      option :"2"
      option :"3_to_4"
      option :"5_to_7"
      option :"8_to_11"
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
        question :on_benefits
      end
    end

    radio_with_intro :on_benefits do
      option :yes
      option :no
      option :dont_know

      on_response do |response|
        calculator.on_benefits = response
      end

      next_node do |response|
        if response == "yes"
          question :current_benefits
        else
          outcome :assets_and_savings
        end
      end
    end

    checkbox_question :current_benefits do
      option :universal_credit
      option :jobseekers_allowance
      option :employment_and_support_allowance
      option :pension_credit
      option :income_support
      option :housing_benefit

      on_response do |response|
        calculator.current_benefits = response
      end

      validate :error_message do
        calculator.benefits_selected?
      end

      next_node do
        outcome :assets_and_savings
      end
    end

    radio :assets_and_savings do
      option :over_16000
      option :under_16000
      option :none_16000

      on_response do |response|
        calculator.assets_and_savings = response
      end

      next_node do
        question :results
      end
    end

    outcome :results
  end
end
