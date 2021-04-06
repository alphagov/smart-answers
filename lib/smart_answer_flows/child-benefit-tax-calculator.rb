module SmartAnswer
  class ChildBenefitTaxCalculatorFlow < Flow
    def define
      name "child-benefit-tax-calculator"
      content_id "0e1de8f1-9909-4e45-a6a3-bffe95470275"
      flow_content_id "26f5df1d-2d73-4abc-85f7-c09c73332693"
      status :published

      # Q1
      value_question :how_many_children?, parse: Integer do
        on_response do |response|
          self.calculator = Calculators::ChildBenefitTaxCalculator.new
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
        Calculators::ChildBenefitTaxCalculator.tax_years.each do |tax_year|
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
          question :child_benefit_start?
        end
      end

      # Q3b
      date_question :child_benefit_start? do
        on_response do |response|
          calculator.store_date(:start_date, response)
        end

        validate(:valid_within_tax_year) do
          calculator.valid_within_tax_year?(:start_date)
        end

        next_node do
          question :add_child_benefit_stop?
        end
      end

      # Q3c
      radio :add_child_benefit_stop? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            question :child_benefit_stop?
          else
            calculator.child_index += 1
            if calculator.child_index < calculator.part_year_children_count
              question :child_benefit_start?
            else
              question :income_details?
            end
          end
        end
      end

      # Q3d
      date_question :child_benefit_stop? do
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
          calculator.child_index += 1
          if calculator.child_index < calculator.part_year_children_count
            question :child_benefit_start?
          else
            question :income_details?
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
end
