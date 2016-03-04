module SmartAnswer
  class AmIGettingMinimumWageFlow < Flow
    def define
      content_id "111e006d-2b22-4b1f-989a-56bb61355d68"
      name 'am-i-getting-minimum-wage'
      status :published
      satisfies_need "100145"

      # Q1
      multiple_choice :what_would_you_like_to_check? do
        option "current_payment"
        option "past_payment"
        option "current_payment_april_2016"

        calculate :calculator do |response|
          Calculators::MinimumWageCalculator.new(what_to_check: response)
        end

        calculate :accommodation_charge do
          nil
        end

        permitted_next_nodes = [
          :are_you_an_apprentice?,
          :will_you_be_a_first_year_apprentice?,
          :past_payment_date?
        ]

        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'current_payment'
            :are_you_an_apprentice?
          when 'current_payment_april_2016'
            :will_you_be_a_first_year_apprentice?
          when 'past_payment'
            :past_payment_date?
          end
        end
      end

      # Q2 - April 2016
      multiple_choice :will_you_be_a_first_year_apprentice? do
        option :yes
        option :no

        permitted_next_nodes = [
          :does_not_apply_to_first_year_apprentices,
          :how_old_are_you?
        ]

        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            calculator.is_apprentice = true
            :does_not_apply_to_first_year_apprentices
          when 'no'
            :how_old_are_you? #Q3
          end
        end
      end

      # Q3
      value_question :how_old_are_you?, parse: Integer do
        precalculate :age_title do
          if calculator.what_to_check == 'current_payment_april_2016'
            "How old will you be on 1 April 2016?"
          else
            "How old are you?"
          end
        end

        validate do |response|
          calculator.valid_age?(response)
        end

        validate :valid_age_for_living_wage? do |response|
          if calculator.what_to_check == 'current_payment_april_2016'
            calculator.valid_age_for_living_wage?(response)
          else
            true
          end
        end

        permitted_next_nodes = [
          :under_school_leaving_age,
          :how_often_do_you_get_paid?
        ]

        next_node(permitted: permitted_next_nodes) do |response|
          calculator.age = response
          if calculator.under_school_leaving_age?
            :under_school_leaving_age
          else
            :how_often_do_you_get_paid?
          end
        end
      end

      use_shared_logic "minimum_wage"

      outcome :does_not_apply_to_first_year_apprentices
    end
  end
end
