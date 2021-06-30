module SmartAnswer
  class SmartAnswersControllerSampleWithCheckboxQuestionFlow < Flow
    def define
      name "smart-answers-controller-sample-with-checkbox-question"

      start_page
      checkbox_question :what? do
        option :cheese
        next_node do
          outcome :done
        end
      end
      outcome :done
    end
  end
end
