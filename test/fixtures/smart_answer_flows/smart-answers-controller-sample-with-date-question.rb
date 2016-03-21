module SmartAnswer
  class SmartAnswersControllerSampleWithDateQuestionFlow < Flow
    def define
      name "smart-answers-controller-sample-with-date-question"

      date_question :when? do
        next_node do
          outcome :done
        end
      end
      outcome :done
    end
  end
end
