module SmartAnswer
  class StudentFinanceFormsFlow < Flow
    def define
      name 'student-finance-forms'
      status :published
      satisfies_need "100982"

      multiple_choice :type_of_student? do
        option 'uk-full-time' => :form_needed_for_1?
        option 'uk-part-time' => :form_needed_for_2?
        option 'eu-full-time' => :what_year?
        option 'eu-part-time' => :what_year?

        save_input_as :type_of_student
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

        # * form_needed_for_1 is 'dsa-expenses' => outcome_dsa_expenses
        # * form_needed_for_1 is 'ccg-expenses' => outcome_ccg_expenses
        # * form_needed_for_1 is 'travel-grant' => outcome_travel
        # * otherwise => what_year_uk_fulltime
      end

      multiple_choice :form_needed_for_2? do
        option 'apply-loans-grants'
        option 'proof-identity'
        option 'apply-dsa'
        option 'dsa-expenses'

        save_input_as :form_needed_for_2

        # * form_needed_for_2 is 'dsa-expenses' => outcome_dsa_expenses
        # * otherwise => what_year
      end

      multiple_choice :continuing_student? do
        option 'continuing-student'
        option 'new-student'

        # * type_of_student is 'eu-full-time'
        #   * what_year is 'year-1415'
        #     * continuing_student is 'continuing-student' => outcome_eu_ft_1415_continuing
        #     * continuing_student is 'new-student' => outcome_eu_ft_1415_new
        #   * what_year is 'year-1516'
        #     * continuing_student is 'continuing-student' => outcome_eu_ft_1516_continuing
        #     * continuing_student is 'new-student' => outcome_eu_ft_1516_new
        # * type_of_student is 'eu-part-time'
        #   * what_year is 'year-1415'
        #     * continuing_student is 'continuing-student' => outcome_eu_pt_1415_continuing
        #     * continuing_student is 'new-student' => outcome_eu_pt_1415_new
        #   * what_year is 'year-1516'
        #     * continuing_student is 'continuing-student' => outcome_eu_pt_1516_continuing
        #     * continuing_student is 'new-student' => outcome_eu_pt_1516_new
        # * type_of_student is 'uk-full-time'
        #   * what_year is 'year-1415'
        #     * form_needed_for_1 is 'apply-loans-grants'
        #       * continuing_student is 'continuing-student' => outcome_uk_ft_1415_continuing
        #       * continuing_student is 'new-student' => outcome_uk_ft_1415_new
        #   * what_year is 'year-1516'
        #     * form_needed_for_1 is 'apply-loans-grants'
        #       * continuing_student is 'continuing-student' => outcome_uk_ft_1516_continuing
        #       * continuing_student is 'new-student' => outcome_uk_ft_1516_new
        # * type_of_student is 'uk-part-time' => pt_course_start
      end

      multiple_choice :pt_course_start? do
        option 'course-start-before-01092012'
        option 'course-start-after-01092012'

        # * what_year is 'year-1415'
        #   * pt_course_start is 'course-start-before-01092012' => outcome_uk_pt_1415_grant
        #   * pt_course_start is 'course-start-after-01092012'
        #     * continuing_student is 'continuing-student' => outcome_uk_pt_1415_continuing
        #     * continuing_student is 'new-student' => outcome_uk_pt_1415_new
        # * what_year is 'year-1516'
        #   * pt_course_start is 'course-start-before-01092012'
        #     * continuing_student is 'continuing-student' => outcome_uk_ptgc_1516_grant
        #     * continuing_student is 'new-student' => outcome_uk_ptgn_1516_grant
        #   * pt_course_start is 'course-start-after-01092012'
        #     * continuing_student is 'continuing-student' => outcome_uk_pt_1516_continuing
        #     * continuing_student is 'new-student' => outcome_uk_pt_1516_new
      end


      use_outcome_templates
    end
  end
end
