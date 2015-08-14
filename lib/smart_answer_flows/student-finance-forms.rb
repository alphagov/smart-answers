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
        # # What academic year do you want funding for?

        # [choice: what_year]
        # * year-1516: 2015 to 2016
        # * year-1415: 2014 to 2015

        # * type_of_student is 'eu-full-time' => continuing_student
        # * type_of_student is 'eu-part-time' => continuing_student
        # * type_of_student is 'uk-full-time'
        #   * form_needed_for_1 is 'proof-identity'
        #     * what_year is 'year-1415' => outcome_proof_identity_1415
        #     * what_year is 'year-1516' => outcome_proof_identity_1516
        #   * form_needed_for_1 is 'income-details'
        #     * what_year is 'year-1415' => outcome_parent_partner_1415
        #     * what_year is 'year-1516' => outcome_parent_partner_1516
        #   * form_needed_for_1 is 'apply-dsa'
        #     * what_year is 'year-1415' => outcome_dsa_1415
        #     * what_year is 'year-1516' => outcome_dsa_1516
        #   * form_needed_for_1 is 'apply-ccg'
        #       * what_year is 'year-1415' => outcome_ccg_1415
        #       * what_year is 'year-1516' => outcome_ccg_1516
        #   * form_needed_for_1 is 'apply-loans-grants' => continuing_student
        # * type_of_student is 'uk-part-time'
        #   * form_needed_for_2 is 'proof-identity'
        #     * what_year is 'year-1415' => outcome_proof_identity_1415
        #     * what_year is 'year-1516' => outcome_proof_identity_1516
        #   * form_needed_for_2 is 'apply-dsa'
        #     * what_year is 'year-1415' => outcome_dsa_1415_pt
        #     * what_year is 'year-1516' => outcome_dsa_1516_pt
        #   * form_needed_for_2 is 'apply-loans-grants' => continuing_student
      end

      multiple_choice :form_needed_for_1? do
        # # What do you need the form for?

        # [choice: form_needed_for_1]
        # * apply-loans-grants: Apply for student loans and grants
        # * proof-identity: Send proof of identity
        # * income-details: Send parent or partner’s income detail - eg PFF2 or CYI
        # * apply-dsa: Apply for Disabled Students’ Allowances
        # * dsa-expenses: Claim Disabled Students’ Allowances expenses
        # * apply-ccg: Apply for Childcare Grant
        # * ccg-expenses: Childcare Grant costs confirmation
        # * travel-grant: Travel Grant

        # * form_needed_for_1 is 'dsa-expenses' => outcome_dsa_expenses
        # * form_needed_for_1 is 'ccg-expenses' => outcome_ccg_expenses
        # * form_needed_for_1 is 'travel-grant' => outcome_travel
        # * otherwise => what_year_uk_fulltime
      end

      multiple_choice :form_needed_for_2? do
        # # What do you need the form for?

        # [choice: form_needed_for_2]
        # * apply-loans-grants: Apply for student loans and grants
        # * proof-identity: Send proof of identity
        # * apply-dsa: Apply for Disabled Students’ Allowances
        # * dsa-expenses: Claim Disabled Students’ Allowances expenses

        # * form_needed_for_2 is 'dsa-expenses' => outcome_dsa_expenses
        # * otherwise => what_year
      end

      multiple_choice :continuing_student? do
        # # Are you a continuing student?

        # You’re usually a continuing student if you got student finance last year.

        # [choice: continuing_student]
        # * continuing-student: Yes
        # * new-student: No

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
        # Did your part-time course start before 1 September 2012?

        # [choice: pt_course_start]
        # * course-start-before-01092012: Yes
        # * course-start-after-01092012: No

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
