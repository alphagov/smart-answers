module SmartAnswer
  class ValueSampleFlow < Flow
    def define
      name "value-sample"
      status :draft

      value_question :user_input? do
        on_response do |response|
          self.user_input = response
        end

        next_node do
          outcome :outcome_with_template
        end
      end

      outcome :outcome_with_template
    end
  end
end
