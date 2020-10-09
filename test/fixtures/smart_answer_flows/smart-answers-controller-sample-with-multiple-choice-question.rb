module SmartAnswer
  class SmartAnswersControllerSampleWithMultipleChoiceQuestionFlow < Flow
    def define
      name "smart-answers-controller-sample-with-multiple-choice-question"
      radio :what? do
        option :cheese
        next_node do
          outcome :done
        end
      end
      outcome :done
    end
  end
end
