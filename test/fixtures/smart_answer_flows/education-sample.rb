module SmartAnswer
  class EducationSampleFlow < Flow
    def define
      name "education-sample"

      postcode_question :user_input? do
        save_input_as :user_input

        next_node do
          outcome :outcome
        end
      end

      outcome :outcome
    end
  end
end
