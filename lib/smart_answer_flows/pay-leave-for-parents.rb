module SmartAnswer
  class PayLeaveForParentsFlow < Flow
    def define
      name "pay-leave-for-parents"
      status :published
      satisfies_need "101018"

      multiple_choice :two_carers do
        option "yes"
        option "no"

        save_input_as :two_carers

        next_node_calculation :calculator do
          Calculators::PayLeaveForParentsCalculator.new
        end

        next_node :due_date
      end

      date_question :due_date do
        save_input_as :due_date

        next_node :employment_status_of_mother
      end

      multiple_choice :employment_status_of_mother do
        option "employee"
        option "worker"
        option "self-employed"
        option "unemployed"

        save_input_as :employment_status_of_mother

        next_node do |response|
          if two_carers == 'no'
            case response
            when 'employee', 'worker'
              :mother_started_working_before_continuity_start_date
            when 'self-employed', 'unemployed'
              :mother_worked_at_least_26_weeks
            end
          elsif two_carers == 'yes'
            :employment_status_of_partner
          end
        end
      end

      multiple_choice :employment_status_of_partner do
        option "employee"
        option "worker"
        option "self-employed"
        option "unemployed"

        save_input_as :employment_status_of_partner

        next_node do |response|
          case employment_status_of_mother
          when 'employee', 'worker'
            :mother_started_working_before_continuity_start_date
          when 'self-employed', 'unemployed'
            :mother_worked_at_least_26_weeks
          end
        end
      end

      multiple_choice :mother_started_working_before_continuity_start_date do
        option "yes"
        option "no"

        save_input_as :mother_started_working_before_continuity_start_date

        precalculate :continuity_start_date do
          calculator.continuity_start_date(due_date)
        end

        next_node :mother_still_working_on_continuity_end_date
      end

      multiple_choice :mother_still_working_on_continuity_end_date do
        option "yes"
        option "no"

        save_input_as :mother_still_working_on_continuity_end_date

        precalculate :continuity_end_date do
          calculator.continuity_end_date(due_date)
        end

        next_node :mother_salary
      end

      salary_question :mother_salary do

        next_node :mother_earned_more_than_lower_earnings_limit
      end

      multiple_choice :mother_earned_more_than_lower_earnings_limit do
        option "yes"
        option "no"

        save_input_as :mother_earned_more_than_lower_earnings_limit

        precalculate :lower_earnings_amount do
          calculator.lower_earnings_amount(due_date)
        end

        precalculate :lower_earnings_start_date do
          calculator.lower_earnings_start_date(due_date)
        end

        precalculate :lower_earnings_end_date do
          calculator.lower_earnings_end_date(due_date)
        end

        next_node do |response|
          if calculator.continuity(mother_started_working_before_continuity_start_date, mother_still_working_on_continuity_end_date) && calculator.lower_earnings(response)
            if two_carers == 'no'
              if employment_status_of_mother == 'employee'
                :outcome_mat_leave_mat_pay
              elsif employment_status_of_mother == 'worker'
                :outcome_mat_pay
              end
            elsif two_carers == 'yes'
              case employment_status_of_partner
              when 'employee', 'worker'
                :partner_started_working_before_continuity_start_date
              when 'self-employed', 'unemployed'
                if due_date >= Date.parse('2015-04-05')
                  :partner_worked_at_least_26_weeks
                elsif due_date < Date.parse('2015-04-05')
                  if employment_status_of_mother == 'employee'
                    :outcome_mat_leave_mat_pay
                  elsif employment_status_of_mother == 'worker'
                    :outcome_mat_pay
                  end
                end
              end
            end
          else
            :mother_worked_at_least_26_weeks
          end
        end
      end

      multiple_choice :mother_worked_at_least_26_weeks do
        option "yes"
        option "no"

        save_input_as :mother_worked_at_least_26_weeks

        precalculate :earnings_employment_start_date do
          calculator.earnings_employment_start_date(due_date)
        end

        precalculate :earnings_employment_end_date do
          calculator.earnings_employment_end_date(due_date)
        end

        next_node :mother_earned_at_least_390
      end

      multiple_choice :mother_earned_at_least_390 do
        option "yes"
        option "no"

        save_input_as :mother_earned_at_least_390

        precalculate :earnings_employment_start_date do
          calculator.earnings_employment_start_date(due_date)
        end

        precalculate :earnings_employment_end_date do
          calculator.earnings_employment_end_date(due_date)
        end

        next_node do |response|
          if two_carers == 'no'
            if calculator.earnings_employment(response, mother_worked_at_least_26_weeks)
              :salary_1_66_weeks
            elsif employment_status_of_mother == 'employee'
              if mother_still_working_on_continuity_end_date == 'yes'
                :outcome_mat_leave
              elsif mother_still_working_on_continuity_end_date == 'no'
                :outcome_single_birth_nothing
              end
            elsif %w(worker self-employed unemployed).include?(employment_status_of_mother)
              :outcome_single_birth_nothing
            end
          elsif two_carers == 'yes'
            if calculator.earnings_employment(response, mother_worked_at_least_26_weeks)
              :salary_1_66_weeks
            elsif %w(employee worker).include?(employment_status_of_partner)
              :partner_started_working_before_continuity_start_date
            elsif %w(self-employed unemployed).include?(employment_status_of_partner)
              if employment_status_of_mother == 'employee'
                if calculator.continuity(mother_started_working_before_continuity_start_date, mother_still_working_on_continuity_end_date) && due_date >= Date.parse('2015-04-05')
                  :partner_worked_at_least_26_weeks
                elsif mother_still_working_on_continuity_end_date == 'yes'
                  :outcome_mat_leave
                elsif mother_still_working_on_continuity_end_date == 'no'
                  :outcome_birth_nothing
                end
              elsif %w(worker self-employed).include?(employment_status_of_mother)
                :outcome_birth_nothing
              elsif employment_status_of_mother == 'unemployed'
                if employment_status_of_partner == 'self-employed'
                  :outcome_mat_allowance_14_weeks
                elsif employment_status_of_partner == 'unemployed'
                  :outcome_birth_nothing
                end
              end
            end
          end
        end
      end

      salary_question :salary_1_66_weeks do
        save_input_as :salary_1_66_weeks

        precalculate :earnings_employment_start_date do
          calculator.earnings_employment_start_date(due_date)
        end

        precalculate :earnings_employment_end_date do
          calculator.earnings_employment_end_date(due_date)
        end

        next_node do |response|
          # * two_carers is 'no'
          #   * employment_status_of_mother is 'employee'
          #     * mother_still_working_on_continuity_end_date is 'yes' => outcome_mat-allowance_mat-leave
          #     * mother_still_working_on_continuity_end_date is 'no' => outcome_mat-allowance
          #   * employment_status_of_mother in {worker self-employed unemployed} => outcome_mat-allowance
          # * two_carers is 'yes'
          #   * employment_status_of_partner in {employee worker} => partner_started_working_before_continuity_start_date
          #   * employment_status_of_partner in {self-employed unemployed}
          #     * employment_status_of_mother is 'employee'
          #       * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) AND due_date >= '2015-4-5' => partner_worked_at_least_26_weeks
          #       * mother_still_working_on_continuity_end_date is 'yes' => outcome_mat-allowance_mat-leave
          #       * mother_still_working_on_continuity_end_date is 'no' => outcome_mat-allowance
          #     * employment_status_of_mother in {worker self-employed unemployed} => outcome_mat-allowance
        end
      end

      multiple_choice :partner_started_working_before_continuity_start_date do
        option "yes"
        option "no"

        save_input_as :partner_started_working_before_continuity_start_date

        precalculate :continuity_start_date do
          calculator.continuity_start_date(due_date)
        end

        next_node :partner_still_working_on_continuity_end_date
      end

      multiple_choice :partner_still_working_on_continuity_end_date do
        option "yes"
        option "no"

        save_input_as :partner_still_working_on_continuity_end_date

        precalculate :continuity_end_date do
          calculator.continuity_end_date(due_date)
        end

        next_node :partner_salary
      end

      salary_question :partner_salary do
        save_input_as :partner_salary

        next_node :partner_earned_more_than_lower_earnings_limit
      end

      multiple_choice :partner_earned_more_than_lower_earnings_limit do
        option "yes"
        option "no"

        save_input_as :partner_earned_more_than_lower_earnings_limit

        precalculate :lower_earnings_amount do
          calculator.lower_earnings_amount(due_date)
        end

        precalculate :lower_earnings_start_date do
          calculator.lower_earnings_start_date(due_date)
        end

        precalculate :lower_earnings_end_date do
          calculator.lower_earnings_end_date(due_date)
        end

        next_node do |response|
          # * employment_status_of_partner is 'employee'
          #   * continuity(partner_started_working_before_continuity_start_date partner_still_working_on_continuity_end_date) AND lower_earnings(partner_earned_more_than_lower_earnings_limit)
          #     * employment_status_of_mother is 'employee'
          #       * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) AND lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * due_date >= '2015-4-5' => outcome_mat-leave_mat-pay_pat-leave_pat-pay_both-shared-leave_both-shared-pay
          #         * due_date < '2015-4-5' => outcome_mat-leave_mat-pay_pat-leave_pat-pay_additional-pat-leave_additional-pat-pay
          #       * mother_started_working_before_continuity_start_date is 'yes' AND mother_still_working_on_continuity_end_date is 'yes'
          #         * due_date >= '2015-4-5'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave_pat-leave_pat-pay_both-shared-leave_pat-shared-pay
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave_pat-leave_pat-pay_mat-shared-leave
          #         * due_date < '2015-4-5'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave_pat-leave_pat-pay_additional-pat-leave_additional-pat-pay
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave_pat-leave_pat-pay_additional-pat-leave
          #       * mother_still_working_on_continuity_end_date is 'yes'
          #         * due_date >= '2015-4-5'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave_pat-leave_pat-pay_pat-shared-leave_pat-shared-pay
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave_pat-leave_pat-pay
          #         * due_date < '2015-4-5'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave_pat-leave_pat-pay_additional-pat-leave_additional-pat-pay
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave_pat-leave_pat-pay_additional-pat-leave
          #       * mother_still_working_on_continuity_end_date is 'no'
          #         * due_date >= '2015-4-5'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_pat-leave_pat-pay_pat-shared-leave_pat-shared-pay
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_pat-leave_pat-pay
          #         * due_date < '2015-4-5'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_pat-leave_pat-pay_additional-pat-leave_additional-pat-pay
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_pat-leave_pat-pay
          #     * employment_status_of_mother is 'worker'
          #       * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) AND lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * due_date >= '2015-4-5' => outcome_mat-pay_pat-leave_pat-pay_pat-shared-leave_both-shared-pay
          #         * due_date < '2015-4-5' => outcome_mat-pay_pat-leave_pat-pay_additional-pat-leave_additional-pat-pay
          #       * NOT continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) OR NOT lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * due_date >= '2015-4-5'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_pat-leave_pat-pay_pat-shared-leave_pat-shared-pay
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_pat-leave_pat-pay
          #         * due_date < '2015-4-5'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_pat-leave_pat-pay_additional-pat-leave_additional-pat-pay
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_pat-leave_pat-pay
          #     * employment_status_of_mother in {unemployed self-employed}
          #       * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_pat-leave_pat-pay
          #       * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks)
          #         * due_date >= '2015-4-5' => outcome_mat-allowance_pat-leave_pat-pay_pat-shared-leave_pat-shared-pay
          #         * due_date < '2015-4-5' => outcome_mat-allowance_pat-leave_pat-pay_additional-pat-leave_additional-pat-pay
          #   * continuity(partner_started_working_before_continuity_start_date partner_still_working_on_continuity_end_date)
          #     * employment_status_of_mother is 'employee'
          #       * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) AND lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * due_date >= '2015-4-5' => partner_worked_at_least_26_weeks
          #         * due_date < '2015-4-5' => outcome_mat-leave_mat-pay_pat-leave_additional-pat-leave
          #       * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date)
          #         * due_date >= '2015-4-5' => partner_worked_at_least_26_weeks
          #         * due_date < '2015-4-5'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave_pat-leave_additional-pat-leave
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave_pat-leave_additional-pat-leave
          #       * mother_still_working_on_continuity_end_date is 'yes'
          #         * due_date >= '2015-4-5'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave_pat-leave_pat-shared-leave
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave_pat-leave
          #         * due_date < '2015-4-5'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave_pat-leave_additional-pat-leave
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave_pat-leave_additional-pat-leave
          #       * mother_still_working_on_continuity_end_date is 'no'
          #         * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks)
          #           * due_date >= '2015-4-5' => outcome_mat-allowance_pat-leave_pat-shared-leave
          #           * due_date < '2015-4-5' => outcome_mat-allowance_pat-leave_additional-pat-leave
          #         * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_pat-leave
          #     * employment_status_of_mother is 'worker'
          #       * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) AND lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * due_date >= '2015-4-5' => partner_worked_at_least_26_weeks
          #         * due_date < '2015-4-5' => outcome_mat-pay_pat-leave_additional-pat-leave
          #       * NOT continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) OR NOT lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks)
          #           * due_date >= '2015-4-5' => outcome_mat-allowance_pat-leave_pat-shared-leave
          #           * due_date < '2015-4-5' => outcome_mat-allowance_pat-leave_additional-pat-leave
          #         * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_pat-leave
          #     * employment_status_of_mother in {unemployed self-employed}
          #       * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks)
          #         * due_date >= '2015-4-5' => outcome_mat-allowance_pat-leave_pat-shared-leave
          #         * due_date < '2015-4-5' => outcome_mat-allowance_pat-leave_additional-pat-leave
          #       * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_pat-leave
          #   * NOT continuity(partner_started_working_before_continuity_start_date partner_still_working_on_continuity_end_date)
          #     * employment_status_of_mother is 'employee'
          #       * mother_still_working_on_continuity_end_date is 'yes'
          #         * due_date >= '2015-4-5'
          #           * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) => partner_worked_at_least_26_weeks
          #           * otherwise
          #             * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave
          #             * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave
          #         * due_date < '2015-4-5'
          #           * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) AND lower_earnings(mother_earned_more_than_lower_earnings_limit) => outcome_mat-leave_mat-pay
          #           * NOT continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) OR NOT lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #             * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave
          #             * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave
          #       * mother_still_working_on_continuity_end_date is 'no'
          #         * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance
          #         * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_birth-nothing
          #     * employment_status_of_mother is 'worker'
          #       * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) AND lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * due_date >= '2015-4-5' => partner_worked_at_least_26_weeks
          #         * due_date < '2015-4-5' => outcome_mat-pay
          #       * NOT continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) OR NOT lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance
          #         * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_birth-nothing
          #     * employment_status_of_mother in {unemployed self-employed}
          #       * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance
          #       * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_birth-nothing
          # * employment_status_of_partner is 'worker'
          #   * continuity(partner_started_working_before_continuity_start_date partner_still_working_on_continuity_end_date) AND lower_earnings(partner_earned_more_than_lower_earnings_limit)
          #     * employment_status_of_mother is 'employee'
          #       * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) AND lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * due_date >= '2015-4-5' => outcome_mat-leave_mat-pay_pat-pay_mat-shared-leave_both-shared-pay
          #         * due_date < '2015-4-5' => outcome_mat-leave_mat-pay_pat-pay_additional-pat-pay
          #       * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date)
          #         * due_date >= '2015-4-5'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave_pat-pay_mat-shared-leave_pat-shared-pay
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave_pat-pay_mat-shared-leave
          #         * due_date < '2015-4-5'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave_pat-pay_additional-pat-pay
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave_pat-pay
          #       * mother_still_working_on_continuity_end_date is 'yes'
          #         * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave_pat-pay
          #         * due_date >= '2015-4-5' => outcome_mat-allowance_mat-leave_pat-pay_pat-shared-pay
          #         * due_date < '2015-4-5' => outcome_mat-allowance_mat-leave_pat-pay_additional-pat-pay
          #       * mother_still_working_on_continuity_end_date is 'no'
          #         * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_pat-pay
          #         * due_date >= '2015-4-5' => outcome_mat-allowance_pat-pay_pat-shared-pay
          #         * due_date < '2015-4-5' => outcome_mat-allowance_pat-pay_additional-pat-pay
          #     * employment_status_of_mother is 'worker'
          #       * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) AND lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * due_date >= '2015-4-5' => outcome_mat-pay_pat-pay_both-shared-pay
          #         * due_date < '2015-4-5' => outcome_mat-pay_pat-pay_additional-pat-pay
          #       * NOT continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) OR NOT lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * due_date >= '2015-4-5'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_pat-pay_pat-shared-pay
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_pat-pay
          #         * due_date < '2015-4-5'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_pat-pay_additional-pat-pay
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_pat-pay
          #     * employment_status_of_mother in {unemployed self-employed}
          #       * due_date >= '2015-4-5'
          #         * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_pat-pay_pat-shared-pay
          #         * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_pat-pay
          #       * due_date < '2015-4-5'
          #         * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_pat-pay_additional-pat-pay
          #         * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_pat-pay
          #   * continuity(partner_started_working_before_continuity_start_date partner_still_working_on_continuity_end_date)
          #     * employment_status_of_mother is 'employee'
          #       * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) AND lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * due_date >= '2015-4-5' => partner_worked_at_least_26_weeks
          #         * due_date < '2015-4-5' => outcome_mat-leave_mat-pay
          #       * NOT continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) OR NOT lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date)
          #           * due_date >= '2015-4-5' => partner_worked_at_least_26_weeks
          #           * due_date < '2015-4-5' AND earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave
          #           * due_date < '2015-4-5' AND NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave
          #         * mother_still_working_on_continuity_end_date is 'yes'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave
          #         * mother_still_working_on_continuity_end_date is 'no'
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_birth-nothing
          #     * employment_status_of_mother is 'worker'
          #       * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) AND lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * due_date >= '2015-4-5' => partner_worked_at_least_26_weeks
          #         * due_date < '2015-4-5' => outcome_mat-pay_pat-pay_additional-pat-pay
          #       * NOT continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) OR NOT lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance
          #         * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_birth-nothing
          #     * employment_status_of_mother in {unemployed self-employed}
          #       * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance
          #       * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_birth-nothing
          #   * NOT continuity(partner_started_working_before_continuity_start_date partner_still_working_on_continuity_end_date)
          #     * employment_status_of_mother is 'employee'
          #       * mother_still_working_on_continuity_end_date is 'yes'
          #         * due_date >= '2015-4-5'
          #           * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) => partner_worked_at_least_26_weeks
          #           * NOT continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date)
          #             * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave
          #             * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave
          #         * due_date < '2015-4-5'
          #           * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) AND lower_earnings(mother_earned_more_than_lower_earnings_limit) => outcome_mat-leave_mat-pay
          #           * NOT continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) OR NOT lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #             * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave
          #             * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave
          #       * mother_still_working_on_continuity_end_date is 'no'
          #         * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance
          #         * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_birth-nothing
          #     * employment_status_of_mother is 'worker'
          #       * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) AND lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * due_date >= '2015-4-5' => partner_worked_at_least_26_weeks
          #         * due_date < '2015-4-5' => outcome_mat-pay
          #       * NOT continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) OR NOT lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #         * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance
          #         * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_birth-nothing
          #     * employment_status_of_mother in {unemployed self-employed}
          #       * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance
          #       * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_birth-nothing
        end
      end

      multiple_choice :partner_worked_at_least_26_weeks do
        option "yes"
        option "no"

        save_input_as :partner_worked_at_least_26_weeks

        precalculate :earnings_employment_start_date do
          calculator.earnings_employment_start_date(due_date)
        end

        precalculate :earnings_employment_end_date do
          calculator.earnings_employment_end_date(due_date)
        end

        next_node :partner_earned_at_least_390
      end

      multiple_choice :partner_earned_at_least_390 do
        option "yes"
        option "no"

        save_input_as :partner_earned_at_least_390

        precalculate :earnings_employment_start_date do
          calculator.earnings_employment_start_date(due_date)
        end

        precalculate :earnings_employment_end_date do
          calculator.earnings_employment_end_date(due_date)
        end

        next_node do |response|
          # * employment_status_of_mother is 'employee'
          #   * continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) AND lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #     * employment_status_of_partner is 'employee'
          #       * continuity(partner_started_working_before_continuity_start_date partner_still_working_on_continuity_end_date)
          #         * earnings_employment(partner_earned_at_least_390 partner_worked_at_least_26_weeks) => outcome_mat-leave_mat-pay_pat-leave_both-shared-leave_mat-shared-pay
          #         * NOT earnings_employment(partner_earned_at_least_390 partner_worked_at_least_26_weeks) => outcome_mat-leave_mat-pay_pat-leave_pat-shared-leave
          #       * NOT continuity(partner_started_working_before_continuity_start_date partner_still_working_on_continuity_end_date)
          #         * earnings_employment(partner_earned_at_least_390 partner_worked_at_least_26_weeks) => outcome_mat-leave_mat-pay_mat-shared-leave_mat-shared-pay
          #         * NOT earnings_employment(partner_earned_at_least_390 partner_worked_at_least_26_weeks) => outcome_mat-leave_mat-pay
          #     * employment_status_of_partner in {worker self-employed unemployed}
          #       * earnings_employment(partner_earned_at_least_390 partner_worked_at_least_26_weeks) => outcome_mat-leave_mat-pay_mat-shared-leave_mat-shared-pay
          #       * NOT earnings_employment(partner_earned_at_least_390 partner_worked_at_least_26_weeks) => outcome_mat-leave_mat-pay
          #   * NOT continuity(mother_started_working_before_continuity_start_date mother_still_working_on_continuity_end_date) OR NOT lower_earnings(mother_earned_more_than_lower_earnings_limit)
          #     * earnings_employment(partner_earned_at_least_390 partner_worked_at_least_26_weeks)
          #       * employment_status_of_partner is 'employee'
          #         * continuity(partner_started_working_before_continuity_start_date partner_still_working_on_continuity_end_date)
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave_pat-leave_both-shared-leave
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave_pat-leave_mat-shared-leave
          #         * NOT continuity(partner_started_working_before_continuity_start_date partner_still_working_on_continuity_end_date)
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave_mat-shared-leave
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave_mat-shared-leave
          #       * employment_status_of_partner in {worker self-employed unemployed}
          #         * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave_mat-shared-leave
          #         * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave_mat-shared-leave
          #     * NOT earnings_employment(partner_earned_at_least_390 partner_worked_at_least_26_weeks)
          #       * employment_status_of_partner is 'employee'
          #         * continuity(partner_started_working_before_continuity_start_date partner_still_working_on_continuity_end_date)
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave_pat-leave_pat-shared-leave
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave_pat-leave
          #         * NOT continuity(partner_started_working_before_continuity_start_date partner_still_working_on_continuity_end_date)
          #           * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave
          #           * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave
          #       * employment_status_of_partner in {worker self-employed unemployed}
          #         * earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-allowance_mat-leave
          #         * NOT earnings_employment(mother_earned_at_least_390 mother_worked_at_least_26_weeks) => outcome_mat-leave
          # * employment_status_of_mother is 'worker'
          #   * employment_status_of_partner is 'employee'
          #     * continuity(partner_started_working_before_continuity_start_date partner_still_working_on_continuity_end_date)
          #       * earnings_employment(partner_earned_at_least_390 partner_worked_at_least_26_weeks) => outcome_mat-pay_pat-leave_pat-shared-leave_mat-shared-pay
          #       * NOT earnings_employment(partner_earned_at_least_390 partner_worked_at_least_26_weeks) => outcome_mat-pay_pat-leave
          #     * NOT continuity(partner_started_working_before_continuity_start_date partner_still_working_on_continuity_end_date)
          #       * earnings_employment(partner_earned_at_least_390 partner_worked_at_least_26_weeks) => outcome_mat-pay_mat-shared-pay
          #       * NOT earnings_employment(partner_earned_at_least_390 partner_worked_at_least_26_weeks) => outcome_mat-pay
          #   * employment_status_of_partner in {worker self-employed unemployed}
          #     * earnings_employment(partner_earned_at_least_390 partner_worked_at_least_26_weeks) => outcome_mat-pay_mat-shared-pay
          #     * NOT earnings_employment(partner_earned_at_least_390 partner_worked_at_least_26_weeks) => outcome_mat-pay
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
