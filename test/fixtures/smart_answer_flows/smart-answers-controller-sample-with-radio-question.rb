class SmartAnswersControllerSampleWithRadioQuestionFlow < SmartAnswer::Flow
  def define
    name "smart-answers-controller-sample-with-radio-question"
    radio :what? do
      option :cheese
      next_node do
        outcome :done
      end
    end
    outcome :done
  end
end
