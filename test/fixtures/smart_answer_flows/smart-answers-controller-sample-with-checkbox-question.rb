class SmartAnswersControllerSampleWithCheckboxQuestionFlow < SmartAnswer::Flow
  def define
    name "smart-answers-controller-sample-with-checkbox-question"
    checkbox_question :what? do
      option :cheese
      next_node do
        outcome :done
      end
    end
    outcome :done
  end
end
