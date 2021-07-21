class MaternityPaternityCalculatorFlow < SmartAnswer::Flow
  class PaternityCalculatorFlow < SmartAnswer::Flow
    def define
      days_of_the_week = SmartAnswer::Calculators::MaternityPayCalculator::DAYS_OF_THE_WEEK

      ## QP0
      radio :leave_or_pay_for_adoption? do
        option :yes
        option :no

        next_node do |response|
          case response
          when "yes"
            question :employee_date_matched_paternity_adoption?
          when "no"
            question :baby_due_date_paternity?
          end
        end
      end

      ## QP1
      date_question :baby_due_date_paternity? do
        on_response do |response|
          self.due_date = response
          self.calculator = SmartAnswer::Calculators::PaternityPayCalculator.new(due_date)
        end

        next_node do
          question :baby_birth_date_paternity?
        end
      end

      ## QAP1 - Paternity Adoption
      date_question :employee_date_matched_paternity_adoption? do
        on_response do |response|
          self.matched_date = response
          self.calculator = SmartAnswer::Calculators::PaternityAdoptionPayCalculator.new(matched_date)
          self.leave_type = "paternity_adoption"
          self.paternity_adoption = true
        end

        next_node do
          question :padoption_date_of_adoption_placement?
        end
      end

      ## QP2
      date_question :baby_birth_date_paternity? do
        on_response do |response|
          self.date_of_birth = response
          calculator.date_of_birth = date_of_birth
        end

        next_node do
          question :employee_responsible_for_upbringing?
        end
      end

      ## QAP2 - Paternity Adoption
      date_question :padoption_date_of_adoption_placement? do
        on_response do |response|
          self.ap_adoption_date = response
          calculator.adoption_placement_date = ap_adoption_date
          self.ap_adoption_date_formatted = calculator.format_date_day ap_adoption_date
          self.matched_date_formatted = calculator.format_date_day matched_date
        end

        validate :error_message do
          ap_adoption_date >= matched_date
        end

        next_node do
          question :padoption_employee_responsible_for_upbringing?
        end
      end

      ## QP3
      radio :employee_responsible_for_upbringing? do
        option :yes
        option :no

        on_response do |response|
          self.paternity_responsible = response
          self.employment_start = calculator.employment_start
          self.employment_end = due_date
          self.qualifying_week_start = calculator.qualifying_week.first
          self.p_notice_leave = calculator.notice_of_leave_deadline
        end

        next_node do
          case paternity_responsible
          when "yes"
            question :employee_work_before_employment_start?
          when "no"
            outcome :paternity_not_entitled_to_leave_or_pay
          end
        end
      end

      ## QAP3 - Paternity Adoption
      radio :padoption_employee_responsible_for_upbringing? do
        option :yes
        option :no

        on_response do |response|
          self.paternity_responsible = response
          self.employment_start = calculator.a_employment_start
          self.employment_end = matched_date
          self.qualifying_week_start = calculator.adoption_qualifying_start
        end

        next_node do
          case paternity_responsible
          when "yes"
            question :employee_work_before_employment_start? # Combined flow
          when "no"
            outcome :paternity_not_entitled_to_leave_or_pay
          end
        end
      end

      ## QP4 - Shared flow onwards
      radio :employee_work_before_employment_start? do
        option :yes
        option :no

        on_response do |response|
          self.paternity_employment_start = response
        end

        next_node do
          case paternity_employment_start
          when "yes"
            question :employee_has_contract_paternity?
          when "no"
            outcome :paternity_not_entitled_to_leave_or_pay
          end
        end
      end

      ## QP5
      radio :employee_has_contract_paternity? do
        option :yes
        option :no

        on_response do |response|
          self.has_contract = response
        end

        next_node do
          question :employee_on_payroll_paternity?
        end
      end

      ## QP6
      radio :employee_on_payroll_paternity? do
        option :yes
        option :no

        on_response do |response|
          calculator.on_payroll = response

          if paternity_adoption
            self.leave_spp_claim_link = "adoption"
            self.to_saturday = calculator.matched_week.last
            self.still_employed_date = calculator.employment_end
            self.start_leave_hint = ap_adoption_date_formatted
          else
            self.leave_spp_claim_link = "notice-period"
            self.to_saturday = calculator.qualifying_week.last
            self.still_employed_date = date_of_birth
            self.start_leave_hint = date_of_birth
          end

          self.to_saturday_formatted = calculator.format_date_day to_saturday
        end

        next_node do
          if calculator.on_payroll == "yes"
            question :employee_still_employed_on_birth_date?
          elsif has_contract == "no"
            outcome :paternity_not_entitled_to_leave_or_pay
          else
            question :employee_start_paternity?
          end
        end
      end

      ## QP7
      radio :employee_still_employed_on_birth_date? do
        option :yes
        option :no

        on_response do |response|
          self.employed_dob = response
        end

        next_node do
          if has_contract == "no" && employed_dob == "no"
            outcome :paternity_not_entitled_to_leave_or_pay
          else
            question :employee_start_paternity?
          end
        end
      end

      ## QP8
      date_question :employee_start_paternity? do
        from { 2.years.ago(Time.zone.today) }
        to { 2.years.since(Time.zone.today) }

        on_response do |response|
          self.employee_leave_start = response
          self.leave_start_date = employee_leave_start
          calculator.leave_start_date = employee_leave_start
          self.notice_of_leave_deadline = calculator.notice_of_leave_deadline
        end

        validate :error_message do
          calculator.leave_start_date >= if paternity_adoption
                                           ap_adoption_date
                                         else
                                           date_of_birth
                                         end
        end

        next_node do
          question :employee_paternity_length?
        end
      end

      ## QP9
      radio :employee_paternity_length? do
        option :one_week
        option :two_weeks

        on_response do |response|
          self.leave_amount = response
          calculator.paternity_leave_duration = leave_amount
          self.leave_end_date = calculator.pay_end_date
        end

        next_node do
          if has_contract == "yes" && (calculator.on_payroll == "no" || employed_dob == "no")
            outcome :paternity_not_entitled_to_leave_or_pay
          else
            question :last_normal_payday_paternity?
          end
        end
      end

      ## QP10
      date_question :last_normal_payday_paternity? do
        from { 2.years.ago(Time.zone.today) }
        to { 2.years.since(Time.zone.today) }

        on_response do |response|
          calculator.last_payday = response
        end

        validate :error_message do
          calculator.last_payday <= to_saturday
        end

        next_node do
          question :payday_eight_weeks_paternity?
        end
      end

      ## QP11
      date_question :payday_eight_weeks_paternity? do
        from { 2.years.ago(Time.zone.today) }
        to { 2.years.since(Time.zone.today) }

        on_response do |response|
          calculator.pre_offset_payday = response + 1.day
          self.relevant_period = calculator.formatted_relevant_period
          self.payday_offset = calculator.payday_offset
        end

        validate :error_message do
          calculator.pre_offset_payday <= calculator.payday_offset
        end

        next_node do
          question :pay_frequency_paternity?
        end
      end

      ## QP12
      radio :pay_frequency_paternity? do
        option :weekly
        option :every_2_weeks
        option :every_4_weeks
        option :monthly

        on_response do |response|
          calculator.pay_pattern = response
        end

        next_node do
          question :earnings_for_pay_period_paternity?
        end
      end

      ## QP13
      money_question :earnings_for_pay_period_paternity? do
        on_response do |response|
          self.earnings = response
          calculator.earnings_for_pay_period = earnings
        end

        next_node do
          if calculator.average_weekly_earnings_under_lower_earning_limit?
            outcome :paternity_leave_and_pay
          elsif calculator.weekly?
            question :how_many_payments_weekly? # See SharedAdoptionMaternityPaternityFlow for definition
          elsif calculator.every_2_weeks?
            question :how_many_payments_every_2_weeks? # See SharedAdoptionMaternityPaternityFlow for definition
          elsif calculator.every_4_weeks?
            question :how_many_payments_every_4_weeks? # See SharedAdoptionMaternityPaternityFlow for definition
          elsif calculator.monthly?
            question :how_many_payments_monthly? # See SharedAdoptionMaternityPaternityFlow for definition
          else
            question :how_do_you_want_the_spp_calculated?
          end
        end
      end

      ## QP14
      radio :how_do_you_want_the_spp_calculated? do
        option :weekly_starting
        option :usual_paydates

        on_response do |response|
          calculator.period_calculation_method = response
        end

        next_node do
          if calculator.period_calculation_method == "weekly_starting"
            outcome :paternity_leave_and_pay
          elsif calculator.pay_pattern == "monthly"
            question :monthly_pay_paternity?
          else
            question :next_pay_day_paternity?
          end
        end
      end

      ## QP15 - Also shared with adoption calculator here onwards
      date_question :next_pay_day_paternity? do
        from { 2.years.ago(Time.zone.today) }
        to { 2.years.since(Time.zone.today) }

        on_response do |response|
          self.next_pay_day = response
          calculator.pay_date = next_pay_day
        end

        next_node do
          outcome :paternity_leave_and_pay
        end
      end

      ## QP16
      radio :monthly_pay_paternity? do
        option :first_day_of_the_month
        option :last_day_of_the_month
        option :specific_date_each_month
        option :last_working_day_of_the_month
        option :a_certain_week_day_each_month

        on_response do |response|
          self.monthly_pay_method = response
          calculator.monthly_pay_method = monthly_pay_method
        end

        next_node do
          if monthly_pay_method == "specific_date_each_month"
            question :specific_date_each_month_paternity?
          elsif monthly_pay_method == "last_working_day_of_the_month"
            question :days_of_the_week_paternity?
          elsif monthly_pay_method == "a_certain_week_day_each_month"
            question :day_of_the_month_paternity?
          elsif leave_type == "adoption"
            outcome :adoption_leave_and_pay
          else
            outcome :paternity_leave_and_pay
          end
        end
      end

      ## QP17
      value_question :specific_date_each_month_paternity?, parse: :to_i do
        on_response do |response|
          calculator.pay_day_in_month = response
        end

        validate :error_message do
          calculator.pay_day_in_month.positive? && calculator.pay_day_in_month < 32
        end

        next_node do
          if leave_type == "adoption"
            outcome :adoption_leave_and_pay
          else
            outcome :paternity_leave_and_pay
          end
        end
      end

      ## QP18
      checkbox_question :days_of_the_week_paternity? do
        (0...days_of_the_week.size).each { |i| option i.to_s.to_sym }

        on_response do |response|
          calculator.work_days = response.split(",").map(&:to_i)
          calculator.pay_day_in_week = response.split(",").max.to_i
        end

        next_node do
          if leave_type == "adoption"
            outcome :adoption_leave_and_pay
          else
            outcome :paternity_leave_and_pay
          end
        end
      end

      ## QP19
      radio :day_of_the_month_paternity? do
        option :"0"
        option :"1"
        option :"2"
        option :"3"
        option :"4"
        option :"5"
        option :"6"

        on_response do |response|
          calculator.pay_day_in_week = response.to_i
          self.pay_day_in_week = days_of_the_week[calculator.pay_day_in_week]
        end

        next_node do
          question :pay_date_options_paternity?
        end
      end

      ## QP20
      radio :pay_date_options_paternity? do
        option :first
        option :second
        option :third
        option :fourth
        option :last

        on_response do |response|
          calculator.pay_week_in_month = response
        end

        next_node do
          if leave_type == "adoption"
            outcome :adoption_leave_and_pay
          else
            outcome :paternity_leave_and_pay
          end
        end
      end

      # Paternity outcomes
      outcome :paternity_leave_and_pay
      outcome :paternity_not_entitled_to_leave_or_pay
    end
  end
end
