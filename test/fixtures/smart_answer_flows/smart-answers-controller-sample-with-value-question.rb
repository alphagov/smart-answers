module SmartAnswer
  class SmartAnswersControllerSampleWithValueQuestionFlow < Flow
    def define
      name "smart-answers-controller-sample-with-value-question"
      value_question :how_many_green_bottles? do
        next_node :value_question_with_label?
      end
      value_question :value_question_with_label? do
        next_node :value_question_with_suffix_label?
      end
      value_question :value_question_with_suffix_label? do
        next_node :done
      end

      outcome :done
    end
  end
end
