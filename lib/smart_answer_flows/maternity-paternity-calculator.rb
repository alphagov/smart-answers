module SmartAnswer
  class MaternityPaternityCalculatorFlow < Flow
    def define
      name 'maternity-paternity-calculator'
      status :published
      satisfies_need "100990"

      ## Q1
      multiple_choice :what_type_of_leave? do
        save_input_as :leave_type
        option :maternity
        option :paternity
        option :adoption

        next_node do |response|
          case response
          when "maternity"
            :baby_due_date_maternity?
          when "paternity"
            :leave_or_pay_for_adoption?
          when "adoption"
            :taking_paternity_leave_for_adoption?
          end
        end
      end

      ## QA0
      multiple_choice :taking_paternity_leave_for_adoption? do
        option :yes
        option :no

        next_node do |response|
          case response
          when "yes"
            :employee_date_matched_paternity_adoption?
          when "no"
            :date_of_adoption_match?
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
          :date_of_adoption_placement?
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
        next_node do
          :adoption_did_the_employee_work_for_you?
        end
      end

      ## QA3
      multiple_choice :adoption_did_the_employee_work_for_you? do
        option :yes
        option :no

        calculate :adoption_leave_info do
          PhraseList.new(:adoption_not_entitled_to_leave_or_pay)
        end

        next_node do |response|
          case response
          when "yes"
            :adoption_employment_contract?
          when "no"
            :adoption_not_entitled_to_leave_or_pay
          end
        end
      end

      ## QA4
      multiple_choice :adoption_employment_contract? do
        option :yes
        option :no

        save_input_as :employee_has_contract_adoption

        #not entitled to leave if no contract; keep asking questions to check eligibility
        calculate :adoption_leave_info do |response|
          if response == 'no'
            PhraseList.new(:adoption_not_entitled_to_leave)
          end
        end

        next_node do
          :adoption_is_the_employee_on_your_payroll?
        end
      end

      ## QA5
      multiple_choice :adoption_is_the_employee_on_your_payroll? do
        option :yes
        option :no

        save_input_as :on_payroll

        calculate :adoption_pay_info do |response|
          if response == 'no'
            PhraseList.new(
              :adoption_not_entitled_to_pay_intro,
              :must_be_on_payroll,
              :adoption_not_entitled_to_pay_outro
            )
          end
        end

        calculate :to_saturday do
          calculator.matched_week.last
        end

        calculate :to_saturday_formatted do
          calculator.format_date_day to_saturday
        end

        next_node do |response|
          if employee_has_contract_adoption == 'no' && response == 'no'
            next :adoption_not_entitled_to_leave_or_pay
          end
          :adoption_date_leave_starts?
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

        calculate :adoption_leave_info do
          if adoption_leave_info.nil?
            PhraseList.new(:adoption_leave_table)
          else
            adoption_leave_info
          end
        end

        next_node do |response|
          if employee_has_contract_adoption == 'yes' && on_payroll == 'no'
            next :adoption_leave_and_pay
          end
          :last_normal_payday_adoption?
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
          :payday_eight_weeks_adoption?
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
          :pay_frequency_adoption?
        end
      end

      # QA9
      multiple_choice :pay_frequency_adoption? do
        option :weekly
        option :every_2_weeks
        option :every_4_weeks
        option :monthly
        save_input_as :pay_pattern

        calculate :calculator do |response|
          calculator.pay_method = response
          calculator
        end

        next_node do
          :earnings_for_pay_period_adoption?
        end
      end

      ## QA10
      money_question :earnings_for_pay_period_adoption? do

       calculate :lower_earning_limit do
         sprintf("%.2f", calculator.lower_earning_limit)
       end

        calculate :average_weekly_earnings do
          sprintf("%.2f", calculator.average_weekly_earnings)
        end

        calculate :above_lower_earning_limit? do
          calculator.average_weekly_earnings > calculator.lower_earning_limit
        end

        next_node_calculation :calculator do |response|
          calculator.calculate_average_weekly_pay(pay_pattern, response)
          calculator
        end

         calculate :adoption_pay_info do
          if calculator.average_weekly_earnings < calculator.lower_earning_limit
            PhraseList.new(
              :adoption_not_entitled_to_pay_intro,
              :must_earn_over_threshold,
              :adoption_not_entitled_to_pay_outro
            )
          else
            PhraseList.new(:adoption_pay_table)
          end
        end

        next_node do |response|
          if calculator.average_weekly_earnings < calculator.lower_earning_limit
            next :adoption_leave_and_pay
          end
          :how_do_you_want_the_sap_calculated?
        end
      end

      ## QA11
      multiple_choice :how_do_you_want_the_sap_calculated? do
        option :weekly_starting
        option :usual_paydates

        save_input_as :sap_calculation_method

        calculate :adoption_pay_info do
          PhraseList.new(:adoption_pay_table)
        end

        next_node do |response|
          if ['weekly_starting'].include?(response)
            next :adoption_leave_and_pay
          end
          if ['monthly'].include?(pay_pattern)
            next :monthly_pay_paternity? ## Shared with paternity calculator
          end
          :next_pay_day_paternity? ## Shared with paternity calculator
        end
      end

      outcome :adoption_leave_and_pay do

        precalculate :pay_method do
          calculator.pay_method = (
            if monthly_pay_method
              if monthly_pay_method == 'specific_date_each_month' and pay_day_in_month > 28
                'last_day_of_the_month'
              else
                monthly_pay_method
              end
            elsif sap_calculation_method == 'weekly_starting'
              sap_calculation_method
            else
              pay_pattern
            end
          )
        end

        precalculate :pay_dates_and_pay do
          if above_lower_earning_limit?
            calculator.paydates_and_pay.map do |date_and_pay|
              %Q(#{date_and_pay[:date].strftime("%e %B %Y")}|£#{sprintf("%.2f", date_and_pay[:pay])})
            end.join("\n")
          end
        end

        precalculate :total_sap do
          if above_lower_earning_limit?
            sprintf("%.2f", calculator.total_statutory_pay)
          end
        end
      end

      outcome :adoption_not_entitled_to_leave_or_pay

      days_of_the_week = Calculators::MaternityPaternityCalculator::DAYS_OF_THE_WEEK

      ## QP0
      multiple_choice :leave_or_pay_for_adoption? do
        option :yes
        option :no

        next_node do |response|
          case response
          when "yes"
            :employee_date_matched_paternity_adoption?
          when "no"
            :baby_due_date_paternity?
          end
        end
      end

      ## QP1
      date_question :baby_due_date_paternity? do
        calculate :due_date do |response|
          response
        end

        calculate :calculator do
          Calculators::MaternityPaternityCalculator.new(due_date, 'paternity')
        end

        next_node do
          :baby_birth_date_paternity?
        end
      end

      ## QAP1 - Paternity Adoption
      date_question :employee_date_matched_paternity_adoption? do
        calculate :matched_date do |response|
          response
        end

        calculate :calculator do
          Calculators::MaternityPaternityCalculator.new(matched_date, 'paternity_adoption')
        end

        calculate :leave_type do
          'paternity_adoption'
        end

        calculate :paternity_adoption? do
          leave_type == 'paternity_adoption'
        end

        next_node do
          :padoption_date_of_adoption_placement?
        end
      end

      ## QP2
      date_question :baby_birth_date_paternity? do
        calculate :date_of_birth do |response|
          response
        end

        calculate :calculator do
          calculator.date_of_birth = date_of_birth
          calculator
        end

        next_node do
          :employee_responsible_for_upbringing?
        end
      end

      ## QAP2 - Paternity Adoption
      date_question :padoption_date_of_adoption_placement? do

        calculate :ap_adoption_date do |response|
          placement_date = response
          raise SmartAnswer::InvalidResponse if placement_date < matched_date
          calculator.adoption_placement_date = placement_date
          placement_date
        end

        calculate :ap_adoption_date_formatted do
          calculator.format_date_day ap_adoption_date
        end

        calculate :matched_date_formatted do
          calculator.format_date_day matched_date
        end

        next_node do
          :padoption_employee_responsible_for_upbringing?
        end
      end

      ## QP3
      multiple_choice :employee_responsible_for_upbringing? do
        option :yes
        option :no
        save_input_as :paternity_responsible

        calculate :employment_start do
          calculator.employment_start
        end

        calculate :employment_end do
          due_date
        end

        calculate :p_notice_leave do
          calculator.notice_of_leave_deadline
        end

        next_node do |response|
          case response
          when "yes"
            :employee_work_before_employment_start?
          when "no"
            :paternity_not_entitled_to_leave_or_pay
          end
        end
      end

      ## QAP3 - Paternity Adoption
      multiple_choice :padoption_employee_responsible_for_upbringing? do
        option :yes
        option :no
        save_input_as :paternity_responsible

        calculate :employment_start do
          calculator.a_employment_start
        end

        calculate :employment_end do
          matched_date
        end

        next_node do |response|
          case response
          when "yes"
            :employee_work_before_employment_start?
          when "no"
            :paternity_not_entitled_to_leave_or_pay
          end
        end
      end

      ## QP4 - Shared flow onwards
      multiple_choice :employee_work_before_employment_start? do
        option :yes
        option :no
        save_input_as :paternity_employment_start ## Needed only in outcome

        next_node do |response|
          case response
          when "yes"
            :employee_has_contract_paternity?
          when "no"
            :paternity_not_entitled_to_leave_or_pay
          end
        end
      end

      ## QP5
      multiple_choice :employee_has_contract_paternity? do
        option :yes
        option :no
        save_input_as :has_contract

        next_node do
          :employee_on_payroll_paternity?
        end
      end

      ## QP6
      multiple_choice :employee_on_payroll_paternity? do
        option :yes
        option :no
        save_input_as :on_payroll

        calculate :leave_spp_claim_link do
          if paternity_adoption?
            'adoption'
          else
            'notice-period'
          end
        end

        calculate :not_entitled_reason do |response|
          if response == 'no' && has_contract == 'no'
            PhraseList.new(
              :paternity_not_entitled_to_leave,
              :paternity_not_entitled_to_pay_intro,
              :must_be_on_payroll,
              :paternity_not_entitled_to_pay_outro
            )
          end
        end

        calculate :to_saturday do
          if paternity_adoption?
            calculator.matched_week.last
          else
            calculator.qualifying_week.last
          end
        end

        calculate :to_saturday_formatted do
          calculator.format_date_day to_saturday
        end

        calculate :still_employed_date do
          if paternity_adoption?
            calculator.employment_end
          else
            date_of_birth
          end
        end

        calculate :start_leave_hint do
          if paternity_adoption?
            ap_adoption_date_formatted
          else
            date_of_birth
          end
        end

        next_node do |response|
          case response
          when "yes"
            :employee_still_employed_on_birth_date?
          when "no"
            if ['no'].include?(has_contract)
              next :paternity_not_entitled_to_leave_or_pay
            end
            :employee_start_paternity?
          end
        end
      end

      ## QP7
      multiple_choice :employee_still_employed_on_birth_date? do
        option :yes
        option :no
        save_input_as :employed_dob

        calculate :not_entitled_reason do |response|
          if response == 'no' and has_contract == 'no'
            PhraseList.new(
              :paternity_not_entitled_to_leave,
              :paternity_not_entitled_to_pay_intro,
              :"#{leave_type}_must_be_employed_by_you",
              :paternity_not_entitled_to_pay_outro
            )
          end
        end

        next_node do |response|
          if ['no'].include?(has_contract) && ['no'].include?(response)
            next :paternity_not_entitled_to_leave_or_pay
          end
          :employee_start_paternity?
        end
      end

      ## QP8
      date_question :employee_start_paternity? do
        from { 2.years.ago(Date.today) }
        to { 2.years.since(Date.today) }

        save_input_as :employee_leave_start

        calculate :leave_start_date do |response|
          calculator.leave_start_date = response
          if paternity_adoption?
            raise SmartAnswer::InvalidResponse if calculator.leave_start_date < ap_adoption_date
          else
            raise SmartAnswer::InvalidResponse if calculator.leave_start_date < date_of_birth
          end
          calculator.leave_start_date
        end

        calculate :notice_of_leave_deadline do
          calculator.notice_of_leave_deadline
        end

        next_node do
          :employee_paternity_length?
        end
      end

      ## QP9
      multiple_choice :employee_paternity_length? do
        option :one_week
        option :two_weeks
        save_input_as :leave_amount

        calculate :leave_end_date do |response|
          unless leave_start_date.nil?
            if response == 'one_week'
              1.week.since(leave_start_date)
            else
              2.weeks.since(leave_start_date)
            end
          end
        end

        calculate :not_entitled_reason do
          if has_contract == 'yes'
            if employed_dob == 'no'
              PhraseList.new(
                :paternity_entitled_to_leave,
                :paternity_not_entitled_to_pay_intro,
                :"#{leave_type}_must_be_employed_by_you",
                :paternity_not_entitled_to_pay_outro
              )
            elsif on_payroll == 'no'
              PhraseList.new(
                :paternity_entitled_to_leave,
                :paternity_not_entitled_to_pay_intro,
                :must_be_on_payroll,
                :paternity_not_entitled_to_pay_outro
              )
            end
          end
        end

        next_node do |response|
          if ['yes'].include?(has_contract) && (['no'].include?(on_payroll) || ['no'].include?(employed_dob))
            next :paternity_not_entitled_to_leave_or_pay
          end
          :last_normal_payday_paternity?
        end
      end

      ## QP10
      date_question :last_normal_payday_paternity? do
        from { 2.years.ago(Date.today) }
        to { 2.years.since(Date.today) }

        calculate :calculator do |response|
          calculator.last_payday = response
          raise SmartAnswer::InvalidResponse if calculator.last_payday > to_saturday
          calculator
        end

        next_node do
          :payday_eight_weeks_paternity?
        end
      end

      ## QP11
      date_question :payday_eight_weeks_paternity? do
        from { 2.years.ago(Date.today) }
        to { 2.years.since(Date.today) }

        precalculate :payday_offset do
          calculator.payday_offset
        end

        precalculate :payday_offset_formatted do
          calculator.format_date_day payday_offset
        end

        calculate :pre_offset_payday do |response|
          payday = response + 1.day
          raise SmartAnswer::InvalidResponse if payday > calculator.payday_offset
          calculator.pre_offset_payday = payday
          payday
        end

        calculate :relevant_period do
          calculator.formatted_relevant_period
        end

        next_node do
          :pay_frequency_paternity?
        end
      end

      ## QP12
      multiple_choice :pay_frequency_paternity? do
        option :weekly
        option :every_2_weeks
        option :every_4_weeks
        option :monthly
        save_input_as :pay_pattern

        calculate :calculator do |response|
          calculator.pay_method = response
          calculator
        end

        next_node do
          :earnings_for_pay_period_paternity?
        end
      end

      ## QP13
      money_question :earnings_for_pay_period_paternity? do
        save_input_as :earnings

        next_node_calculation :calculator do |response|
          calculator.calculate_average_weekly_pay(pay_pattern, response)
          calculator
        end

        next_node do |response|
          if calculator.average_weekly_earnings < calculator.lower_earning_limit
            next :paternity_leave_and_pay
          end
          :how_do_you_want_the_spp_calculated?
        end
      end

      ## QP14
      multiple_choice :how_do_you_want_the_spp_calculated? do
        option :weekly_starting
        option :usual_paydates

        save_input_as :spp_calculation_method

        next_node do |response|
          if ['weekly_starting'].include?(response)
            next :paternity_leave_and_pay
          end
          if ['monthly'].include?(pay_pattern)
            next :monthly_pay_paternity?
          end
          :next_pay_day_paternity?
        end
      end

      ## QP15 - Also shared with adoption calculator here onwards
      date_question :next_pay_day_paternity? do
        from { 2.years.ago(Date.today) }
        to { 2.years.since(Date.today) }
        save_input_as :next_pay_day

        calculate :calculator do |response|
          calculator.pay_date = response
          calculator
        end
        next_node do
          :paternity_leave_and_pay
        end
      end

      ## QP16
      multiple_choice :monthly_pay_paternity? do
        option :first_day_of_the_month
        option :last_day_of_the_month
        option :specific_date_each_month
        option :last_working_day_of_the_month
        option :a_certain_week_day_each_month

        save_input_as :monthly_pay_method

        next_node do |response|
          case response
          when "specific_date_each_month"
            :specific_date_each_month_paternity?
          when "last_working_day_of_the_month"
            :days_of_the_week_paternity?
          when "a_certain_week_day_each_month"
            :day_of_the_month_paternity?
          else
            if ['adoption'].include?(leave_type)
              next :adoption_leave_and_pay
            end
            :paternity_leave_and_pay
          end
        end
      end

      ## QP17
      value_question :specific_date_each_month_paternity?, parse: :to_i do

        calculate :pay_day_in_month do |response|
          day = response
          raise InvalidResponse unless day > 0 and day < 32
          calculator.pay_day_in_month = day
        end

        next_node do |response|
          if ['adoption'].include?(leave_type)
            next :adoption_leave_and_pay
          end
          :paternity_leave_and_pay
        end
      end

      ## QP18
      checkbox_question :days_of_the_week_paternity? do
        (0...days_of_the_week.size).each { |i| option i.to_s.to_sym }

        calculate :last_day_in_week_worked do |response|
          calculator.work_days = response.split(",").map(&:to_i)
          calculator.pay_day_in_week = response.split(",").sort.last.to_i
        end

        next_node do |response|
          if ['adoption'].include?(leave_type)
            next :adoption_leave_and_pay
          end
          :paternity_leave_and_pay
        end
      end

      ## QP19
      multiple_choice :day_of_the_month_paternity? do
        option :"0"
        option :"1"
        option :"2"
        option :"3"
        option :"4"
        option :"5"
        option :"6"

        calculate :pay_day_in_week do |response|
          calculator.pay_day_in_week = response.to_i
          days_of_the_week[response.to_i]
        end

        next_node do
          :pay_date_options_paternity?
        end
      end

      ## QP20
      multiple_choice :pay_date_options_paternity? do
        option :"first"
        option :"second"
        option :"third"
        option :"fourth"
        option :"last"

        calculate :pay_week_in_month do |response|
          calculator.pay_week_in_month = response
        end

        next_node do |response|
          if ['adoption'].include?(leave_type)
            next :adoption_leave_and_pay
          end
          :paternity_leave_and_pay
        end
      end

      # Paternity outcomes
      outcome :paternity_leave_and_pay do

        precalculate :pay_method do
          calculator.pay_method = (
            if monthly_pay_method
              if monthly_pay_method == 'specific_date_each_month' and pay_day_in_month > 28
                'last_day_of_the_month'
              else
                monthly_pay_method
              end
            elsif spp_calculation_method == 'weekly_starting'
              spp_calculation_method
            else
              pay_pattern
            end
          )
        end

        precalculate :above_lower_earning_limit? do
          calculator.average_weekly_earnings > calculator.lower_earning_limit
        end

        precalculate :paternity_info do
          phrases = PhraseList.new

          if has_contract == "no"
            phrases << :paternity_not_entitled_to_leave
          else
            phrases << :paternity_entitled_to_leave
          end

          unless above_lower_earning_limit?
            phrases << :paternity_not_entitled_to_pay_intro <<
                        :must_earn_over_threshold <<
                        :paternity_not_entitled_to_pay_outro
          else
            phrases << :paternity_entitled_to_pay << :"#{leave_type}_spp_claim_link"
          end
          phrases
        end

        precalculate :lower_earning_limit do
          sprintf("%.2f", calculator.lower_earning_limit)
        end

        precalculate :entitled_to_pay? do
          !paternity_info.nil? && paternity_info.phrase_keys.include?(:paternity_entitled_to_pay)
        end

        precalculate :pay_dates_and_pay do
          if entitled_to_pay? && above_lower_earning_limit?
            calculator.paydates_and_pay.map do |date_and_pay|
              %Q(#{date_and_pay[:date].strftime("%e %B %Y")}|£#{sprintf("%.2f", date_and_pay[:pay])})
            end.join("\n")
          end
        end

        precalculate :total_spp do
          if above_lower_earning_limit?
            sprintf("%.2f", calculator.total_statutory_pay)
          end
        end

        precalculate :average_weekly_earnings do
          sprintf("%.2f", calculator.average_weekly_earnings)
        end

      end

      outcome :paternity_not_entitled_to_leave_or_pay do
        precalculate :not_entitled_reason do
          if not_entitled_reason.nil?
            phrases = PhraseList.new(:paternity_not_entitled_to_leave_or_pay_intro)
            if paternity_responsible == 'no'
              phrases << :"#{leave_type}_not_responsible_for_upbringing"
            end
            if paternity_employment_start == "no"
              phrases << :not_worked_long_enough
            end
            phrases << :paternity_not_entitled_to_leave_or_pay_outro
            phrases
          else
            not_entitled_reason
          end
        end
      end


      days_of_the_week = Calculators::MaternityPaternityCalculator::DAYS_OF_THE_WEEK

      ## QM1
      date_question :baby_due_date_maternity? do
        from { 1.year.ago(Date.today) }
        to { 2.years.since(Date.today) }

        calculate :calculator do |response|
          Calculators::MaternityPaternityCalculator.new(response)
        end
        next_node do
          :employment_contract?
        end
      end

      ## QM2
      multiple_choice :employment_contract? do
        option :yes
        option :no
        calculate :maternity_leave_info do |response|
          if response == 'yes'
            PhraseList.new(:maternity_leave_table)
          else
            PhraseList.new(:not_entitled_to_statutory_maternity_leave)
          end
        end
        next_node do
          :date_leave_starts?
        end
      end

      ## QM3
      date_question :date_leave_starts? do
        from { 2.years.ago(Date.today) }
        to { 2.years.since(Date.today) }

        precalculate :leave_earliest_start_date do
          calculator.leave_earliest_start_date
        end

        calculate :leave_start_date do |response|
          ls_date = response
          raise SmartAnswer::InvalidResponse if ls_date < leave_earliest_start_date
          calculator.leave_start_date = ls_date
          calculator.leave_start_date
        end

        calculate :leave_end_date do
          calculator.leave_end_date
        end
        calculate :leave_earliest_start_date do
          calculator.leave_earliest_start_date
        end
        calculate :notice_of_leave_deadline do
          calculator.notice_of_leave_deadline
        end

        calculate :pay_start_date do
          calculator.pay_start_date
        end
        calculate :pay_end_date do
          calculator.pay_end_date
        end
        calculate :employment_start do
          calculator.employment_start
        end
        calculate :ssp_stop do
          calculator.ssp_stop
        end
        next_node do
          :did_the_employee_work_for_you?
        end
      end

      ## QM4
      multiple_choice :did_the_employee_work_for_you? do
        option :yes
        option :no
        calculate :not_entitled_to_pay_reason do |response|
          if response == 'no'
            :not_worked_long_enough
          else
            nil
          end
        end

        next_node do |response|
          case response
          when "yes"
            :is_the_employee_on_your_payroll?
          when "no"
            :maternity_leave_and_pay_result
          end
        end
      end

      ## QM5
      multiple_choice :is_the_employee_on_your_payroll? do
        option :yes
        option :no

        calculate :not_entitled_to_pay_reason do |response|
          if response == 'no'
            :must_be_on_payroll
          else
            nil
          end
        end

        calculate :to_saturday do
          calculator.qualifying_week.last
        end

        calculate :to_saturday_formatted do
          calculator.format_date_day to_saturday
        end

        next_node do |response|
          case response
          when "yes"
            :last_normal_payday?
          when "no"
            :maternity_leave_and_pay_result
          end
        end
      end

      ## QM6
      date_question :last_normal_payday? do
        from { 2.years.ago(Date.today) }
        to { 2.years.since(Date.today) }

        calculate :last_payday do |response|
          calculator.last_payday = response
          raise SmartAnswer::InvalidResponse if calculator.last_payday > to_saturday
          calculator.last_payday
        end
        next_node do
          :payday_eight_weeks?
        end
      end

      ## QM7
      date_question :payday_eight_weeks? do
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
          :pay_frequency?
        end
      end

      ## QM8
      multiple_choice :pay_frequency? do
        save_input_as :pay_pattern
        option :weekly
        option :every_2_weeks
        option :every_4_weeks
        option :monthly

        next_node do
          :earnings_for_pay_period?
        end
      end

      ## QM9 Maternity only onwards
      money_question :earnings_for_pay_period? do
        calculate :calculator do |response|
          calculator.calculate_average_weekly_pay(pay_pattern, response)
          calculator
        end
        calculate :average_weekly_earnings do
          calculator.average_weekly_earnings
        end
        next_node do
          :how_do_you_want_the_smp_calculated?
        end
      end

      ## QM10
      multiple_choice :how_do_you_want_the_smp_calculated? do
        option :weekly_starting
        option :usual_paydates

        save_input_as :smp_calculation_method

        next_node do |response|
          if ["usual_paydates"].include?(response)
            if ["monthly"].include?(pay_pattern)
              next :when_in_the_month_is_the_employee_paid?
            end
            next :when_is_your_employees_next_pay_day?
          end
          :maternity_leave_and_pay_result
        end
      end

      ## QM11
      date_question :when_is_your_employees_next_pay_day? do
        calculate :next_pay_day do |response|
          calculator.pay_date = response
          calculator.pay_date
        end

        next_node do
          :maternity_leave_and_pay_result
        end
      end

      ## QM12
      multiple_choice :when_in_the_month_is_the_employee_paid? do
        option :first_day_of_the_month
        option :last_day_of_the_month
        option :specific_date_each_month
        option :last_working_day_of_the_month
        option :a_certain_week_day_each_month

        save_input_as :monthly_pay_method

        next_node do |response|
          case response
          when "first_day_of_the_month", "last_day_of_the_month"
            :maternity_leave_and_pay_result
          when "specific_date_each_month"
            :what_specific_date_each_month_is_the_employee_paid?
          when "last_working_day_of_the_month"
            :what_days_does_the_employee_work?
          when "a_certain_week_day_each_month"
            :what_particular_day_of_the_month_is_the_employee_paid?
          end
        end
      end

      ## QM13
      value_question :what_specific_date_each_month_is_the_employee_paid?, parse: :to_i do
        calculate :pay_day_in_month do |response|
          day = response
          raise InvalidResponse unless day > 0 and day < 32
          calculator.pay_day_in_month = day
        end

        next_node do
          :maternity_leave_and_pay_result
        end
      end

      ## QM14
      checkbox_question :what_days_does_the_employee_work? do
        (0...days_of_the_week.size).each { |i| option i.to_s.to_sym }

        calculate :last_day_in_week_worked do |response|
          calculator.work_days = response.split(",").map(&:to_i)
          calculator.pay_day_in_week = response.split(",").sort.last.to_i
        end
        next_node do
          :maternity_leave_and_pay_result
        end
      end

      ## QM15
      multiple_choice :what_particular_day_of_the_month_is_the_employee_paid? do
        days_of_the_week.each { |d| option d.to_sym }

        calculate :pay_day_in_week do |response|
          calculator.pay_day_in_week = days_of_the_week.index(response)
          response
        end
        next_node do
          :which_week_in_month_is_the_employee_paid?
        end
      end

      ## QM16
      multiple_choice :which_week_in_month_is_the_employee_paid? do
        option :"first"
        option :"second"
        option :"third"
        option :"fourth"
        option :"last"

        calculate :pay_week_in_month do |response|
          calculator.pay_week_in_month = response
        end
        next_node do
          :maternity_leave_and_pay_result
        end
      end

      ## Maternity outcomes
      outcome :maternity_leave_and_pay_result do

        precalculate :pay_method do
          calculator.pay_method = (
            if monthly_pay_method
              if monthly_pay_method == 'specific_date_each_month' and pay_day_in_month > 28
                'last_day_of_the_month'
              else
                monthly_pay_method
              end
            elsif smp_calculation_method == 'weekly_starting'
              smp_calculation_method
            elsif pay_pattern
              pay_pattern
            end
          )
        end
        precalculate :smp_a do
          sprintf("%.2f", calculator.statutory_maternity_rate_a)
        end
        precalculate :smp_b do
          sprintf("%.2f", calculator.statutory_maternity_rate_b)
        end
        precalculate :lower_earning_limit do
          sprintf("%.2f", calculator.lower_earning_limit)
        end

        precalculate :notice_request_pay do
          calculator.notice_request_pay
        end

        precalculate :below_threshold do
          calculator.average_weekly_earnings and
            calculator.average_weekly_earnings < calculator.lower_earning_limit
        end

        precalculate :not_entitled_to_pay_reason do
          if below_threshold
            :must_earn_over_threshold
          else
            not_entitled_to_pay_reason
          end
        end

        precalculate :total_smp do
          unless not_entitled_to_pay_reason.present?
            sprintf("%.2f", calculator.total_statutory_pay)
          end
        end

        precalculate :maternity_pay_info do
          if not_entitled_to_pay_reason.present?
            pay_info = PhraseList.new
            if calculator.average_weekly_earnings
              pay_info << :not_entitled_to_smp_intro_with_awe
            else
              pay_info << :not_entitled_to_smp_intro
            end
            pay_info << not_entitled_to_pay_reason
            pay_info << :not_entitled_to_smp_outro
          else
            pay_info = PhraseList.new(:maternity_pay_table, :paydates_table)
          end
          pay_info
        end

        precalculate :pay_dates_and_pay do
          unless not_entitled_to_pay_reason.present?
            calculator.paydates_and_pay.map do |date_and_pay|
              %Q(#{date_and_pay[:date].strftime("%e %B %Y")}|£#{sprintf("%.2f", date_and_pay[:pay])})
            end.join("\n")
          end
        end
      end
    end
  end
end
