module SmartAnswer
  class MaternityPaternityCalculatorFlow < Flow
    class AdoptionCalculatorFlow < Flow
      def define
        radio :taking_paternity_or_maternity_leave_for_adoption? do
          option :paternity
          option :maternity

          next_node do |response|
            case response
            when "paternity"
              question :employee_date_matched_paternity_adoption?
            when "maternity"
              question :adoption_is_from_overseas?
            end
          end
        end

        radio :adoption_is_from_overseas? do
          option :yes
          option :no

          on_response do |response|
            self.adoption_is_from_overseas = (response == "yes")
          end

          next_node do
            question :date_of_adoption_match?
          end
        end

        date_question :date_of_adoption_match? do
          on_response do |response|
            self.match_date = response
            self.calculator = Calculators::AdoptionPayCalculator.new(match_date)
          end

          next_node do
            question :date_of_adoption_placement?
          end
        end

        date_question :date_of_adoption_placement? do
          on_response do |response|
            self.adoption_placement_date = response
            calculator.adoption_placement_date = adoption_placement_date

            self.a_leave_earliest_start = calculator.leave_earliest_start_date(adoption_is_from_overseas)
            self.a_leave_earliest_start_formatted = calculator.format_date(a_leave_earliest_start)

            self.a_leave_latest_start = calculator.leave_latest_start_date(adoption_is_from_overseas)
            self.a_leave_latest_start_formatted = calculator.format_date(a_leave_latest_start)

            self.employment_start = calculator.a_employment_start
            self.qualifying_week_start = calculator.adoption_qualifying_start
          end

          validate :error_message do
            adoption_placement_date >= match_date
          end

          next_node do
            if adoption_is_from_overseas
              question :adoption_date_leave_starts?
            else
              question :adoption_did_the_employee_work_for_you?
            end
          end
        end

        radio :adoption_did_the_employee_work_for_you? do
          option :yes
          option :no

          next_node do |response|
            case response
            when "yes"
              if adoption_is_from_overseas
                question :adoption_is_the_employee_on_your_payroll?
              else
                question :adoption_employment_contract?
              end
            when "no"
              outcome :adoption_not_entitled_to_leave_or_pay
            end
          end
        end

        radio :adoption_employment_contract? do
          option :yes
          option :no

          on_response do |response|
            calculator.employee_has_contract_adoption = response
          end

          next_node do
            if adoption_is_from_overseas
              question :adoption_did_the_employee_work_for_you?
            else
              question :adoption_is_the_employee_on_your_payroll?
            end
          end
        end

        radio :adoption_is_the_employee_on_your_payroll? do
          option :yes
          option :no

          on_response do |response|
            calculator.on_payroll = response
            self.to_saturday = calculator.matched_week.last
            self.to_saturday_formatted = calculator.format_date_day(to_saturday)
          end

          next_node do
            if calculator.no_contract_not_on_payroll?
              outcome :adoption_not_entitled_to_leave_or_pay
            elsif adoption_is_from_overseas
              question :last_normal_payday_adoption?
            else
              question :adoption_date_leave_starts?
            end
          end
        end

        date_question :adoption_date_leave_starts? do
          on_response do |response|
            self.leave_start_date = response
            calculator.leave_start_date = leave_start_date
            self.leave_end_date = calculator.leave_end_date
            self.pay_start_date = calculator.pay_start_date
            self.pay_end_date = calculator.pay_end_date
            self.a_notice_leave = calculator.a_notice_leave.to_s(:govuk_date) if calculator.a_notice_leave
            self.overseas_adoption_leave_employment_threshold = calculator.overseas_adoption_leave_employment_threshold
          end

          validate :error_leave_starts_too_early do
            leave_start_date >= a_leave_earliest_start
          end

          validate :error_leave_starts_too_late do
            leave_start_date <= a_leave_latest_start
          end

          next_node do
            if adoption_is_from_overseas
              question :adoption_employment_contract?
            elsif calculator.has_contract_not_on_payroll?
              outcome :adoption_leave_and_pay
            else
              question :last_normal_payday_adoption?
            end
          end
        end

        date_question :last_normal_payday_adoption? do
          from { 2.years.ago(Time.zone.today) }
          to { 2.years.since(Time.zone.today) }

          on_response do |response|
            self.last_payday = response
            calculator.last_payday = last_payday
            self.payday_offset = calculator.payday_offset
            self.payday_offset_formatted = calculator.format_date(payday_offset)
          end

          validate :error_message do
            last_payday <= to_saturday
          end

          next_node do
            question :payday_eight_weeks_adoption?
          end
        end

        date_question :payday_eight_weeks_adoption? do
          from { 2.years.ago(Time.zone.today) }
          to { 2.years.since(Time.zone.today) }

          on_response do |response|
            self.last_payday_eight_weeks = response + 1.day
            calculator.pre_offset_payday = last_payday_eight_weeks
            self.relevant_period = calculator.formatted_relevant_period
          end

          validate :error_message do
            calculator.payday_offset >= last_payday_eight_weeks
          end

          next_node do
            question :pay_frequency_adoption?
          end
        end

        radio :pay_frequency_adoption? do
          option :weekly
          option :every_2_weeks
          option :every_4_weeks
          option :monthly

          on_response do |response|
            self.pay_pattern = response
            calculator.pay_pattern = pay_pattern
          end

          next_node do
            question :earnings_for_pay_period_adoption?
          end
        end

        money_question :earnings_for_pay_period_adoption? do
          on_response do |response|
            calculator.earnings_for_pay_period = response
            self.lower_earning_limit = sprintf("%.2f", calculator.lower_earning_limit)
          end

          next_node do
            if calculator.average_weekly_earnings_under_lower_earning_limit?
              outcome :adoption_leave_and_pay
            elsif calculator.weekly?
              question :how_many_payments_weekly? # See SharedAdoptionMaternityPaternityFlow for definition
            elsif calculator.every_2_weeks?
              question :how_many_payments_every_2_weeks? # See SharedAdoptionMaternityPaternityFlow for definition
            elsif calculator.every_4_weeks?
              question :how_many_payments_every_4_weeks? # See SharedAdoptionMaternityPaternityFlow for definition
            elsif calculator.monthly?
              question :how_many_payments_monthly? # See SharedAdoptionMaternityPaternityFlow for definition
            else
              question :how_do_you_want_the_sap_calculated?
            end
          end
        end

        radio :how_do_you_want_the_sap_calculated? do
          option :weekly_starting
          option :usual_paydates

          on_response do |response|
            self.sap_calculation_method = response
          end

          next_node do
            if sap_calculation_method == "weekly_starting"
              outcome :adoption_leave_and_pay
            elsif calculator.pay_pattern == "monthly"
              question :monthly_pay_paternity?
            else
              question :next_pay_day_paternity?
            end
          end
        end

        outcome :adoption_leave_and_pay do
          precalculate :above_lower_earning_limit do
            calculator.average_weekly_earnings > calculator.lower_earning_limit
          end

          precalculate :pay_method do
            calculator.pay_method = (
              if monthly_pay_method
                if monthly_pay_method == "specific_date_each_month" && pay_day_in_month > 28
                  "last_day_of_the_month"
                else
                  monthly_pay_method
                end
              elsif sap_calculation_method == "weekly_starting"
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

          precalculate :average_weekly_earnings do
            sprintf("%.2f", calculator.average_weekly_earnings)
          end
        end

        outcome :adoption_not_entitled_to_leave_or_pay
      end
    end
  end
end
