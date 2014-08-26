module SmartdownAdapter
  class QuestionPagePresenter

    def initialize(smartdown_question_page)
      @smartdown_question_page = smartdown_question_page
    end

    def questions
      @smartdown_question_page.questions.map do |smartdown_question|
        case smartdown_question
        when Smartdown::Api::DateQuestion
          DateQuestionPresenter.new(smartdown_question)
        else
          QuestionPresenter.new(smartdown_question)
        end
      end
    end
  end
end
