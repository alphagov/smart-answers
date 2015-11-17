module SmartAnswer
  class StudentFinanceFormsFlow < Flow
    def define
      content_id "67764435-e8ed-4700-a657-2e0432cb1f5b"
      name 'student-finance-forms'
      status :published
      satisfies_need "100982"

      multiple_choice :type_of_student? do
        option 'uk-full-time'
        option 'uk-part-time'
        option 'eu-full-time'
        option 'eu-part-time'

        save_input_as :type_of_student

        permitted_next_nodes = [
          :form_needed_for_1?,
          :form_needed_for_2?,
          :what_year?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'uk-full-time'
            :form_needed_for_1?
          when 'uk-part-time'
            :form_needed_for_2?
          when 'eu-full-time', 'eu-part-time'
            :what_year?
          end
        end
      end

      multiple_choice :form_needed_for_1? do
        option 'apply-loans-grants'
        option 'proof-identity'
        option 'income-details'
        option 'apply-dsa'
        option 'dsa-expenses'
        option 'apply-ccg'
        option 'ccg-expenses'
        option 'travel-grant'

        save_input_as :form_needed_for_1

        permitted_next_nodes = [
          :outcome_ccg_expenses,
          :outcome_dsa_expenses,
          :outcome_travel,
          :what_year?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'dsa-expenses'
            :outcome_dsa_expenses
          when 'ccg-expenses'
            :outcome_ccg_expenses
          when 'travel-grant'
            :outcome_travel
          else
            :what_year?
          end
        end
      end

      multiple_choice :form_needed_for_2? do
        option 'apply-loans-grants'
        option 'proof-identity'
        option 'apply-dsa'
        option 'dsa-expenses'

        save_input_as :form_needed_for_2

        next_node_if(:outcome_dsa_expenses, responded_with('dsa-expenses'))
        next_node(:what_year?)
      end

      multiple_choice :what_year? do
        option 'year-1516'
        option 'year-1415'

        save_input_as :what_year

        next_node_if(:continuing_student?, variable_matches(:type_of_student, %w(eu-full-time eu-part-time)))

        on_condition(variable_matches(:type_of_student, 'uk-full-time')) do

          on_condition(variable_matches(:form_needed_for_1, 'proof-identity')) do
            next_node_if(:outcome_proof_identity_1415, responded_with('year-1415'))
            next_node_if(:outcome_proof_identity_1516, responded_with('year-1516'))
          end

          on_condition(variable_matches(:form_needed_for_1, 'income-details')) do
            next_node_if(:outcome_parent_partner_1415, responded_with('year-1415'))
            next_node_if(:outcome_parent_partner_1516, responded_with('year-1516'))
          end

          on_condition(variable_matches(:form_needed_for_1, 'apply-dsa')) do
            next_node_if(:outcome_dsa_1415, responded_with('year-1415'))
            next_node_if(:outcome_dsa_1516, responded_with('year-1516'))
          end

          on_condition(variable_matches(:form_needed_for_1, 'apply-ccg')) do
            next_node_if(:outcome_ccg_1415, responded_with('year-1415'))
            next_node_if(:outcome_ccg_1516, responded_with('year-1516'))
          end

          next_node_if(:continuing_student?, variable_matches(:form_needed_for_1, 'apply-loans-grants'))
        end

        on_condition(variable_matches(:type_of_student, 'uk-part-time')) do

          on_condition(variable_matches(:form_needed_for_2, 'proof-identity')) do
            next_node_if(:outcome_proof_identity_1415, responded_with('year-1415'))
            next_node_if(:outcome_proof_identity_1516, responded_with('year-1516'))
          end

          on_condition(variable_matches(:form_needed_for_2, 'apply-dsa')) do
            next_node_if(:outcome_dsa_1415_pt, responded_with('year-1415'))
            next_node_if(:outcome_dsa_1516_pt, responded_with('year-1516'))
          end

          next_node_if(:continuing_student?, variable_matches(:form_needed_for_2, 'apply-loans-grants'))
        end
      end

      multiple_choice :continuing_student? do
        option 'continuing-student'
        option 'new-student'

        save_input_as :continuing_student

        on_condition(variable_matches(:type_of_student, 'eu-full-time')) do
          on_condition(variable_matches(:what_year, 'year-1415')) do
            next_node_if(:outcome_eu_ft_1415_continuing, responded_with('continuing-student'))
            next_node_if(:outcome_eu_ft_1415_new, responded_with('new-student'))
          end
          on_condition(variable_matches(:what_year, 'year-1516')) do
            next_node_if(:outcome_eu_ft_1516_continuing, responded_with('continuing-student'))
            next_node_if(:outcome_eu_ft_1516_new, responded_with('new-student'))
          end
        end

        on_condition(variable_matches(:type_of_student, 'eu-part-time')) do
          on_condition(variable_matches(:what_year, 'year-1415')) do
            next_node_if(:outcome_eu_pt_1415_continuing, responded_with('continuing-student'))
            next_node_if(:outcome_eu_pt_1415_new, responded_with('new-student'))
          end

          on_condition(variable_matches(:what_year, 'year-1516')) do
            next_node_if(:outcome_eu_pt_1516_continuing, responded_with('continuing-student'))
            next_node_if(:outcome_eu_pt_1516_new, responded_with('new-student'))
          end
        end

        on_condition(variable_matches(:type_of_student, 'uk-full-time')) do
          on_condition(variable_matches(:form_needed_for_1, 'apply-loans-grants')) do
            on_condition(variable_matches(:what_year, 'year-1415')) do
              next_node_if(:outcome_uk_ft_1415_continuing, responded_with('continuing-student'))
              next_node_if(:outcome_uk_ft_1415_new, responded_with('new-student'))
            end

            on_condition(variable_matches(:what_year, 'year-1516')) do
              next_node_if(:outcome_uk_ft_1516_continuing, responded_with('continuing-student'))
              next_node_if(:outcome_uk_ft_1516_new, responded_with('new-student'))
            end
          end
        end

        next_node_if(:pt_course_start?, variable_matches(:type_of_student, 'uk-part-time'))
      end

      multiple_choice :pt_course_start? do
        option 'course-start-before-01092012'
        option 'course-start-after-01092012'

        on_condition(variable_matches(:what_year, 'year-1415')) do
          next_node_if(:outcome_uk_pt_1415_grant, responded_with('course-start-before-01092012'))
          on_condition(responded_with('course-start-after-01092012')) do
            next_node_if(:outcome_uk_pt_1415_continuing, variable_matches(:continuing_student, 'continuing-student'))
            next_node_if(:outcome_uk_pt_1415_new, variable_matches(:continuing_student, 'new-student'))
          end
        end

        on_condition(variable_matches(:what_year, 'year-1516')) do
          on_condition(responded_with('course-start-before-01092012')) do
            next_node_if(:outcome_uk_ptgc_1516_grant, variable_matches(:continuing_student, 'continuing-student'))
            next_node_if(:outcome_uk_ptgn_1516_grant, variable_matches(:continuing_student, 'new-student'))
          end

          on_condition(responded_with('course-start-after-01092012')) do
            next_node_if(:outcome_uk_pt_1516_continuing, variable_matches(:continuing_student, 'continuing-student'))
            next_node_if(:outcome_uk_pt_1516_new, variable_matches(:continuing_student, 'new-student'))
          end
        end
      end

      outcome :outcome_ccg_1415
      outcome :outcome_ccg_1516
      outcome :outcome_ccg_expenses
      outcome :outcome_dsa_1415
      outcome :outcome_dsa_1415_pt
      outcome :outcome_dsa_1516
      outcome :outcome_dsa_1516_pt
      outcome :outcome_dsa_expenses
      outcome :outcome_eu_ft_1415_continuing
      outcome :outcome_eu_ft_1415_new
      outcome :outcome_eu_ft_1516_continuing
      outcome :outcome_eu_ft_1516_new
      outcome :outcome_eu_pt_1415_continuing
      outcome :outcome_eu_pt_1415_new
      outcome :outcome_eu_pt_1516_continuing
      outcome :outcome_eu_pt_1516_new
      outcome :outcome_parent_partner_1415
      outcome :outcome_parent_partner_1516
      outcome :outcome_proof_identity_1415
      outcome :outcome_proof_identity_1516
      outcome :outcome_travel
      outcome :outcome_uk_ft_1415_continuing
      outcome :outcome_uk_ft_1415_new
      outcome :outcome_uk_ft_1516_continuing
      outcome :outcome_uk_ft_1516_new
      outcome :outcome_uk_pt_1415_continuing
      outcome :outcome_uk_pt_1415_grant
      outcome :outcome_uk_pt_1415_new
      outcome :outcome_uk_pt_1516_continuing
      outcome :outcome_uk_pt_1516_new
      outcome :outcome_uk_ptgc_1516_grant
      outcome :outcome_uk_ptgn_1516_grant
    end
  end
end
