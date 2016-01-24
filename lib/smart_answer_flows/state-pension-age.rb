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

        permitted_next_nodes = [
          :bus_pass_result,
          :gender?
        ]

        calculate :calculator do |response|
          Calculators::StatePensionAgeCalculator.new(dob: response)
        end

        next_node(permitted: permitted_next_nodes) do
          if which_calculation == 'age'
            :gender?
          else
            :bus_pass_result
          end
        end
      end

      # Q3
      multiple_choice :gender? do
        option :male
        option :female

        permitted_next_nodes = [
          :not_yet_reached_sp_age,
          :has_reached_sp_age
        ]

        next_node(permitted: permitted_next_nodes) do |response|
          calculator.gender = response.to_sym

          if calculator.before_state_pension_date?
            :not_yet_reached_sp_age
          else
            :has_reached_sp_age
          end
        end
      end

      outcome :bus_pass_result

      outcome :not_yet_reached_sp_age

      outcome :has_reached_sp_age
    end
  end
end
