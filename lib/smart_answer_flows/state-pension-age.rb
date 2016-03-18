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

        next_node do
          question :dob_age?
        end
      end

      # Q2:Age
      date_question :dob_age? do
        date_of_birth_defaults

        validate { |response| response <= Date.today }

        calculate :calculator do |response|
          Calculators::StatePensionAgeCalculator.new(dob: response)
        end

        next_node do
          if which_calculation == 'age'
            question :gender?
          else
            outcome :bus_pass_result
          end
        end
      end

      # Q3
      multiple_choice :gender? do
        option :male
        option :female

        next_node do |response|
          calculator.gender = response.to_sym

          if calculator.before_state_pension_date?
            outcome :not_yet_reached_sp_age
          else
            outcome :has_reached_sp_age
          end
        end
      end

      outcome :bus_pass_result

      outcome :not_yet_reached_sp_age

      outcome :has_reached_sp_age
    end
  end
end
