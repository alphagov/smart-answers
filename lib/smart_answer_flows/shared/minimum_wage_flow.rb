module SmartAnswer
  module Shared
    class MinimumWageFlow < Flow
      def define
        # Q1A
        multiple_choice :past_payment_date? do
          option "2015-10-01"
          option "2014-10-01"
          option "2013-10-01"
          option "2012-10-01"
          option "2011-10-01"
          option "2010-10-01"
          option "2009-10-01"

          next_node do |response|
            calculator.date = Date.parse(response)
            question :were_you_an_apprentice?
          end
        end

        # Q2
        multiple_choice :are_you_an_apprentice? do
          option "not_an_apprentice"
          option "apprentice_under_19"
          option "apprentice_over_19_first_year"
          option "apprentice_over_19_second_year_onwards"

          next_node do |response|
            case response
            when 'not_an_apprentice', 'apprentice_over_19_second_year_onwards'
              calculator.is_apprentice = false
              question :how_old_are_you?
            when 'apprentice_under_19', 'apprentice_over_19_first_year'
              calculator.is_apprentice = true
              question :how_often_do_you_get_paid?
            end
          end
        end

        # Q2 Past
        multiple_choice :were_you_an_apprentice? do
          option "no"
          option "apprentice_under_19"
          option "apprentice_over_19"

          next_node do |response|
            case response
            when "no"
              calculator.is_apprentice = false
              question :how_old_were_you?
            else
              calculator.is_apprentice = true
              if calculator.apprentice_eligible_for_minimum_wage?
                question :how_often_did_you_get_paid?
              else
                outcome :does_not_apply_to_historical_apprentices
              end
            end
          end
        end

        # Q3 Past
        value_question :how_old_were_you?, parse: Integer do
          validate do |response|
            calculator.valid_age?(response)
          end

          next_node do |response|
            calculator.age = response
            if calculator.under_school_leaving_age?
              outcome :under_school_leaving_age_past
            else
              question :how_often_did_you_get_paid?
            end
          end
        end

        # Q4
        value_question :how_often_do_you_get_paid?, parse: :to_i do
          validate do |response|
            calculator.valid_pay_frequency?(response)
          end

          next_node do |response|
            calculator.pay_frequency = response
            question :how_many_hours_do_you_work?
          end
        end

        # Q4 Past
        value_question :how_often_did_you_get_paid?, parse: :to_i do
          validate do |response|
            calculator.valid_pay_frequency?(response)
          end

          next_node do |response|
            calculator.pay_frequency = response
            question :how_many_hours_did_you_work?
          end
        end

        # Q5
        value_question :how_many_hours_do_you_work?, parse: Float do
          validate(:error_hours) do |response|
            calculator.valid_hours_worked?(response)
          end

          next_node do |response|
            calculator.basic_hours = response
            question :how_much_are_you_paid_during_pay_period?
          end
        end

        # Q5 Past
        value_question :how_many_hours_did_you_work?, parse: Float do
          validate(:error_hours) do |response|
            calculator.valid_hours_worked?(response)
          end

          next_node do |response|
            calculator.basic_hours = response
            question :how_much_were_you_paid_during_pay_period?
          end
        end

        # Q6
        money_question :how_much_are_you_paid_during_pay_period? do
          next_node do |response|
            calculator.basic_pay = Float(response)
            question :how_many_hours_overtime_do_you_work?
          end
        end

        # Q6 Past
        money_question :how_much_were_you_paid_during_pay_period? do
          next_node do |response|
            calculator.basic_pay = Float(response)
            question :how_many_hours_overtime_did_you_work?
          end
        end

        # Q7
        value_question :how_many_hours_overtime_do_you_work?, parse: Float do
          validate do |response|
            calculator.valid_overtime_hours_worked?(response)
          end

          next_node do |response|
            calculator.overtime_hours = response
            if calculator.any_overtime_hours_worked?
              question :what_is_overtime_pay_per_hour?
            else
              question :is_provided_with_accommodation?
            end
          end
        end

        # Q7 Past
        value_question :how_many_hours_overtime_did_you_work?, parse: Float do
          validate do |response|
            calculator.valid_overtime_hours_worked?(response)
          end

          next_node do |response|
            calculator.overtime_hours = response
            if calculator.any_overtime_hours_worked?
              question :what_was_overtime_pay_per_hour?
            else
              question :was_provided_with_accommodation?
            end
          end
        end

        # Q8
        money_question :what_is_overtime_pay_per_hour? do
          next_node do |response|
            calculator.overtime_hourly_rate = Float(response)
            question :is_provided_with_accommodation?
          end
        end

        # Q8 Past
        money_question :what_was_overtime_pay_per_hour? do
          next_node do |response|
            calculator.overtime_hourly_rate = Float(response)
            question :was_provided_with_accommodation?
          end
        end

        # Q9
        multiple_choice :is_provided_with_accommodation? do
          option "no"
          option "yes_free"
          option "yes_charged"

          next_node do |response|
            case response
            when "yes_free"
              question :current_accommodation_usage?
            when "yes_charged"
              question :current_accommodation_charge?
            else
              if calculator.minimum_wage_or_above?
                outcome :current_payment_above
              else
                outcome :current_payment_below
              end
            end
          end
        end

        # Q9 Past
        multiple_choice :was_provided_with_accommodation? do
          option "no"
          option "yes_free"
          option "yes_charged"

          next_node do |response|
            case response
            when "yes_free"
              question :past_accommodation_usage?
            when "yes_charged"
              question :past_accommodation_charge?
            else
              if calculator.minimum_wage_or_above?
                outcome :past_payment_above
              else
                outcome :past_payment_below
              end
            end
          end
        end

        # Q10
        money_question :current_accommodation_charge? do
          validate do |response|
            calculator.valid_accommodation_charge?(response)
          end

          next_node do
            question :current_accommodation_usage?
          end

          save_input_as :accommodation_charge
        end

        # Q10 Past
        money_question :past_accommodation_charge? do
          validate do |response|
            calculator.valid_accommodation_charge?(response)
          end

          next_node do
            question :past_accommodation_usage?
          end

          save_input_as :accommodation_charge
        end

        # Q11
        value_question :current_accommodation_usage?, parse: Integer do
          validate do |response|
            calculator.valid_accommodation_usage?(response)
          end

          next_node do |response|
            calculator.accommodation_adjustment(accommodation_charge, response)
            if calculator.minimum_wage_or_above?
              outcome :current_payment_above
            else
              outcome :current_payment_below
            end
          end
        end

        # Q11 Past
        value_question :past_accommodation_usage?, parse: Integer do
          validate do |response|
            calculator.valid_accommodation_usage?(response)
          end

          next_node do |response|
            calculator.accommodation_adjustment(accommodation_charge, response)
            if calculator.historically_receiving_minimum_wage?
              outcome :past_payment_above
            else
              outcome :past_payment_below
            end
          end
        end

        outcome :current_payment_above
        outcome :current_payment_below

        outcome :past_payment_above
        outcome :past_payment_below

        outcome :under_school_leaving_age
        outcome :does_not_apply_to_historical_apprentices
        outcome :under_school_leaving_age_past
      end
    end
  end
end
