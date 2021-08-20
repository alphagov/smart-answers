class MaternityPaternityCalculatorFlow < SmartAnswer::Flow
  class MaternityCalculatorFlow < SmartAnswer::Flow
    def define
      days_of_the_week = SmartAnswer::Calculators::MaternityPayCalculator::DAYS_OF_THE_WEEK

      ## QM1
      date_question :baby_due_date_maternity? do
        on_response do |response|
          self.calculator = SmartAnswer::Calculators::MaternityPayCalculator.new(response)
        end

        next_node do
          question :date_leave_starts?
        end
      end

      ## QM2
      date_question :date_leave_starts? do
        on_response do |response|
          self.leave_start_date = response
          calculator.leave_start_date = leave_start_date
          self.leave_end_date = calculator.leave_end_date
          self.notice_of_leave_deadline = calculator.notice_of_leave_deadline
          self.pay_start_date = calculator.pay_start_date
          self.pay_end_date = calculator.pay_end_date
          self.employment_start = calculator.employment_start
          self.qualifying_week_start = calculator.qualifying_week.first
          self.ssp_stop = calculator.ssp_stop
        end

        validate :error_message do
          leave_start_date >= calculator.leave_earliest_start_date
        end

        next_node do
          question :did_the_employee_work_for_you_between?
        end
      end

      ## QM3
      radio :did_the_employee_work_for_you_between? do
        option :yes
        option :no

        on_response do |response|
          self.has_employment_contract_between_dates = response
          calculator.not_entitled_to_pay_reason = response == "no" ? :not_worked_long_enough_and_not_on_payroll : nil
          self.to_saturday = calculator.qualifying_week.last
          self.to_saturday_formatted = calculator.format_date_day(to_saturday)
        end

        next_node do
          case has_employment_contract_between_dates
          when "yes"
            question :last_normal_payday?
          when "no"
            question :does_the_employee_work_for_you_now?
          end
        end
      end

      ## QM4
      radio :does_the_employee_work_for_you_now? do
        option :yes
        option :no

        on_response do |response|
          self.has_employment_contract_now = response
        end

        next_node do
          outcome :maternity_leave_and_pay_result
        end
      end

      ## QM5
      date_question :last_normal_payday? do
        on_response do |response|
          self.last_payday = response
          calculator.last_payday = last_payday
        end

        validate :error_message do
          calculator.last_payday <= to_saturday
        end

        next_node do
          question :payday_eight_weeks?
        end
      end

      ## QM6
      date_question :payday_eight_weeks? do
        on_response do |response|
          self.last_payday_eight_weeks = 1.day.after(response)
          calculator.pre_offset_payday = last_payday_eight_weeks
          self.relevant_period = calculator.formatted_relevant_period
        end

        validate :error_message do
          last_payday_eight_weeks <= calculator.payday_offset
        end

        next_node do
          question :pay_frequency?
        end
      end

      ## QM7
      radio :pay_frequency? do
        option :weekly
        option :every_2_weeks
        option :every_4_weeks
        option :monthly

        on_response do |response|
          calculator.pay_pattern = response
        end

        next_node do
          question :earnings_for_pay_period?
        end
      end

      ## QM8
      money_question :earnings_for_pay_period? do
        on_response do |response|
          calculator.earnings_for_pay_period = response
        end

        next_node do
          if calculator.weekly?
            question :how_many_payments_weekly? # See SharedAdoptionMaternityPaternityFlow for definition
          elsif calculator.every_2_weeks?
            question :how_many_payments_every_2_weeks? # See SharedAdoptionMaternityPaternityFlow for definition
          elsif calculator.every_4_weeks?
            question :how_many_payments_every_4_weeks? # See SharedAdoptionMaternityPaternityFlow for definition
          elsif calculator.monthly?
            question :how_many_payments_monthly? # See SharedAdoptionMaternityPaternityFlow for definition
          else
            question :how_do_you_want_the_smp_calculated?
          end
        end
      end

      ## QM9
      radio :how_do_you_want_the_smp_calculated? do
        option :weekly_starting
        option :usual_paydates

        on_response do |response|
          calculator.period_calculation_method = response
        end

        next_node do
          if calculator.period_calculation_method != "usual_paydates"
            outcome :maternity_leave_and_pay_result
          elsif calculator.pay_pattern == "monthly"
            question :when_in_the_month_is_the_employee_paid?
          else
            question :when_is_your_employees_next_pay_day?
          end
        end
      end

      ## QM10
      date_question :when_is_your_employees_next_pay_day? do
        on_response do |response|
          self.next_pay_day = response
          calculator.pay_date = next_pay_day
        end

        next_node do
          outcome :maternity_leave_and_pay_result
        end
      end

      ## QM11
      radio :when_in_the_month_is_the_employee_paid? do
        option :first_day_of_the_month
        option :last_day_of_the_month
        option :specific_date_each_month
        option :last_working_day_of_the_month
        option :a_certain_week_day_each_month

        on_response do |response|
          calculator.monthly_pay_method = response
        end

        next_node do
          case calculator.monthly_pay_method
          when "first_day_of_the_month", "last_day_of_the_month"
            outcome :maternity_leave_and_pay_result
          when "specific_date_each_month"
            question :what_specific_date_each_month_is_the_employee_paid?
          when "last_working_day_of_the_month"
            question :what_days_does_the_employee_work?
          when "a_certain_week_day_each_month"
            question :what_particular_day_of_the_month_is_the_employee_paid?
          end
        end
      end

      ## QM12
      value_question :what_specific_date_each_month_is_the_employee_paid?, parse: :to_i do
        on_response do |response|
          self.pay_day_in_month = response
          calculator.pay_day_in_month = pay_day_in_month
        end

        validate :error_message do
          pay_day_in_month.positive? && pay_day_in_month < 32
        end

        next_node do
          outcome :maternity_leave_and_pay_result
        end
      end

      ## QM13
      checkbox_question :what_days_does_the_employee_work? do
        (0...days_of_the_week.size).each { |i| option i.to_s.to_sym }

        on_response do |response|
          self.last_day_in_week_worked = response
          calculator.work_days = last_day_in_week_worked.split(",").map(&:to_i)
          calculator.pay_day_in_week = calculator.work_days.max
        end

        next_node do
          outcome :maternity_leave_and_pay_result
        end
      end

      ## QM14
      radio :what_particular_day_of_the_month_is_the_employee_paid? do
        days_of_the_week.each { |d| option d.to_sym }

        on_response do |response|
          self.pay_day_in_week = response
          calculator.pay_day_in_week = days_of_the_week.index(pay_day_in_week)
        end

        next_node do
          question :which_week_in_month_is_the_employee_paid?
        end
      end

      ## QM15
      radio :which_week_in_month_is_the_employee_paid? do
        option :first
        option :second
        option :third
        option :fourth
        option :last

        on_response do |response|
          self.pay_week_in_month = response
          calculator.pay_week_in_month = pay_week_in_month
        end
        next_node do
          outcome :maternity_leave_and_pay_result
        end
      end

      ## Maternity outcomes
      outcome :maternity_leave_and_pay_result
    end
  end
end
