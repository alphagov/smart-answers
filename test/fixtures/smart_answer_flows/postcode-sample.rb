module SmartAnswer
  class PostcodeSampleFlow < Flow
    def define
      name "postcode-sample"
      status :draft

      use_erb_templates_for_questions

      postcode_question :user_input? do
        save_input_as :user_input

        next_node :outcome
      end

      outcome :outcome
    end
  end
end
