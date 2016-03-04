module SmartAnswer
  class SmartAnswersControllerSampleWithMultipleChoiceQuestionFlow < Flow
    def define
      name "smart-answers-controller-sample-with-multiple-choice-question"
      multiple_choice :what? do
        option :cheese
        next_node :done
      end
      outcome :done
    end
  end
end
