module SmartAnswer
  class PipCheckerFlow < Flow
    def define
      name 'pip-checker'
      status :published
      satisfies_need "100389"

      ## Q1
      multiple_choice :are_you_getting_dla? do
        option yes: :what_is_your_dob?
        option no: :what_is_your_dob?

        # Used in later questions
        calculate :calculator do
          Calculators::PIPDates.new
        end

        calculate :getting_dla do |response|
          response == 'yes'
        end
      end

      ## Q2
      date_question :what_is_your_dob? do
        date_of_birth_defaults

        next_node do |response|
          calculator.dob = response
          if getting_dla
            if calculator.in_group_65?
              :result_6
            elsif calculator.turning_16_before_oct_2013?
              :result_7
            elsif calculator.in_middle_group?
              :result_7
            else
              :result_5
            end
          else
            if calculator.is_65_or_over?
              :result_2
            elsif calculator.is_16_to_64?
              :result_3
            else
              :result_1
            end
          end
        end
      end

      outcome :result_1
      outcome :result_2
      outcome :result_3
      outcome :result_4
      outcome :result_5
      outcome :result_6
      outcome :result_7
    end
  end
end
