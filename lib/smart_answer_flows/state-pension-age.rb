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

        permitted_next_nodes = [
          :dob_bus_pass?,
          :gender?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if response == 'bus_pass'
            :dob_bus_pass?
          else
            :gender?
          end
        end
      end

      # Q2
      multiple_choice :gender? do
        save_input_as :gender

        option :male
        option :female

        permitted_next_nodes = [
          :dob_age?
        ]
        next_node(permitted: permitted_next_nodes) do
          :dob_age?
        end
      end

      # Q3:Age
      date_question :dob_age? do
        date_of_birth_defaults

        save_input_as :dob

        calculate :calculator do
          Calculators::StatePensionAgeCalculator.new(gender: gender, dob: dob)
        end

        calculate :state_pension_date do
          calculator.state_pension_date
        end

        calculate :old_state_pension do
          calculator.state_pension_date < Date.parse('6 April 2016')
        end

        calculate :pension_credit_date do |response|
          StatePensionDateQuery.bus_pass_qualification_date(response).strftime("%-d %B %Y")
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

        validate { |response| response <= Date.today }

        permitted_next_nodes = [
          :too_young,
          :near_state_pension_age,
          :age_result
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          calc = Calculators::StatePensionAgeCalculator.new(gender: gender, dob: response)
          near_pension_date = calc.before_state_pension_date? && calc.within_four_months_one_day_from_state_pension?
          under_20_years_old = calc.under_20_years_old?

          if under_20_years_old
            :too_young
          elsif near_pension_date
            :near_state_pension_age
          else
            :age_result
          end
        end
      end

      date_question :dob_bus_pass? do
        date_of_birth_defaults
        validate { |response| response <= Date.today }

        calculate :qualifies_for_bus_pass_on do |response|
          StatePensionDateQuery.bus_pass_qualification_date(response).strftime("%-d %B %Y")
        end

        next_node(:bus_pass_age_result)
      end

      outcome :near_state_pension_age
      outcome :too_young
      outcome :age_result
      outcome :bus_pass_age_result
    end
  end
end
