require "data/state_pension_date_query"

module SmartAnswer
  class StatePensionAgeFlow < Flow
    def define
      content_id "5491c439-1c83-4044-80d3-32cc3613b739"
      name 'state-pension-age'
      status :published
      satisfies_need "100245"

      # Q1
      multiple_choice :which_calculation? do
        option :age
        option :bus_pass

        save_input_as :which_calculation

        permitted_next_nodes = [
          :dob_age?
        ]
        next_node(permitted: permitted_next_nodes) do
          :dob_age?
        end
      end

      # Q2:Age
      date_question :dob_age? do
        date_of_birth_defaults

        validate { |response| response <= Date.today }

        save_input_as :dob

        permitted_next_nodes = [
          :bus_pass_age_result,
          :gender?
        ]

        next_node(permitted: permitted_next_nodes) do
          if which_calculation == 'age'
            :gender?
          else
            :bus_pass_age_result
          end
        end
      end

      # Q3
      multiple_choice :gender? do
        option :male
        option :female

        next_node_calculation :calculator do |response|
          Calculators::StatePensionAgeCalculator.new(dob: dob, gender: response)
        end

        calculate :state_pension_date do
          calculator.state_pension_date
        end

        calculate :old_state_pension do
          calculator.state_pension_date < Date.parse('6 April 2016')
        end

        calculate :pension_credit_date do
          StatePensionDateQuery.bus_pass_qualification_date(dob).strftime("%-d %B %Y")
        end

        calculate :formatted_state_pension_date do
          state_pension_date.strftime("%-d %B %Y")
        end

        calculate :state_pension_age do
          calculator.state_pension_age
        end

        calculate :available_ni_years do
          calculator.ni_years_to_date_from_dob
        end

        permitted_next_nodes = [
          :too_young,
          :near_state_pension_age,
          :age_result
        ]
        next_node(permitted: permitted_next_nodes) do
          near_pension_date = calculator.before_state_pension_date? && calculator.within_four_months_one_day_from_state_pension?
          under_20_years_old = calculator.under_20_years_old?

          if under_20_years_old
            :too_young
          elsif near_pension_date
            :near_state_pension_age
          else
            :age_result
          end
        end
      end

      outcome :bus_pass_age_result do
        precalculate :qualifies_for_bus_pass_on do
          StatePensionDateQuery.bus_pass_qualification_date(dob).strftime("%-d %B %Y")
        end
      end

      outcome :near_state_pension_age

      outcome :too_young

      outcome :age_result
    end
  end
end
