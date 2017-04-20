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

        next_node do |response|
          case response
          when 'uk-full-time'
            question :form_needed_for_1?
          when 'uk-part-time'
            question :form_needed_for_2?
          when 'eu-full-time'
            question :what_year_full_time?
          when 'eu-part-time'
            question :what_year_part_time?
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

        next_node do |response|
          case response
          when 'dsa-expenses'
            outcome :outcome_dsa_expenses
          when 'ccg-expenses'
            outcome :outcome_ccg_expenses
          when 'travel-grant'
            outcome :outcome_travel
          else
            question :what_year_full_time?
          end
        end
      end

      multiple_choice :form_needed_for_2? do
        option 'apply-loans-grants'
        option 'proof-identity'
        option 'apply-dsa'
        option 'dsa-expenses'

        save_input_as :form_needed_for_2

        next_node do |response|
          case response
          when 'dsa-expenses'
            outcome :outcome_dsa_expenses
          else
            question :what_year_part_time?
          end
        end
      end

      multiple_choice :what_year_full_time? do
        option 'year-1718'
        option 'year-1617'

        save_input_as :what_year

        next_node do |response|
          case type_of_student
          when 'eu-full-time'
            question :continuing_student?
          when 'uk-full-time'
            case form_needed_for_1
            when 'proof-identity'
              case response
              when 'year-1718'
                outcome :outcome_proof_identity_1718
              when 'year-1617'
                outcome :outcome_proof_identity_1617
              end
            when 'income-details'
              case response
              when 'year-1718'
                outcome :outcome_parent_partner_1718
              when 'year-1617'
                outcome :outcome_parent_partner_1617
              end
            when 'apply-dsa'
              case response
              when 'year-1718'
                outcome :outcome_dsa_1718
              when 'year-1617'
                outcome :outcome_dsa_1617
              end
            when 'apply-ccg'
              case response
              when 'year-1718'
                outcome :outcome_ccg_1718
              when 'year-1617'
                outcome :outcome_ccg_1617
              end
            when 'apply-loans-grants'
              question :continuing_student?
            end
          end
        end
      end

      multiple_choice :what_year_part_time? do
        option 'year-1617'

        save_input_as :what_year

        next_node do |response|
          case type_of_student
          when 'eu-part-time'
            question :continuing_student?
          when 'uk-part-time'
            case form_needed_for_2
            when 'proof-identity'
              case response
              when 'year-1617'
                outcome :outcome_proof_identity_1617
              end
            when 'apply-dsa'
              case response
              when 'year-1617'
                outcome :outcome_dsa_1617_pt
              end
            when 'apply-loans-grants'
              question :continuing_student?
            end
          end
        end
      end

      multiple_choice :continuing_student? do
        option 'continuing-student'
        option 'new-student'

        save_input_as :continuing_student

        next_node do |response|
          case type_of_student
          when 'eu-full-time'
            case what_year
            when 'year-1718'
              case response
              when 'continuing-student'
                outcome :outcome_eu_ft_1718_continuing
              when 'new-student'
                outcome :outcome_eu_ft_1718_new
              end
            when 'year-1617'
              case response
              when 'continuing-student'
                outcome :outcome_eu_ft_1617_continuing
              when 'new-student'
                outcome :outcome_eu_ft_1617_new
              end
            end
          when 'eu-part-time'
            case what_year
            when 'year-1617'
              case response
              when 'continuing-student'
                outcome :outcome_eu_pt_1617_continuing
              when 'new-student'
                outcome :outcome_eu_pt_1617_new
              end
            end
          when 'uk-full-time'
            if form_needed_for_1 == 'apply-loans-grants'
              case what_year
              when 'year-1617'
                case response
                when 'continuing-student'
                  outcome :outcome_uk_ft_1617_continuing
                when 'new-student'
                  outcome :outcome_uk_ft_1617_new
                end
              when 'year-1718'
                case response
                when 'continuing-student'
                  outcome :outcome_uk_ft_1718_continuing
                when 'new-student'
                  outcome :outcome_uk_ft_1718_new
                end
              end
            end
          when 'uk-part-time'
            question :pt_course_start?
          end
        end
      end

      multiple_choice :pt_course_start? do
        option 'course-start-before-01092012'
        option 'course-start-after-01092012'

        next_node do |response|
          case what_year
          when 'year-1617'
            case response
            when 'course-start-before-01092012'
              case continuing_student
              when 'continuing-student'
                outcome :outcome_uk_pt_1617_grant_continuing
              when 'new-student'
                outcome :outcome_uk_pt_1617_grant_new
              end
            when 'course-start-after-01092012'
              case continuing_student
              when 'continuing-student'
                outcome :outcome_uk_pt_1617_continuing
              when 'new-student'
                outcome :outcome_uk_pt_1617_new
              end
            end
          end
        end
      end

      outcome :outcome_ccg_1718
      outcome :outcome_ccg_1617
      outcome :outcome_ccg_expenses
      outcome :outcome_dsa_1718
      outcome :outcome_dsa_1617
      outcome :outcome_dsa_1617_pt
      outcome :outcome_dsa_expenses
      outcome :outcome_eu_ft_1718_continuing
      outcome :outcome_eu_ft_1718_new
      outcome :outcome_eu_ft_1617_continuing
      outcome :outcome_eu_ft_1617_new
      outcome :outcome_eu_pt_1617_continuing
      outcome :outcome_eu_pt_1617_new
      outcome :outcome_parent_partner_1718
      outcome :outcome_parent_partner_1617
      outcome :outcome_proof_identity_1718
      outcome :outcome_proof_identity_1617
      outcome :outcome_travel
      outcome :outcome_uk_pt_1617_continuing
      outcome :outcome_uk_pt_1617_grant_continuing
      outcome :outcome_uk_pt_1617_grant_new
      outcome :outcome_uk_pt_1617_new
      outcome :outcome_uk_ft_1718_continuing
      outcome :outcome_uk_ft_1718_new
      outcome :outcome_uk_ft_1617_continuing
      outcome :outcome_uk_ft_1617_new
    end
  end
end
