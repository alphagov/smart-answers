module SmartAnswer
  class ChildBenefitTaxCalculatorFlow < Flow
    def define
      name "child-benefit-tax-calculator"
      start_page_content_id "201fff60-1cad-4d91-a5bf-d7754b866b87"
      flow_content_id "26f5df1d-2d73-4abc-85f7-c09c73332693"
      status :draft

      # Q1
      value_question :how_many_children?, parse: Integer do
        on_response do |response|
          self.calculator = Calculators::ChildBenefitTaxCalculator.new
          calculator.children_count = response.to_i
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

        next_node do
          question :child_benefit_start?
        end
      end

      # Q3b
      date_question :child_benefit_start? do
        on_response do |response|
          calculator.store_date(:start_date, response)
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
            question :child_benefit_stop?
        end
      end

      # Q3d
      date_question :child_benefit_stop? do
        on_response do |response|
          calculator.store_date(:end_date, response)
        end

        next_node do
            question :income_details?
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
            question :allowable_deductions?
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
            question :other_allowable_deductions?
        end
      end

      # Q6a
      money_question :other_allowable_deductions? do
        on_response do |response|
          calculator.other_allowable_deductions = response
        end
        next_node do
          outcome :outcome_1
        end
      end

      outcome :outcome_1
    end
  end
end
