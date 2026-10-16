class MaternityPaternityPayLeaveFlow < SmartAnswer::Flow
  def define
    content_id "1f6b4ecc-ce2c-488a-b9c7-b78b3bba5598"
    name "maternity-paternity-pay-leave"
    status :published

    radio :two_carers do
      option "yes"
      option "no"

      on_response do |response|
        self.calculator = SmartAnswer::Calculators::MaternityPaternityPayLeaveCalculator.new
        calculator.two_carers = response
      end

      next_node do
        if calculator.two_carers?
          question :where_does_the_mother_partner_live
        else
          question :due_date
        end
      end
    end

    radio :where_does_the_mother_partner_live do
      option "england"
      option "scotland"
      option "wales"
      option "northern_ireland"

      on_response do |response|
        calculator.where_does_the_mother_partner_live = response
      end

      next_node do
        question :due_date
      end
    end

    date_question :due_date do
      on_response do |response|
        calculator.due_date = response
      end

      next_node do
        question :mother_employment_status
      end
    end

    radio :mother_employment_status do
      option "employee"
      option "worker"
      option "self-employed"
      option "unemployed"

      on_response do |response|
        calculator.mother_employment_status = response
      end

      next_node do
        if calculator.two_carers?
          question :partner_employment_status
        elsif mother_employee_or_worker?
          question :mother_started_working_before_continuity_start_date
        else
          question :mother_worked_at_least_26_weeks
        end
      end
    end

    radio :partner_employment_status do
      option "employee"
      option "worker"
      option "self-employed"
      option "unemployed"

      on_response do |response|
        calculator.partner_employment_status = response
      end

      next_node do
        if mother_employee_or_worker?
          question :mother_started_working_before_continuity_start_date
        else
          question :mother_worked_at_least_26_weeks
        end
      end
    end

    radio :mother_started_working_before_continuity_start_date do
      option "yes"
      option "no"

      on_response do |response|
        calculator.mother_started_working_before_continuity_start_date = response
      end

      next_node do
        question :mother_still_working_on_continuity_end_date
      end
    end

    radio :mother_still_working_on_continuity_end_date do
      option "yes"
      option "no"

      on_response do |response|
        calculator.mother_still_working_on_continuity_end_date = response
      end

      next_node do
        question :mother_earned_more_than_lower_earnings_limit
      end
    end

    radio :mother_earned_more_than_lower_earnings_limit do
      option "yes"
      option "no"

      on_response do |response|
        calculator.mother_earned_more_than_lower_earnings_limit = response
      end

      next_node do
        if calculator.mother_continuity? && calculator.mother_earned_more_than_lower_earnings_limit == "yes"
          if calculator.two_carers?
            if partner_employee_or_worker?
              question :partner_started_working_before_continuity_start_date
            elsif partner_self_employed_or_unemployed?
              outcome :outcome_mat_leave_mat_pay
            end
          elsif mother_is_employee?
            outcome :outcome_mat_leave_mat_pay
          elsif mother_is_worker?
            outcome :outcome_mat_pay
          end
        else
          question :mother_worked_at_least_26_weeks
        end
      end
    end

    radio :mother_worked_at_least_26_weeks do
      option "yes"
      option "no"

      on_response do |response|
        calculator.mother_worked_at_least_26_weeks = response
      end

      next_node do
        if mother_employee_or_self_employed? && calculator.mother_worked_at_least_26_weeks == "no"
          if calculator.two_carers?
            if partner_employee_or_worker?
              question :partner_started_working_before_continuity_start_date
            elsif partner_self_employed_or_unemployed?
              if mother_is_employee?
                if calculator.mother_continuity? || calculator.mother_still_working_on_continuity_end_date == "yes"
                  outcome :outcome_mat_leave
                elsif calculator.mother_still_working_on_continuity_end_date == "no"
                  outcome :outcome_birth_nothing
                end
              else
                outcome :outcome_birth_nothing
              end
            end
          elsif mother_is_employee? && calculator.mother_still_working_on_continuity_end_date == "yes"
            outcome :outcome_mat_leave
          else
            outcome :outcome_single_birth_nothing
          end
        elsif mother_is_self_employed?
          if calculator.two_carers? && partner_employee_or_worker?
            question :partner_started_working_before_continuity_start_date
          else
            outcome :outcome_mat_allowance
          end
        elsif calculator.mother_worked_at_least_26_weeks == "no" && !calculator.two_carers?
          outcome :outcome_single_birth_nothing
        else
          question :mother_earned_at_least_390
        end
      end
    end

    radio :mother_earned_at_least_390 do
      option "yes"
      option "no"

      on_response do |response|
        calculator.mother_earned_at_least_390 = response
      end

      next_node do
        if calculator.two_carers?
          if partner_employee_or_worker?
            question :partner_started_working_before_continuity_start_date
          elsif partner_self_employed_or_unemployed?
            if mother_is_employee?
              if calculator.mother_continuity? || calculator.mother_still_working_on_continuity_end_date == "yes"
                if calculator.mother_earnings_employment?
                  outcome :outcome_mat_allowance_mat_leave
                else
                  outcome :outcome_mat_leave
                end
              elsif calculator.mother_still_working_on_continuity_end_date == "no"
                if calculator.mother_earnings_employment?
                  outcome :outcome_mat_allowance
                else
                  outcome :outcome_birth_nothing
                end
              end
            elsif calculator.mother_earnings_employment?
              outcome :outcome_mat_allowance
            elsif mother_worker_or_self_employed? || partner_is_unemployed?
              outcome :outcome_birth_nothing
            elsif partner_is_self_employed?
              outcome :outcome_mat_allowance_14_weeks
            end
          end
        elsif mother_is_employee?
          if calculator.mother_still_working_on_continuity_end_date == "yes"
            if calculator.mother_earnings_employment?
              outcome :outcome_mat_allowance_mat_leave
            else
              outcome :outcome_mat_leave
            end
          elsif calculator.mother_earnings_employment?
            outcome :outcome_mat_allowance
          else
            outcome :outcome_single_birth_nothing
          end
        elsif calculator.mother_earnings_employment?
          outcome :outcome_mat_allowance
        else
          outcome :outcome_single_birth_nothing
        end
      end
    end

    radio :partner_started_working_before_continuity_start_date do
      option "yes"
      option "no"

      on_response do |response|
        calculator.partner_started_working_before_continuity_start_date = response
      end

      next_node do
        outcome :partner_still_working_on_continuity_end_date
      end
    end

    radio :partner_still_working_on_continuity_end_date do
      option "yes"
      option "no"

      on_response do |response|
        calculator.partner_still_working_on_continuity_end_date = response
      end

      next_node do
        outcome :partner_earned_more_than_lower_earnings_limit
      end
    end

    radio :partner_earned_more_than_lower_earnings_limit do
      option "yes"
      option "no"

      on_response do |response|
        calculator.partner_earned_more_than_lower_earnings_limit = response
      end

      next_node do
        if partner_is_employee?
          if calculator.partner_continuity? && calculator.partner_earned_more_than_lower_earnings_limit == "yes"
            if mother_is_employee?
              if calculator.mother_continuity? && calculator.mother_earned_more_than_lower_earnings_limit == "yes"
                outcome :outcome_mat_leave_mat_pay_pat_leave_pat_pay
              elsif calculator.mother_still_working_on_continuity_end_date == "yes"
                if calculator.mother_earnings_employment?
                  outcome :outcome_mat_allowance_mat_leave_pat_leave_pat_pay
                elsif !calculator.mother_earnings_employment?
                  outcome :outcome_mat_leave_pat_leave_pat_pay
                end
              elsif calculator.mother_still_working_on_continuity_end_date == "no"
                if calculator.mother_earnings_employment?
                  outcome :outcome_mat_allowance_pat_leave_pat_pay
                elsif !calculator.mother_earnings_employment?
                  outcome :outcome_pat_leave_pat_pay
                end
              end
            elsif mother_is_worker?
              if calculator.mother_continuity? && calculator.mother_earned_more_than_lower_earnings_limit == "yes"
                outcome :outcome_mat_pay_pat_leave_pat_pay
              elsif calculator.mother_earnings_employment?
                outcome :outcome_mat_allowance_pat_leave_pat_pay
              else
                outcome :outcome_pat_leave_pat_pay
              end
            elsif mother_self_employed_or_unemployed?
              if !calculator.mother_earnings_employment?
                outcome :outcome_pat_leave_pat_pay
              elsif calculator.mother_earnings_employment?
                outcome :outcome_mat_allowance_pat_leave_pat_pay
              end
            end
          elsif calculator.partner_continuity?
            if mother_is_employee?
              if calculator.mother_continuity? && calculator.mother_earned_more_than_lower_earnings_limit == "yes"
                outcome :outcome_mat_leave_mat_pay_pat_leave
              elsif calculator.mother_continuity?
                outcome :outcome_mat_leave_pat_leave
              elsif calculator.mother_still_working_on_continuity_end_date == "yes"
                if calculator.mother_earnings_employment?
                  outcome :outcome_mat_allowance_mat_leave_pat_leave
                else
                  outcome :outcome_mat_leave_pat_leave
                end
              elsif calculator.mother_earnings_employment?
                outcome :outcome_mat_allowance_pat_leave
              else
                outcome :outcome_pat_leave
              end
            elsif mother_is_worker?
              if calculator.mother_continuity? && calculator.mother_earned_more_than_lower_earnings_limit == "yes"
                # TODO: Unsure about mat_pay
                outcome :outcome_mat_pay_pat_leave
              elsif calculator.mother_earnings_employment?
                outcome :outcome_mat_allowance_pat_leave
              else
                outcome :outcome_pat_leave
              end
            elsif mother_self_employed_or_unemployed?
              if calculator.mother_earnings_employment?
                outcome :outcome_mat_allowance_pat_leave
              else
                outcome :outcome_pat_leave
              end
            end
          elsif !calculator.partner_continuity?
            if mother_is_employee?
              if calculator.mother_still_working_on_continuity_end_date == "yes"
                if calculator.mother_continuity?
                  outcome :outcome_mat_leave
                elsif calculator.mother_earnings_employment?
                  outcome :outcome_mat_allowance_mat_leave
                else
                  outcome :outcome_mat_leave
                end
              elsif calculator.mother_earnings_employment?
                outcome :outcome_mat_allowance
              else
                outcome :outcome_birth_nothing
              end
            elsif mother_is_worker?
              if calculator.mother_continuity? && calculator.mother_earned_more_than_lower_earnings_limit == "yes"
                outcome :outcome_mat_pay
              elsif calculator.mother_earnings_employment?
                outcome :outcome_mat_allowance
              else
                outcome :outcome_birth_nothing
              end
            elsif mother_self_employed_or_unemployed?
              if calculator.mother_earnings_employment?
                outcome :outcome_mat_allowance
              else
                outcome :outcome_birth_nothing
              end
            end
          end
        elsif partner_is_worker?
          if calculator.partner_continuity? && calculator.partner_earned_more_than_lower_earnings_limit == "yes"
            if mother_is_employee?
              if calculator.mother_continuity? && calculator.mother_earned_more_than_lower_earnings_limit == "yes"
                outcome :outcome_mat_leave_mat_pay_pat_pay
              elsif calculator.mother_continuity?
                if calculator.mother_earnings_employment?
                  outcome :outcome_mat_allowance_mat_leave_pat_pay
                else
                  outcome :outcome_mat_leave_pat_pay
                end
              elsif calculator.mother_still_working_on_continuity_end_date == "yes"
                if calculator.mother_earnings_employment?
                  outcome :outcome_mat_allowance_mat_leave_pat_pay
                else
                  outcome :outcome_mat_leave_pat_pay
                end
              elsif calculator.mother_still_working_on_continuity_end_date == "no"
                if calculator.mother_earnings_employment?
                  outcome :outcome_mat_allowance_pat_pay
                else
                  outcome :outcome_pat_pay
                end
              end
            elsif mother_is_worker?
              if calculator.mother_continuity? && calculator.mother_earned_more_than_lower_earnings_limit == "yes"
                outcome :outcome_mat_pay_pat_pay
              elsif calculator.mother_earnings_employment?
                outcome :outcome_mat_allowance_pat_pay
              else
                outcome :outcome_pat_pay
              end
            elsif mother_self_employed_or_unemployed?
              if calculator.mother_earnings_employment?
                outcome :outcome_mat_allowance_pat_pay
              else
                outcome :outcome_pat_pay
              end
            end
          elsif calculator.partner_continuity?
            if mother_is_employee?
              if calculator.mother_continuity? && calculator.mother_earned_more_than_lower_earnings_limit == "yes"
                outcome :outcome_mat_leave_mat_pay
              elsif !calculator.mother_continuity?
                if calculator.mother_earnings_employment?
                  outcome :outcome_mat_allowance_mat_leave
                else
                  outcome :outcome_mat_leave
                end
              elsif calculator.mother_still_working_on_continuity_end_date == "yes"
                if calculator.mother_earnings_employment?
                  outcome :outcome_mat_allowance_mat_leave
                else
                  outcome :outcome_mat_leave
                end
              elsif calculator.mother_still_working_on_continuity_end_date == "no"
                if calculator.mother_earnings_employment?
                  outcome :outcome_mat_allowance
                else
                  outcome :outcome_birth_nothing
                end
              end
            elsif mother_is_worker?
              if calculator.mother_continuity? && calculator.mother_earned_more_than_lower_earnings_limit == "yes"
                outcome :outcome_mat_pay
              elsif calculator.mother_earnings_employment?
                outcome :outcome_mat_allowance
              else
                outcome :outcome_birth_nothing
              end
            elsif calculator.mother_earnings_employment?
              outcome :outcome_mat_allowance
            else
              outcome :outcome_birth_nothing
            end
          elsif !calculator.partner_continuity?
            if mother_is_employee?
              if calculator.mother_still_working_on_continuity_end_date == "yes"
                if calculator.mother_continuity?
                  if calculator.mother_earned_more_than_lower_earnings_limit == "yes"
                    outcome :outcome_mat_leave_mat_pay
                  else
                    outcome :outcome_mat_leave
                  end
                elsif calculator.mother_earnings_employment?
                  outcome :outcome_mat_allowance_mat_leave
                else
                  outcome :outcome_mat_leave
                end
              elsif calculator.mother_earnings_employment?
                outcome :outcome_mat_allowance
              else
                outcome :outcome_birth_nothing
              end
            elsif mother_is_worker?
              if calculator.mother_continuity? && calculator.mother_earned_more_than_lower_earnings_limit == "yes"
                outcome :outcome_mat_pay
              elsif calculator.mother_earnings_employment?
                outcome :outcome_mat_allowance
              else
                outcome :outcome_birth_nothing
              end
            elsif mother_self_employed_or_unemployed?
              if calculator.mother_earnings_employment?
                outcome :outcome_mat_allowance
              else
                outcome :outcome_birth_nothing
              end
            end
          end
        end
      end
    end

    outcome :outcome_birth_nothing
    outcome :outcome_single_birth_nothing
    outcome :outcome_mat_allowance
    outcome :outcome_mat_allowance_14_weeks
    outcome :outcome_mat_allowance_mat_leave
    outcome :outcome_mat_allowance_mat_leave_pat_leave
    outcome :outcome_mat_allowance_mat_leave_pat_leave_pat_pay
    outcome :outcome_mat_allowance_mat_leave_pat_pay
    outcome :outcome_mat_allowance_pat_leave
    outcome :outcome_mat_allowance_pat_leave_pat_pay
    outcome :outcome_mat_allowance_pat_pay
    outcome :outcome_mat_leave
    outcome :outcome_mat_leave_mat_pay
    outcome :outcome_mat_leave_mat_pay_pat_leave
    outcome :outcome_mat_leave_mat_pay_pat_leave_pat_pay
    outcome :outcome_mat_leave_mat_pay_pat_pay
    outcome :outcome_mat_leave_pat_leave
    outcome :outcome_mat_leave_pat_leave_pat_pay
    outcome :outcome_mat_leave_pat_pay
    outcome :outcome_mat_pay
    outcome :outcome_mat_pay_pat_leave
    outcome :outcome_mat_pay_pat_leave_pat_pay
    outcome :outcome_mat_pay_pat_pay
    outcome :outcome_pat_leave
    outcome :outcome_pat_leave_pat_pay
    outcome :outcome_pat_pay
  end
end
