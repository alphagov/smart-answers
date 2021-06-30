module SmartAnswer
  class SmartAnswersControllerSampleWithDateQuestionFlow < Flow
    def define
      name "smart-answers-controller-sample-with-date-question"

      start_page
      date_question :when? do
        next_node do
          outcome :done
        end
      end
      outcome :done
    end
  end
end
