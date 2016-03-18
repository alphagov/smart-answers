module SmartAnswer
  class SmartAnswersControllerSampleWithMoneyQuestionFlow < Flow
    def define
      name "smart-answers-controller-sample-with-money-question"
      money_question :how_much? do
        next_node do
          question :money_question_with_suffix_label?
        end
      end
      money_question :money_question_with_suffix_label? do
        next_node do
          outcome :done
        end
      end
      outcome :done
    end
  end
end
