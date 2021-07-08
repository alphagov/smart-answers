class ChildBenefitTaxCalculatorFlow < SmartAnswer::Flow
  def define
    name "child-benefit-tax-calculator"
    content_id "0e1de8f1-9909-4e45-a6a3-bffe95470275"
    status :published

    # Q1
    value_question :how_many_children?, parse: Integer do
      on_response do |response|
        self.calculator = SmartAnswer::Calculators::ChildBenefitTaxCalculator.new
        calculator.children_count = response.to_i
      end

      validate(:valid_number_of_children) do
        calculator.valid_number_of_children?
      end

      next_node do
        question :which_tax_year?
      end
    end

    # Q2
    radio :which_tax_year? do
      SmartAnswer::Calculators::ChildBenefitTaxCalculator.tax_years.each do |tax_year|
        option :"#{tax_year}"
      end

      on_response do |response|
        calculator.tax_year = response
      end

      next_node do
        question :is_part_year_claim?
      end
    end

    # Q3
    radio :is_part_year_claim? do
      option :yes
      option :no

      next_node do |response|
        if response == "yes"
          question :how_many_children_part_year?
        else
          question :income_details?
        end
      end
    end

    # Q3a
    value_question :how_many_children_part_year?, parse: Integer do
      on_response do |response|
        calculator.part_year_children_count = response
      end

      validate(:valid_number_of_part_year_children) do
        calculator.valid_number_of_part_year_children?
      end

      next_node do
        question :child_benefit_1_start?
      end
    end

    (1..SmartAnswer::Calculators::ChildBenefitTaxCalculator::MAX_CHILDREN).each do |child_number|
      # Q3b
      date_question "child_benefit_#{child_number}_start?".to_sym do
        template_name "child_benefit_start"

        on_response do |response|
          calculator.store_date(:start_date, response)
        end

        validate(:valid_within_tax_year) do
          calculator.valid_within_tax_year?(:start_date)
        end

        next_node do
          question "add_child_benefit_#{child_number}_stop?".to_sym
        end
      end

      # Q3c
      radio "add_child_benefit_#{child_number}_stop?".to_sym do
        template_name "add_child_benefit_stop"

        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            question "child_benefit_#{child_number}_stop?".to_sym
          else
            calculator.child_number = child_number + 1
            if calculator.child_number <= calculator.part_year_children_count
              question "child_benefit_#{calculator.child_number}_start?".to_sym
            else
              question :income_details?
            end
          end
        end
      end

      # Q3d
      date_question "child_benefit_#{child_number}_stop?".to_sym do
        template_name "child_benefit_stop"

        on_response do |response|
          calculator.store_date(:end_date, response)
        end

        validate(:valid_within_tax_year) do
          calculator.valid_within_tax_year?(:end_date)
        end

        validate(:valid_end_date) do
          calculator.valid_end_date?
        end

        next_node do
          calculator.child_number = child_number + 1
          if calculator.child_number <= calculator.part_year_children_count
            question "child_benefit_#{calculator.child_number}_start?".to_sym
          else
            question :income_details?
          end
        end
      end
    end

    # Q4
    money_question :income_details? do
      on_response do |response|
        calculator.income_details = response
      end

      next_node do
        question :add_allowable_deductions?
      end
    end

    # Q5
    radio :add_allowable_deductions? do
      option :yes
      option :no

      next_node do |response|
        if response == "yes"
          question :allowable_deductions?
        else
          outcome :results
        end
      end
    end

    # Q5a
    money_question :allowable_deductions? do
      on_response do |response|
        calculator.allowable_deductions = response
      end

      next_node do
        question :add_other_allowable_deductions?
      end
    end

    # Q6
    radio :add_other_allowable_deductions? do
      option :yes
      option :no

      next_node do |response|
        if response == "yes"
          question :other_allowable_deductions?
        else
          outcome :results
        end
      end
    end

    # Q6a
    money_question :other_allowable_deductions? do
      on_response do |response|
        calculator.other_allowable_deductions = response
      end
      next_node do
        outcome :results
      end
    end

    outcome :results
  end
end
