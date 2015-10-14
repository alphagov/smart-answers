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
        option :ordinary_statutory_paternity_pay
        option :statutory_adoption_pay
        option :additional_statutory_paternity_pay

        calculate :employee_not_entitled_pdf do
          # this avoids lots of content duplication in the YML
          PhraseList.new(:ssp_link)
        end
        calculate :paternity_maternity_warning do |response|
          (response.split(",") & %w{ordinary_statutory_paternity_pay additional_statutory_paternity_pay statutory_adoption_pay}).any?
        end
        next_node_if(:employee_tell_within_limit?,
          response_is_one_of(%w{ordinary_statutory_paternity_pay additional_statutory_paternity_pay statutory_adoption_pay none}))
        next_node(:already_getting_maternity)
      end

      # Question 2
      multiple_choice :employee_tell_within_limit? do
        option :yes
        option :no

        calculate :enough_notice_of_absence do |response|
          response == 'yes'
        end

        next_node(:employee_work_different_days?)
      end

      # Question 3
      multiple_choice :employee_work_different_days? do
        option yes: :not_regular_schedule # Answer 4
        option no: :first_sick_day? # Question 4
      end

      # Question 4
      date_question :first_sick_day? do
        from { Date.new(2011, 1, 1) }
        to { Date.today.end_of_year }
        validate_in_range

        calculate :sick_start_date do |response|
          response
        end

        calculate :sick_start_date_for_awe do |response|
          response
        end

        next_node :last_sick_day?

      end

      # Question 5
      date_question :last_sick_day? do
        from { Date.new(2011, 1, 1) }
        to { Date.today.end_of_year }
        validate_in_range

        calculate :sick_end_date do |response|
          response
        end

        calculate :sick_end_date_for_awe do |response|
          response
        end

        next_node_calculation(:days_sick) do |response|
          start_date = sick_start_date
          last_day_sick = response
          (last_day_sick - start_date).to_i + 1
        end

        validate { days_sick >= 1 }
        next_node_if(:has_linked_sickness?) { days_sick > 3 }
        next_node(:must_be_sick_for_4_days)
      end

      # Question 6
      multiple_choice :has_linked_sickness? do
        option yes: :linked_sickness_start_date?
        option no: :paid_at_least_8_weeks?
      end

      # Question 6.1
      date_question :linked_sickness_start_date? do
        from { Date.new(2010, 1, 1) }
        to { Date.today.end_of_year }
        validate_in_range

        next_node_calculation :sick_start_date_for_awe do |response|
          response
        end

        validate :linked_sickness_must_be_before do
          sick_start_date > sick_start_date_for_awe
        end

        next_node(:linked_sickness_end_date?)
      end

      # Question 6.2
      date_question :linked_sickness_end_date? do
        from { Date.new(2010, 1, 1) }
        to { Date.today.end_of_year }
        validate_in_range

        next_node_calculation :sick_end_date_for_awe do |response|
          response
        end

        validate :must_be_within_eight_weeks do
          furthest_allowed_date = sick_start_date - 8.weeks
          sick_end_date_for_awe > furthest_allowed_date
        end

        next_node_calculation :prior_sick_days do |response|
          start_date = sick_start_date_for_awe
          last_day_sick = response
          (last_day_sick - start_date).to_i + 1
        end

        validate :start_before_end do
          prior_sick_days >= 1
        end

        next_node(:paid_at_least_8_weeks?)
      end

      # Question 7.1
      multiple_choice :paid_at_least_8_weeks? do
        option eight_weeks_more: :how_often_pay_employee_pay_patterns? # Question 7.2
        option eight_weeks_less: :total_earnings_before_sick_period? # Question 10
        option before_payday: :how_often_pay_employee_pay_patterns? # Question 7.2

        save_input_as :eight_weeks_earnings
      end

      # Question 7.2
      multiple_choice :how_often_pay_employee_pay_patterns? do
        option :weekly
        option :fortnightly
        option :every_4_weeks
        option :monthly
        option :irregularly

        save_input_as :pay_pattern

        next_node_if(:last_payday_before_sickness?, variable_matches(:eight_weeks_earnings, 'eight_weeks_more'))  # Question 8
        next_node(:pay_amount_if_not_sick?) # Question 9
      end

      # Question 8
      date_question :last_payday_before_sickness? do
        from { Date.new(2010, 1, 1) }
        to { Date.today.end_of_year }
        validate_in_range

        calculate :relevant_period_to do |response|
          response
        end

        calculate :pay_day_offset do
          relevant_period_to - 8.weeks
        end

        validate do |response|
          payday = response
          start = sick_start_date

          payday < start
        end

        next_node(:last_payday_before_offset?)
      end

      # Question 8.1
      date_question :last_payday_before_offset? do
        from { Date.new(2010, 1, 1) }
        to { Date.today.end_of_year }
        validate_in_range

        # You must enter a date on or before [pay_day_offset]
        validate { |payday| payday <= pay_day_offset }

        # input plus 1 day = relevant_period_from
        calculate :relevant_period_from do |response|
          response + 1.day
        end

        calculate :monthly_pattern_payments do
          start_date = relevant_period_from
          end_date = relevant_period_to
          Calculators::StatutorySickPayCalculator.months_between(start_date, end_date)
        end

        next_node(:total_employee_earnings?)
      end

      # Question 8.2
      money_question :total_employee_earnings? do
        next_node_calculation :employee_average_weekly_earnings do |response|
          Calculators::StatutorySickPayCalculator.average_weekly_earnings(
            pay: response, pay_pattern: pay_pattern, monthly_pattern_payments: monthly_pattern_payments,
            relevant_period_to: relevant_period_to, relevant_period_from: relevant_period_from)
        end

        next_node :usual_work_days?
      end

      # Question 9
      money_question :pay_amount_if_not_sick? do
        save_input_as :relevant_contractual_pay

        next_node :contractual_days_covered_by_earnings?
      end

      # Question 9.1
      value_question :contractual_days_covered_by_earnings? do
        next_node_calculation :employee_average_weekly_earnings do |response|
          pay = relevant_contractual_pay
          days_worked = response
          Calculators::StatutorySickPayCalculator.contractual_earnings_awe(pay, days_worked)
        end
        next_node :usual_work_days?
      end

      # Question 10
      money_question :total_earnings_before_sick_period? do
        save_input_as :earnings

        next_node :days_covered_by_earnings?
      end

      # Question 10.1
      value_question :days_covered_by_earnings? do

        next_node_calculation :employee_average_weekly_earnings do |response|
          pay = earnings
          days_worked = response.to_i
          Calculators::StatutorySickPayCalculator.total_earnings_awe(pay, days_worked)
        end

        next_node :usual_work_days?
      end

      # Question 11
      checkbox_question :usual_work_days? do
        %w{1 2 3 4 5 6 0}.each { |n| option n.to_s }

        next_node_calculation(:usual_work_days) do |response|
          response
        end

        next_node_calculation(:calculator) do |response|
          Calculators::StatutorySickPayCalculator.new(prior_sick_days.to_i, sick_start_date, sick_end_date, response.split(","))
        end

        permitted_next_nodes = OutcomeDecision.possible_outcomes

        next_node(permitted: permitted_next_nodes) do
          OutcomeDecision.new(self).outcome_name
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
          Calculators::StatutorySickPayCalculator.lower_earning_limit_on(sick_start_date)
        end
      end

      # Answer 6
      outcome :entitled_to_sick_pay do
        precalculate :ssp_payment do
          Money.new(calculator.ssp_payment)
        end

        precalculate :days_paid do calculator.days_paid end
        precalculate :normal_workdays_out do calculator.normal_workdays end
        precalculate :pattern_days do calculator.pattern_days end
        precalculate :pattern_days_total do calculator.pattern_days * 28 end

        precalculate :formatted_sick_pay_weekly_amounts do
          if calculator.ssp_payment > 0
            calculator.formatted_sick_pay_weekly_amounts
          else
            ""
          end
        end
      end

      # Answer 7
      outcome :not_entitled_3_days_not_paid do
        precalculate :normal_workdays_out do calculator.normal_workdays end
      end

      # Answer 8
      outcome :maximum_entitlement_reached
    end

  private

    class OutcomeDecision
      delegate :employee_average_weekly_earnings, :prior_sick_days, :usual_work_days, :calculator, :sick_start_date,
               to: :@flow

      def self.possible_outcomes
        [:not_earned_enough, :maximum_entitlement_reached, :entitled_to_sick_pay, :not_entitled_3_days_not_paid]
      end

      def initialize(flow)
        @flow = flow
      end

      def outcome_name
        if employee_average_weekly_earnings < Calculators::StatutorySickPayCalculator.lower_earning_limit_on(sick_start_date)
          :not_earned_enough
        elsif prior_sick_days && prior_sick_days.to_i >= (usual_work_days.split(",").size * 28 + 3)
          :maximum_entitlement_reached
        elsif calculator.ssp_payment > 0
          :entitled_to_sick_pay
        elsif calculator.days_that_can_be_paid_for_this_period == 0
          :maximum_entitlement_reached
        else
          :not_entitled_3_days_not_paid
        end
      end
    end
  end
end
