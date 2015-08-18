module SmartAnswer
  class ValueSampleFlow < Flow
    def define
      name "value-sample"
      status :draft

      value_question :user_input? do
        save_input_as :user_input

        next_node :outcome_with_template
      end

      use_outcome_templates

      outcome :outcome_with_template
    end
  end
end
