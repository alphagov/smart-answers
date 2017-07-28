module SmartAnswer
  class MaternityPaternityCalculatorFlow < Flow
    class AdoptionCalculatorFlow < Flow
      def define
        ## QA0
        multiple_choice :taking_paternity_or_maternity_leave_for_adoption? do
          option :paternity
          option :maternity

          next_node do |response|
            case response
            when 'paternity'
              question :employee_date_matched_paternity_adoption? #QAP1
            when 'maternity'
              question :date_of_adoption_match? # QA1
            end
          end
        end

        ## QA1
        date_question :date_of_adoption_match? do
          calculate :match_date do |response|
            response
          end
          calculate :calculator do
            Calculators::MaternityPaternityCalculator.new(match_date, "adoption")
          end

          next_node do
            question :date_of_adoption_placement?
          end
        end

        ## QA2
        date_question :date_of_adoption_placement? do
          calculate :adoption_placement_date do |response|
            placement_date = response
            raise SmartAnswer::InvalidResponse if placement_date < match_date
            calculator.adoption_placement_date = placement_date
            placement_date
          end

          calculate :a_leave_earliest_start do
            adoption_placement_date - 14
          end

          calculate :a_leave_earliest_start_formatted do
            calculator.format_date a_leave_earliest_start
          end

          calculate :employment_start do
            calculator.a_employment_start
          end

          calculate :qualifying_week_start do
            calculator.adoption_qualifying_start
          end

          next_node do
            question :adoption_did_the_employee_work_for_you?
          end
        end

        ## QA3
        multiple_choice :adoption_did_the_employee_work_for_you? do
          option :yes
          option :no

          next_node do |response|
            case response
            when 'yes'
              question :adoption_employment_contract?
            when 'no'
              outcome :adoption_not_entitled_to_leave_or_pay
            end
          end
        end

        ## QA4
        multiple_choice :adoption_employment_contract? do
          option :yes
          option :no

          on_response do |response|
            calculator.employee_has_contract_adoption = response
          end

          next_node do
            question :adoption_is_the_employee_on_your_payroll?
          end
        end

        ## QA5
        multiple_choice :adoption_is_the_employee_on_your_payroll? do
          option :yes
          option :no

          on_response do |response|
            calculator.on_payroll = response
          end

          calculate :to_saturday do
            calculator.matched_week.last
          end

          calculate :to_saturday_formatted do
            calculator.format_date_day to_saturday
          end

          next_node do
            if calculator.no_contract_not_on_payroll?
              outcome :adoption_not_entitled_to_leave_or_pay
            else
              question :adoption_date_leave_starts?
            end
          end
        end

        ## QA6
        date_question :adoption_date_leave_starts? do
          calculate :adoption_date_leave_starts do |response|
            ald_start = response
            raise SmartAnswer::InvalidResponse if ald_start < a_leave_earliest_start
            calculator.leave_start_date = ald_start
          end

          calculate :leave_start_date do
            calculator.leave_start_date
          end

          calculate :leave_end_date do
            calculator.leave_end_date
          end

          calculate :pay_start_date do
            calculator.pay_start_date
          end

          calculate :pay_end_date do
            calculator.pay_end_date
          end

          calculate :a_notice_leave do
            calculator.format_date calculator.a_notice_leave
          end

          next_node do
            if calculator.has_contract_not_on_payroll?
              outcome :adoption_leave_and_pay
            else
              question :last_normal_payday_adoption?
            end
          end
        end

        # QA7
        date_question :last_normal_payday_adoption? do
          from { 2.years.ago(Date.today) }
          to { 2.years.since(Date.today) }

          calculate :last_payday do |response|
            calculator.last_payday = response
            raise SmartAnswer::InvalidResponse if calculator.last_payday > to_saturday
            calculator.last_payday
          end
          next_node do
            question :payday_eight_weeks_adoption?
          end
        end

        # QA8
        date_question :payday_eight_weeks_adoption? do
          from { 2.year.ago(Date.today) }
          to { 2.years.since(Date.today) }

          precalculate :payday_offset do
            calculator.payday_offset
          end

          precalculate :payday_offset_formatted do
            calculator.format_date_day payday_offset
          end

          calculate :last_payday_eight_weeks do |response|
            payday = response + 1.day
            raise SmartAnswer::InvalidResponse if payday > payday_offset
            calculator.pre_offset_payday = payday
            payday
          end

          calculate :relevant_period do
            calculator.formatted_relevant_period
          end

          next_node do
            question :pay_frequency_adoption?
          end
        end

        # QA9
        multiple_choice :pay_frequency_adoption? do
          option :weekly
          option :every_2_weeks
          option :every_4_weeks
          option :monthly

          on_response do |response|
            calculator.pay_pattern = response
          end

          calculate :calculator do |response|
            calculator.pay_method = response
            calculator
          end

          next_node do
            question :earnings_for_pay_period_adoption?
          end
        end

        ## QA10
        money_question :earnings_for_pay_period_adoption? do
          on_response do |response|
            calculator.earnings_for_pay_period = response
          end

          calculate :lower_earning_limit do
            sprintf("%.2f", calculator.lower_earning_limit)
          end

          calculate :average_weekly_earnings do
            sprintf("%.2f", calculator.average_weekly_earnings)
          end

          calculate :above_lower_earning_limit do
            calculator.average_weekly_earnings > calculator.lower_earning_limit
          end

          next_node do
            if calculator.average_weekly_earnings_under_lower_earning_limit?
              outcome :adoption_leave_and_pay
            else
              question :how_do_you_want_the_sap_calculated?
            end
          end
        end

        ## QA11
        multiple_choice :how_do_you_want_the_sap_calculated? do
          option :weekly_starting
          option :usual_paydates

          save_input_as :sap_calculation_method

          next_node do |response|
            if response == 'weekly_starting'
              outcome :adoption_leave_and_pay
            elsif calculator.pay_pattern == 'monthly'
              question :monthly_pay_paternity?
            else
              question :next_pay_day_paternity?
            end
          end
        end

        outcome :adoption_leave_and_pay do
          precalculate :pay_method do
            calculator.pay_method = (
              if monthly_pay_method
                if monthly_pay_method == 'specific_date_each_month' && pay_day_in_month > 28
                  'last_day_of_the_month'
                else
                  monthly_pay_method
                end
              elsif sap_calculation_method == 'weekly_starting'
                sap_calculation_method
              else
                calculator.pay_pattern
              end
            )
          end

          precalculate :pay_dates_and_pay do
            if above_lower_earning_limit
              lines = calculator.paydates_and_pay.map do |date_and_pay|
                %(#{date_and_pay[:date].strftime('%e %B %Y')}|£#{sprintf('%.2f', date_and_pay[:pay])})
              end
              lines.join("\n")
            end
          end

          precalculate :total_sap do
            if above_lower_earning_limit
              sprintf("%.2f", calculator.total_statutory_pay)
            end
          end
        end

        outcome :adoption_not_entitled_to_leave_or_pay
      end
    end
  end
end
