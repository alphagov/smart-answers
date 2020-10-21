module SmartAnswer
  class EducationSampleFlow < Flow
    def define
      name "education-sample"

      postcode_question :user_input? do
        on_response do |response|
          self.user_input = response
        end

        next_node do
          outcome :outcome
        end
      end

      outcome :outcome
    end
  end
end
