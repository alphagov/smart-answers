module SmartAnswer
  class SmartAnswersControllerSampleWithSalaryQuestionFlow < Flow
    def define
      name "smart-answers-controller-sample-with-salary-question"
      use_erb_templates_for_questions
      salary_question(:how_much?) { next_node :salary_question_with_error_message? }
      salary_question(:salary_question_with_error_message?) { next_node :done }
      outcome :done
    end
  end
end
