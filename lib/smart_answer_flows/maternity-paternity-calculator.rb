module SmartAnswer
  class MaternityPaternityCalculatorFlow < Flow
    def define
      content_id "05d5412d-455b-485e-a570-020c9176a46e"
      name 'maternity-paternity-calculator'
      status :published
      satisfies_need "100990"

      use_erb_templates_for_questions

      ## Q1
      multiple_choice :what_type_of_leave? do
        save_input_as :leave_type
        option :maternity
        option :paternity
        option :adoption

        calculate :leave_spp_claim_link do
          nil
        end
        calculate :notice_of_leave_deadline do
          nil
        end
        calculate :monthly_pay_method do
          nil
        end
        calculate :smp_calculation_method do
          nil
        end
        calculate :pay_pattern do
          nil
        end
        calculate :sap_calculation_method do
          nil
        end
        calculate :above_lower_earning_limit do
          nil
        end
        calculate :paternity_adoption do
          nil
        end
        calculate :spp_calculation_method do
          nil
        end
        calculate :has_contract do
          nil
        end
        calculate :paternity_employment_start do
          nil
        end

        permitted_next_nodes = [
          :baby_due_date_maternity?,
          :leave_or_pay_for_adoption?,
          :taking_paternity_leave_for_adoption?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'maternity'
            :baby_due_date_maternity?
          when 'paternity'
            :leave_or_pay_for_adoption?
          when 'adoption'
            :taking_paternity_leave_for_adoption?
          end
        end
      end

      use_shared_logic ("adoption-calculator")
      use_shared_logic ("paternity-calculator")
      use_shared_logic ("maternity-calculator")
    end
  end
end
