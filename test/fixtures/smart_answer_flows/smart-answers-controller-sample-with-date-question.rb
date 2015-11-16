module SmartAnswer
  class SmartAnswersControllerSampleWithDateQuestionFlow < Flow
    def define
      name "smart-answers-controller-sample-with-date-question"
      use_erb_templates_for_questions
      date_question :when? do
        next_node :done
      end
      outcome :done
    end
  end
end
