module SmartAnswer
  class CalculateStatutorySickPayFlow < Flow
    def define
      content_id "1c676a9e-0424-4ebb-bab8-d8cb8d2fc6f8"
      name 'calculate-statutory-sick-pay'

      status :published
      satisfies_need "100262"

      # Question 1
      checkbox_question :is_your_employee_getting? do
        option :statutory_maternity_pay
        option :maternity_allowance
        option :statutory_paternity_pay
        option :statutory_adoption_pay
        option :additional_statutory_paternity_pay

        next_node_calculation :calculator do
          Calculators::StatutorySickPayCalculator.new
        end

        permitted_next_nodes = [:employee_tell_within_limit?, :already_getting_maternity]
        next_node(permitted: permitted_next_nodes) do |response|
          calculator.other_pay_types_received = response.split(",")
          if calculator.already_getting_maternity_pay?
            :already_getting_maternity
          else
            :employee_tell_within_limit?
          end
        end
      end

      # Question 2
      multiple_choice :employee_tell_within_limit? do
        option :yes
        option :no

        next_node(permitted: [:employee_work_different_days?]) do |response|
          if response == 'yes'
            calculator.enough_notice_of_absence = true
          else
            calculator.enough_notice_of_absence = false
          end
          :employee_work_different_days?
        end
      end

      # Question 3
      multiple_choice :employee_work_different_days? do
        option :yes
        option :no

        permitted_next_nodes = [
          :not_regular_schedule,
          :first_sick_day?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :not_regular_schedule # Answer 4
          when 'no'
            :first_sick_day? # Question 4
          end
        end
      end

      # Question 4
      date_question :first_sick_day? do
        from { Date.new(2011, 1, 1) }
        to { Date.today.end_of_year }
        validate_in_range

        next_node(permitted: [:last_sick_day?]) do |response|
          calculator.sick_start_date = response
          :last_sick_day?
        end
      end

      # Question 5
      date_question :last_sick_day? do
        from { Date.new(2011, 1, 1) }
        to { Date.today.end_of_year }
        validate_in_range

        validate do |response|
          calculator.valid_last_sick_day?(response)
        end

        permitted_next_nodes = [:has_linked_sickness?, :must_be_sick_for_4_days]
        next_node(permitted: permitted_next_nodes) do |response|
          calculator.sick_end_date = response
          if calculator.days_sick >= Calculators::StatutorySickPayCalculator::MINIMUM_NUMBER_OF_DAYS_IN_PERIOD_OF_INCAPACITY_TO_WORK
            :has_linked_sickness?
          else
            :must_be_sick_for_4_days
          end
        end
      end

      # Question 6
      multiple_choice :has_linked_sickness? do
        option :yes
        option :no

        save_input_as :has_linked_sickness

        permitted_next_nodes = [
          :linked_sickness_start_date?,
          :paid_at_least_8_weeks?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            calculator.has_linked_sickness = true
            :linked_sickness_start_date?
          when 'no'
            calculator.has_linked_sickness = false
            :paid_at_least_8_weeks?
          end
        end
      end

      # Question 6.1
      date_question :linked_sickness_start_date? do
        from { Date.new(2010, 1, 1) }
        to { Date.today.end_of_year }
        validate_in_range

        validate :linked_sickness_must_be_before do |response|
          calculator.valid_linked_sickness_start_date?(response)
        end

        next_node(permitted: [:linked_sickness_end_date?]) do |response|
          calculator.linked_sickness_start_date = response
          :linked_sickness_end_date?
        end
      end

      # Question 6.2
      date_question :linked_sickness_end_date? do
        from { Date.new(2010, 1, 1) }
        to { Date.today.end_of_year }
        validate_in_range

        validate :must_be_within_eight_weeks do |response|
          calculator.within_eight_weeks_of_current_sickness_period?(response)
        end

        validate :must_be_at_least_1_day_before_first_sick_day do |response|
          calculator.at_least_1_day_before_first_sick_day?(response)
        end

        validate :must_be_valid_period_of_incapacity_for_work do |response|
          calculator.valid_period_of_incapacity_for_work?(response)
        end

        next_node(permitted: [:paid_at_least_8_weeks?]) do |response|
          calculator.linked_sickness_end_date = response
          :paid_at_least_8_weeks?
        end
      end

      # Question 7.1
      multiple_choice :paid_at_least_8_weeks? do
        option :eight_weeks_more
        option :eight_weeks_less
        option :before_payday

        precalculate :sick_start_date_for_awe do
          calculator.sick_start_date_for_awe
        end

        permitted_next_nodes = [
          :how_often_pay_employee_pay_patterns?,
          :total_earnings_before_sick_period?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          calculator.eight_weeks_earnings = response
          if calculator.paid_at_least_8_weeks_of_earnings?
            :how_often_pay_employee_pay_patterns? # Question 7.2
          elsif calculator.paid_less_than_8_weeks_of_earnings?
            :total_earnings_before_sick_period? # Question 10
          elsif calculator.fell_sick_before_payday?
            :how_often_pay_employee_pay_patterns? # Question 7.2
          end
        end
      end

      # Question 7.2
      multiple_choice :how_often_pay_employee_pay_patterns? do
        option :weekly
        option :fortnightly
        option :every_4_weeks
        option :monthly
        option :irregularly

        permitted_next_nodes = [
          :last_payday_before_sickness?,
          :pay_amount_if_not_sick?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          calculator.pay_pattern = response
          if calculator.paid_at_least_8_weeks_of_earnings?
            :last_payday_before_sickness? # Question 8
          else
            :pay_amount_if_not_sick? # Question 9
          end
        end
      end

      # Question 8
      date_question :last_payday_before_sickness? do
        from { Date.new(2010, 1, 1) }
        to { Date.today.end_of_year }
        validate_in_range

        precalculate :sick_start_date_for_awe do
          calculator.sick_start_date_for_awe
        end

        validate do |response|
          calculator.valid_last_payday_before_sickness?(response)
        end

        next_node(permitted: [:last_payday_before_offset?]) do |response|
          calculator.relevant_period_to = response
          :last_payday_before_offset?
        end
      end

      # Question 8.1
      date_question :last_payday_before_offset? do
        from { Date.new(2010, 1, 1) }
        to { Date.today.end_of_year }
        validate_in_range

        precalculate :pay_day_offset do
          calculator.pay_day_offset
        end

        validate do |response|
          calculator.valid_last_payday_before_offset?(response)
        end

        next_node(permitted: [:total_employee_earnings?]) do |response|
          calculator.relevant_period_from = response + 1.day
          :total_employee_earnings?
        end
      end

      # Question 8.2
      money_question :total_employee_earnings? do
        precalculate :relevant_period_from do
          calculator.relevant_period_from
        end

        precalculate :relevant_period_to do
          calculator.relevant_period_to
        end

        next_node(permitted: [:usual_work_days?])  do |response|
          calculator.total_employee_earnings = response
          :usual_work_days?
        end
      end

      # Question 9
      money_question :pay_amount_if_not_sick? do
        precalculate :sick_start_date_for_awe do
          calculator.sick_start_date_for_awe
        end

        next_node(permitted: [:contractual_days_covered_by_earnings?]) do |response|
          calculator.relevant_contractual_pay = response
          :contractual_days_covered_by_earnings?
        end
      end

      # Question 9.1
      value_question :contractual_days_covered_by_earnings? do
        next_node(permitted: [:usual_work_days?]) do |response|
          calculator.contractual_days_covered_by_earnings = response
          :usual_work_days?
        end
      end

      # Question 10
      money_question :total_earnings_before_sick_period? do
        next_node(permitted: [:days_covered_by_earnings?]) do |response|
          calculator.total_earnings_before_sick_period = response
          :days_covered_by_earnings?
        end
      end

      # Question 10.1
      value_question :days_covered_by_earnings? do
        next_node(permitted: [:usual_work_days?]) do |response|
          calculator.days_covered_by_earnings = response.to_i
          :usual_work_days?
        end
      end

      # Question 11
      checkbox_question :usual_work_days? do
        %w{1 2 3 4 5 6 0}.each { |n| option n.to_s }

        permitted_next_nodes = [
          :not_earned_enough,
          :maximum_entitlement_reached,
          :entitled_to_sick_pay,
          :maximum_entitlement_reached,
          :not_entitled_3_days_not_paid
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          calculator.days_of_the_week_worked = response.split(",")
          if calculator.not_earned_enough?
            :not_earned_enough
          elsif calculator.maximum_entitlement_reached?
            :maximum_entitlement_reached # Answer 8
          elsif calculator.entitled_to_sick_pay?
            :entitled_to_sick_pay # Answer 6
          elsif calculator.maximum_entitlement_reached_v2?
            :maximum_entitlement_reached # Answer 8
          else
            :not_entitled_3_days_not_paid # Answer 7
          end
        end
      end

      # Answer 1
      outcome :already_getting_maternity

      # Answer 2
      outcome :must_be_sick_for_4_days

      # Answer 4
      outcome :not_regular_schedule

      # Answer 5
      outcome :not_earned_enough do
        precalculate :lower_earning_limit do
          calculator.lower_earning_limit
        end

        precalculate :employee_average_weekly_earnings do
          calculator.employee_average_weekly_earnings
        end
      end

      # Answer 6
      outcome :entitled_to_sick_pay do
        precalculate :ssp_payment do
          calculator.ssp_payment
        end

        precalculate :days_paid do calculator.days_paid end
        precalculate :normal_workdays_out do calculator.normal_workdays end
        precalculate :pattern_days do calculator.pattern_days end
        precalculate :pattern_days_total do calculator.pattern_days_total end
      end

      # Answer 7
      outcome :not_entitled_3_days_not_paid do
        precalculate :normal_workdays_out do calculator.normal_workdays end
      end

      # Answer 8
      outcome :maximum_entitlement_reached
    end
  end
end
