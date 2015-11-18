module SmartAnswer
  class ValueSampleFlow < Flow
    def define
      name "value-sample"
      status :draft

      use_erb_templates_for_questions

      value_question :user_input? do
        save_input_as :user_input

        next_node :outcome_with_template
      end

      outcome :outcome_with_template
    end
  end
end
