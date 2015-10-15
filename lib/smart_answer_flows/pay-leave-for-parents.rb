module SmartAnswer
  class PayLeaveForParentFlow < Flow
    def define
      name "pay-leave-for-parents"
      status :published
      satisfies_need "101018"

      multiple_choice :two_carers do
        option "yes"
        option "no"

        next_node :due_date
      end

      date_question :due_date do

        next_node :employment_status_of_mother
      end

      multiple_choice :mother_started_working_before_continuity_start_date do
        option "yes"
        option "no"

        next_node :mother_still_working_on_continuity_end_date
      end

      multiple_choice :mother_still_working_on_continuity_end_date do
        option "yes"
        option "no"

        next_node :mother_salary
      end

      salary_question :mother_salary do

        next_node :mother_earned_more_than_lower_earnings_limit
      end

      multiple_choice :mother_earned_more_than_lower_earnings_limit do
        option "yes"
        option "no"

        next_node do |response|
          # TODO: Manually copy the rules from Smartdown
        end
      end

      multiple_choice :mother_worked_at_least_26_weeks do
        option "yes"
        option "no"

        next_node :mother_earned_at_least_390
      end

      multiple_choice :mother_earned_at_least_390 do
        option "yes"
        option "no"

        next_node do |response|
          # TODO: Manually copy the rules from Smartdown
        end
      end

      salary_question :salary_1_66_weeks do

        next_node do |response|
          # TODO: Manually copy the rules from Smartdown
        end
      end

      multiple_choice :partner_started_working_before_continuity_start_date do
        option "yes"
        option "no"

        next_node :partner_still_working_on_continuity_end_date
      end

      multiple_choice :partner_still_working_on_continuity_end_date do
        option "yes"
        option "no"

        next_node :partner_salary
      end

      salary_question :partner_salary do

        next_node :partner_earned_more_than_lower_earnings_limit
      end

      multiple_choice :partner_earned_more_than_lower_earnings_limit do
        option "yes"
        option "no"

        next_node do |response|
          # TODO: Manually copy the rules from Smartdown
        end
      end

      multiple_choice :partner_worked_at_least_26_weeks do
        option "yes"
        option "no"

        next_node :partner_earned_at_least_390
      end

      multiple_choice :partner_earned_at_least_390 do
        option "yes"
        option "no"

        next_node do |response|
          # TODO: Manually copy the rules from Smartdown
        end
      end

      multiple_choice :employment_status_of_mother do
        option "employee"
        option "worker"
        option "self-employed"
        option "unemployed"

        next_node do |response|
          # TODO: Manually copy the rules from Smartdown
        end
      end

      multiple_choice :employment_status_of_partner do
        option "employee"
        option "worker"
        option "self-employed"
        option "unemployed"

        next_node do |response|
          # TODO: Manually copy the rules from Smartdown
        end
      end

      outcome :outcome_birth_nothing
      outcome :outcome_mat_allowance_14_weeks
      outcome :outcome_mat_allowance
      outcome :outcome_mat_allowance_mat_leave
      outcome :outcome_mat_allowance_mat_leave_mat_shared_leave
      outcome :outcome_mat_allowance_mat_leave_pat_leave_additional_pat_leave
      outcome :outcome_mat_allowance_mat_leave_pat_leave_both_shared_leave
      outcome :outcome_mat_allowance_mat_leave_pat_leave_pat_pay_additional_pat_leave_additional_pat_pay
      outcome :outcome_mat_allowance_mat_leave_pat_leave_pat_pay_both_shared_leave_pat_shared_pay
      outcome :outcome_mat_allowance_mat_leave_pat_leave_pat_pay_pat_shared_leave_pat_shared_pay
      outcome :outcome_mat_allowance_mat_leave_pat_leave_pat_shared_leave
      outcome :outcome_mat_allowance_mat_leave_pat_pay_additional_pat_pay
      outcome :outcome_mat_allowance_mat_leave_pat_pay_mat_shared_leave_pat_shared_pay
      outcome :outcome_mat_allowance_mat_leave_pat_pay_pat_shared_pay
      outcome :outcome_mat_allowance_pat_leave_additional_pat_leave
      outcome :outcome_mat_allowance_pat_leave_pat_pay_additional_pat_leave_additional_pat_pay
      outcome :outcome_mat_allowance_pat_leave_pat_pay_pat_shared_leave_pat_shared_pay
      outcome :outcome_mat_allowance_pat_leave_pat_shared_leave
      outcome :outcome_mat_allowance_pat_pay_additional_pat_pay
      outcome :outcome_mat_allowance_pat_pay_pat_shared_pay
      outcome :outcome_mat_leave
      outcome :outcome_mat_leave_mat_pay
      outcome :outcome_mat_leave_mat_pay_mat_shared_leave_mat_shared_pay
      outcome :outcome_mat_leave_mat_pay_pat_leave_additional_pat_leave
      outcome :outcome_mat_leave_mat_pay_pat_leave_both_shared_leave_mat_shared_pay
      outcome :outcome_mat_leave_mat_pay_pat_leave_pat_pay_additional_pat_leave_additional_pat_pay
      outcome :outcome_mat_leave_mat_pay_pat_leave_pat_pay_both_shared_leave_both_shared_pay
      outcome :outcome_mat_leave_mat_pay_pat_leave_pat_shared_leave
      outcome :outcome_mat_leave_mat_pay_pat_pay_additional_pat_pay
      outcome :outcome_mat_leave_mat_pay_pat_pay_mat_shared_leave_both_shared_pay
      outcome :outcome_mat_leave_mat_shared_leave
      outcome :outcome_mat_leave_pat_leave
      outcome :outcome_mat_leave_pat_leave_additional_pat_leave
      outcome :outcome_mat_leave_pat_leave_mat_shared_leave
      outcome :outcome_mat_leave_pat_leave_pat_pay
      outcome :outcome_mat_leave_pat_leave_pat_pay_additional_pat_leave
      outcome :outcome_mat_leave_pat_leave_pat_pay_mat_shared_leave
      outcome :outcome_mat_leave_pat_pay
      outcome :outcome_mat_leave_pat_pay_mat_shared_leave
      outcome :outcome_mat_pay
      outcome :outcome_mat_pay_mat_shared_pay
      outcome :outcome_mat_pay_pat_leave
      outcome :outcome_mat_pay_pat_leave_additional_pat_leave
      outcome :outcome_mat_pay_pat_leave_pat_pay_additional_pat_leave_additional_pat_pay
      outcome :outcome_mat_pay_pat_leave_pat_pay_pat_shared_leave_both_shared_pay
      outcome :outcome_mat_pay_pat_leave_pat_shared_leave_mat_shared_pay
      outcome :outcome_mat_pay_pat_pay_additional_pat_pay
      outcome :outcome_mat_pay_pat_pay_both_shared_pay
      outcome :outcome_pat_leave
      outcome :outcome_pat_leave_pat_pay
      outcome :outcome_pat_pay
      outcome :outcome_single_birth_nothing
    end
  end
end
