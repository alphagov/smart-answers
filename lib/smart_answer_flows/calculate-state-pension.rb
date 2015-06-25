# -*- coding: utf-8 -*-
module SmartAnswer
  class CalculateStatePensionFlow < Flow
    def define
      name 'calculate-state-pension'
      status :published
      satisfies_need "100245"

      # Q1
      multiple_choice :which_calculation? do
        save_input_as :calculate_age_or_amount

        option :age
        option :amount

        calculate :weekly_state_pension_rate do
          SmartAnswer::Calculators::RatesQuery.new('state_pension').rates.weekly_rate
        end

        next_node :gender?
      end

      # Q2
      multiple_choice :gender? do
        save_input_as :gender

        option :male
        option :female

        # optional text to include in a hint for a later question
        calculate :if_married_woman do |response|
          if response.eql? 'female'
            PhraseList.new(:married_woman_text)
          else
            ''
          end
        end

        next_node_if(:dob_age?, variable_matches(:calculate_age_or_amount, "age"))
        next_node :dob_amount?
      end

      # Q3:Age
      date_question :dob_age? do
        date_of_birth_defaults

        save_input_as :dob

        calculate :calculator do
          Calculators::StatePensionAmountCalculator.new(gender: gender, dob: dob)
        end

        calculate :state_pension_date do
          calculator.state_pension_date
        end

        calculate :old_state_pension do
          calculator.state_pension_date < Date.parse('6 April 2016')
        end

        calculate :pension_credit_date do
          calculator.state_pension_date(:female).strftime("%-d %B %Y")
        end

        calculate :formatted_state_pension_date do
          state_pension_date.strftime("%-d %B %Y")
        end

        calculate :state_pension_age do
          calculator.state_pension_age
        end

        calculate :tense_specific_title do
          if state_pension_date > Date.today
            PhraseList.new(:will_reach_pension_age)
          else
            PhraseList.new(:have_reached_pension_age)
          end
        end

        calculate :available_ni_years do
          calculator.ni_years_to_date_from_dob
        end

        calculate :state_pension_age_statement do
          phrases = PhraseList.new
          if state_pension_date > Date.today
            if state_pension_date >= Date.parse('2016-04-06')
              phrases << :state_pension_age_is_a
              if Date.parse(pension_credit_date) > Date.today
                phrases << :pension_credit_future
              else
                phrases << :pension_credit_past
              end
              phrases << :pension_age_review
            else
              phrases << :state_pension_age_is
              if Date.parse(pension_credit_date) > Date.today
                phrases << :pension_credit_future
              else
                phrases << :pension_credit_past
              end
            end
          else
            phrases << :state_pension_age_was << :pension_credit_past
          end
          phrases << :bus_pass
          phrases
        end

        define_predicate(:near_pension_date?) do |response|
          calc = Calculators::StatePensionAmountCalculator.new(gender: gender, dob: response)
          calc.before_state_pension_date? and calc.within_four_months_one_day_from_state_pension?
        end

        define_predicate(:under_20_years_old?) do |response|
          calc = Calculators::StatePensionAmountCalculator.new(gender: gender, dob: response)
          calc.under_20_years_old?
        end

        validate { |response| response <= Date.today }

        next_node_if(:too_young, under_20_years_old?)
        next_node_if(:near_state_pension_age, near_pension_date?)
        next_node(:age_result)
      end

      # Q3:Amount
      date_question :dob_amount? do
        date_of_birth_defaults

        save_input_as :dob

        calculate :calculator do
          Calculators::StatePensionAmountCalculator.new(gender: gender, dob: dob)
        end

        calculate :state_pension_age do
          calculator.state_pension_age
        end

        calculate :state_pension_date do
          calculator.state_pension_date.to_date
        end

        calculate :old_state_pension do
          calculator.state_pension_date < Date.parse('6 April 2016')
        end

        calculate :formatted_state_pension_date do
          state_pension_date.strftime("%e %B %Y")
        end

        calculate :remaining_years do
          calculator.years_to_pension
        end

        calculate :ni_years_to_date_from_dob do
          calculator.ni_years_to_date_from_dob
        end

        validate { |response| response <= Date.today }

        define_predicate(:before_state_pension_date?) do |response|
          calc = Calculators::StatePensionAmountCalculator.new(gender: gender, dob: response)
          calc.before_state_pension_date?
        end

        define_predicate(:under_20_years_old?) do |response|
          calc = Calculators::StatePensionAmountCalculator.new(gender: gender, dob: response)
          calc.under_20_years_old?
        end

        define_predicate(:woman_and_born_in_date_range?) do |response|
          calc = Calculators::StatePensionAmountCalculator.new(gender: gender, dob: response)
          calc.woman_born_in_married_stamp_era?
        end

        define_predicate(:over_55?) do |response|
          calc = Calculators::StatePensionAmountCalculator.new(gender: gender, dob: response)
          calc.over_55?
        end

        define_predicate(:new_state_pension?) do |response|
          calc = Calculators::StatePensionAmountCalculator.new(gender: gender, dob: response)
          !(calc.state_pension_date < Date.parse('6 April 2016'))
        end

        on_condition(new_state_pension?) do
          next_node_if(:over55_result, over_55?)
        end

        next_node_if(:pay_reduced_ni_rate?, woman_and_born_in_date_range?)
        on_condition(before_state_pension_date?) do
          next_node_if(:too_young, under_20_years_old?)
          next_node :years_paid_ni?
        end
        next_node :reached_state_pension_age
      end

      # Q3a
      multiple_choice :pay_reduced_ni_rate? do
        option :yes
        option :no
        save_input_as :pays_reduced_ni_rate

        define_predicate(:before_state_pension_date?) {
          calculator.before_state_pension_date?
        }

        define_predicate(:under_20_years_old?) {
          calculator.under_20_years_old?
        }

        on_condition(before_state_pension_date?) do
          next_node_if(:too_young, under_20_years_old?)
          next_node :years_paid_ni?
        end
        next_node :reached_state_pension_age
      end

      # Q4
      value_question :years_paid_ni?, parse: Integer do
        # part of a hint for questions 4, 7 and 9 that should only be displayed for women born before 1962
        precalculate :carer_hint_for_women do
          if gender == 'female' and (dob < Date.parse('1962-01-01'))
            PhraseList.new(:carers_allowance_women_hint)
          else
            ''
          end
        end

        validate { |response| (0..ni_years_to_date_from_dob).cover?(response) }

        calculate :carer_hint_for_women_before_1962 do
          if gender == 'female' and (dob < Date.parse('1962-01-01'))
            PhraseList.new(:carers_allowance_women_ni_reduced_years_before_2010)
          else
            ''
          end
        end

        calculate :qualifying_years do |response|
          response
        end

        calculate :available_ni_years do |response|
          calculator.available_years_sum(response)
        end

        calculate :ni_years_to_date_from_dob do |response|
          ni_years_to_date_from_dob - response
        end

        define_predicate(:enough_years_credits_or_no_more_years?) do |response|
          (calculator.enough_qualifying_years_and_credits?(response) && old_state_pension) ||
            (calculator.no_more_available_years?(response) && calculator.three_year_credit_age?)
        end

        define_predicate(:no_more_available_years?) do |response|
          calculator.no_more_available_years?(response)
        end

        next_node_if(:amount_result, enough_years_credits_or_no_more_years?)
        next_node_if(:years_of_work?, no_more_available_years?)
        next_node :years_of_jsa?
      end

      # Q5
      value_question :years_of_jsa?, parse: Integer do

        validate do |response|
          jsa_years = response
          qy = qualifying_years + jsa_years
          (jsa_years >= 0) && calculator.has_available_years?(qy)
        end

        calculate :carer_hint_for_women_before_1962 do
          if gender == 'female' and (dob < Date.parse('1962-01-01'))
            PhraseList.new(:carers_allowance_women_ni_reduced_years_before_2010)
          end
        end

        calculate :qualifying_years do |response|
          jsa_years = response
          qualifying_years + jsa_years
        end

        calculate :available_ni_years do
          calculator.available_years_sum(qualifying_years)
        end

        calculate :ni_years_to_date_from_dob do |response|
          ni_years_to_date_from_dob - response
        end

        next_node_calculation :ni do |response|
          response + qualifying_years
        end

        define_predicate(:enough_years_credits_or_no_more_years?) {
          (calculator.enough_qualifying_years_and_credits?(ni) && old_state_pension) ||
            (calculator.no_more_available_years?(ni) && calculator.three_year_credit_age?)
        }

        define_predicate(:no_more_available_years?) {
          calculator.no_more_available_years?(ni)
        }

        next_node_if(:amount_result, enough_years_credits_or_no_more_years?)
        next_node_if(:years_of_work?, no_more_available_years?)
        next_node :received_child_benefit?
      end

      ## Q6
      multiple_choice :received_child_benefit? do
        option :yes
        option :no

        calculate :ni_years_to_date_from_dob do
          ni_years_to_date_from_dob
        end

        define_predicate(:automatic_ni?) {
          calculator.automatic_ni_age_group?
        }

        define_predicate(:new_rules_and_less_than_10_ni?) {
          ni_and_credits = ni + calculator.starting_credits
          calculator.new_rules_and_less_than_10_ni?(ni_and_credits) && !calculator.credit_band
        }

        define_predicate(:credit_age?) { calculator.credit_age? }

        next_node_if(:years_of_benefit?, responded_with("yes"))
        next_node_if(:years_of_work?, credit_age?)
        next_node_if(:lived_or_worked_outside_uk?, new_rules_and_less_than_10_ni?)
        next_node_if(:amount_result, automatic_ni?)
        next_node :years_of_work?
      end

      ## Q7
      value_question :years_of_benefit?, parse: Integer do

        precalculate :years_you_can_enter do
          calculator.years_can_be_entered(available_ni_years, 22)
        end

        calculate :qualifying_years do |response|
          benefit_years = response
          qy = (benefit_years + qualifying_years)
          if benefit_years > 22 and calculator.has_available_years?(qy)
            raise InvalidResponse, :error_maximum_hrp_years
          elsif benefit_years < 0 or !(calculator.has_available_years?(qy))
            raise InvalidResponse, :error_too_many_years
          end
          qy
        end

        calculate :ni_years_to_date_from_dob do |response|
          ni_years_to_date_from_dob - response
        end

        calculate :available_ni_years do
          calculator.available_years_sum(qualifying_years)
        end

        next_node_calculation :ni do |response|
          response + qualifying_years
        end

        define_predicate(:enough_years_credits_or_no_more_years?) {
          (calculator.enough_qualifying_years_and_credits?(ni) && old_state_pension) ||
            (calculator.no_more_available_years?(ni) && calculator.three_year_credit_age?)
        }

        define_predicate(:no_more_available_years?) {
          calculator.no_more_available_years?(ni)
        }

        next_node_if(:amount_result, enough_years_credits_or_no_more_years?)
        next_node_if(:years_of_work?, no_more_available_years?)
        next_node :years_of_caring?
      end

      ## Q8
      value_question :years_of_caring?, parse: Integer do
        save_input_as :caring_years

        precalculate :allowed_caring_years do
          today = Date.today
          #allow full years from 6 April each year
          (((today.month > 4 or (today.month == 4 and today.day > 5)) ? today.year : today.year - 1) - 2010)
        end

        precalculate :years_you_can_enter do
          calculator.years_can_be_entered(available_ni_years, allowed_caring_years)
        end

        calculate :qualifying_years do |response|
          caring_years = response
          qy = (caring_years + qualifying_years)
          raise InvalidResponse if (caring_years < 0 or (caring_years > allowed_caring_years) or !(calculator.has_available_years?(qy)))
          qy
        end

        calculate :available_ni_years do
          calculator.available_years_sum(qualifying_years)
        end

        calculate :ni_years_to_date_from_dob do |response|
          ni_years_to_date_from_dob - response
        end

        next_node_calculation :ni do |response|
          response + qualifying_years
        end

        define_predicate(:enough_years_credits_or_no_more_years?) {
          (calculator.enough_qualifying_years_and_credits?(ni) && old_state_pension) ||
            (calculator.no_more_available_years?(ni) && calculator.three_year_credit_age?)
        }

        define_predicate(:no_more_available_years?) {
          calculator.no_more_available_years?(ni)
        }

        next_node_if(:amount_result, enough_years_credits_or_no_more_years?)
        next_node_if(:years_of_work?, no_more_available_years?)
        next_node :years_of_carers_allowance?
      end

      ## Q9
      value_question :years_of_carers_allowance?, parse: Integer do
        calculate :qualifying_years do |response|
          caring_years = response
          qy = (caring_years + qualifying_years)
          raise InvalidResponse if caring_years < 0 or !(calculator.has_available_years?(qy))
          qy
        end

        calculate :ni_years_to_date_from_dob do |response|
          ni_years_to_date_from_dob - response
        end

        next_node_calculation :ni do |response|
          response + qualifying_years
        end

        define_predicate(:enough_years_credits_or_three_year_credit?) {
          (calculator.enough_qualifying_years_and_credits?(ni) && old_state_pension) ||
            calculator.three_year_credit_age?
        }

        define_predicate(:new_rules_and_less_than_10_ni?) {
          calculator.new_rules_and_less_than_10_ni? ni
        }

        define_predicate(:credit_age?) { calculator.credit_age? }

        next_node_if(:years_of_work?, credit_age?)
        next_node_if(:lived_or_worked_outside_uk?, new_rules_and_less_than_10_ni?)
        next_node_if(:amount_result, enough_years_credits_or_three_year_credit?)
        next_node :years_of_work?
      end

      ## Q10
      value_question :years_of_work?, parse: Integer do
        save_input_as :years_of_work_entered

        calculate :qualifying_years do |response|
          work_years = response
          qy = (work_years + qualifying_years)
          raise InvalidResponse if (work_years < 0 or work_years > 3)
          qy
        end

        calculate :ni_years_to_date_from_dob do |response|
          calculator.ni_years_to_date_from_dob - response
        end

        next_node_calculation :ni do |response|
          response + qualifying_years
        end

        define_predicate(:new_rules_and_less_than_10_ni?) {
          calculator.new_rules_and_less_than_10_ni? ni
        }

        next_node_if(:lived_or_worked_outside_uk?, new_rules_and_less_than_10_ni?)
        next_node :amount_result
      end

      ## Q11
      multiple_choice :lived_or_worked_outside_uk? do
        option :yes
        option :no
        save_input_as :lived_or_worked_abroad

        next_node :amount_result
      end

      outcome :near_state_pension_age, use_outcome_templates: true

      outcome :reached_state_pension_age, use_outcome_templates: true
      outcome :too_young do
        precalculate :weekly_rate do
          sprintf("%.2f", calculator.current_weekly_rate)
        end
      end

      outcome :age_result
      outcome :over55_result

      outcome :amount_result do
        precalculate :calc do
          Calculators::StatePensionAmountCalculator.new(
            gender: gender, dob: dob, qualifying_years: (qualifying_years)
          )
        end

        precalculate :qualifying_years_total do
          if calc.three_year_credit_age?
            qualifying_years + 3
          else
            if years_of_work_entered
              qualifying_years + calc.calc_qualifying_years_credit(years_of_work_entered)
            else
              ## Q10 was skipped because of flow optimisation
              qualifying_years + calc.calc_qualifying_years_credit(0)
            end
          end
        end

        precalculate :missing_years do
          (qualifying_years_total < 30 ? (30 - qualifying_years_total) : 0)
        end

        precalculate :calculator do
          Calculators::StatePensionAmountCalculator.new(
            gender: gender,
            dob: dob,
            qualifying_years: qualifying_years_total,
            pays_reduced_ni_rate: (pays_reduced_ni_rate.to_s == 'yes')
          )
        end

        precalculate :formatted_state_pension_date do
          calculator.state_pension_date.strftime("%e %B %Y")
        end

        precalculate :state_pension_date do
          calculator.state_pension_date
        end

        precalculate :pension_amount do
          sprintf("%.2f", calculator.what_you_get)
        end

        precalculate :weekly_rate do
          sprintf("%.2f", calculator.current_weekly_rate)
        end

        precalculate :pension_loss do
          sprintf("%.2f", calculator.pension_loss)
        end

        precalculate :what_if_not_full do
          sprintf("%.2f", calculator.what_you_would_get_if_not_full)
        end

        precalculate :pension_summary do
          if calculator.pension_loss > 0
            PhraseList.new(:this_is_n_below_the_full_state_pension)
          else
            PhraseList.new(:this_is_the_full_state_pension)
          end
        end

        precalculate :result_text do
          phrases = PhraseList.new

          enough_qualifying_years = qualifying_years_total >= 30
          enough_remaining_years = remaining_years >= missing_years
          auto_years_entitlement = (dob < Date.parse("6th October 1953") and (gender == "male"))

          if calc.within_four_months_one_day_from_state_pension?
            if enough_qualifying_years
              phrases << :within_4_months_enough_qy_years
            else
              phrases << :within_4_months_not_enough_qy_years
            end

            if Date.today < calc.state_pension_date - 35
              phrases << :pension_statement
            end

            if enough_qualifying_years
              phrases << :within_4_months_enough_qy_years_more
            else
              phrases << :within_4_months_not_enough_qy_years_more
            end

            if auto_years_entitlement && !enough_qualifying_years
              phrases << :automatic_years_phrase
            end
          elsif calculator.state_pension_date >= Date.parse('2016-04-06')
            phrases << :too_few_qy_enough_remaining_years_a_intro
            if qualifying_years_total >= 10
              phrases << :ten_and_greater
              if calculator.qualifies_for_rre_entitlements?
                phrases << :rre_entitlements
              end
            else
              phrases << :less_than_ten
              if pays_reduced_ni_rate == "yes"
                phrases << :reduced_rate_election
              end
              if lived_or_worked_abroad == "yes"
                phrases << :lived_or_worked_overseas
              end
            end
            phrases << :too_few_qy_enough_remaining_years_a
            if auto_years_entitlement
              phrases << :automatic_years_phrase
            end
          elsif !enough_qualifying_years
            if enough_remaining_years
              phrases << :too_few_qy_enough_remaining_years
            else
              phrases << :too_few_qy_not_enough_remaining_years
            end
            if auto_years_entitlement
              phrases << :automatic_years_phrase
            end
          else
            phrases << :you_get_full_state_pension
          end
          phrases
        end

        precalculate :automatic_credits do
          date_of_birth = dob
          if Date.civil(1957, 4, 5) < date_of_birth and date_of_birth < Date.civil(1994, 4, 6)
            PhraseList.new :automatic_credits
          else
            ''
          end
        end
      end
    end
  end
end
