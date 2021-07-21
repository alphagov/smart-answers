class StatePensionAgeFlow < SmartAnswer::Flow
  def define
    content_id "5491c439-1c83-4044-80d3-32cc3613b739"
    name "state-pension-age"
    status :published

    # Q1
    radio :which_calculation? do
      option :age
      option :bus_pass

      on_response do |response|
        self.which_calculation = response
      end

      next_node do
        question :dob_age?
      end
    end

    # Q2:Age
    date_question :dob_age? do
      date_of_birth_defaults

      validate { |response| response <= Time.zone.today }

      on_response do |response|
        self.calculator = SmartAnswer::Calculators::StatePensionAgeCalculator.new(dob: response)
      end

      next_node do
        if which_calculation == "age"
          if calculator.pension_age_based_on_gender?
            question :gender?
          elsif calculator.before_state_pension_date?
            outcome :not_yet_reached_sp_age
          else
            outcome :has_reached_sp_age
          end
        else
          outcome :bus_pass_result
        end
      end
    end

    # Q3
    radio :gender? do
      option :male
      option :female
      option :prefer_not_to_say

      next_node do |response|
        calculator.gender = response.to_sym

        if calculator.non_binary?
          outcome :has_reached_sp_age_non_binary
        elsif calculator.before_state_pension_date?
          outcome :not_yet_reached_sp_age
        else
          outcome :has_reached_sp_age
        end
      end
    end

    outcome :bus_pass_result

    outcome :not_yet_reached_sp_age

    outcome :has_reached_sp_age

    outcome :has_reached_sp_age_non_binary
  end
end
