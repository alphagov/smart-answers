module SmartdownAdapter
  class QuestionPagePresenter
    extend Forwardable

    def_delegators :@smartdown_question_page, :title

    def initialize(smartdown_question_page)
      @smartdown_question_page = smartdown_question_page
    end

    def questions
      @smartdown_question_page.questions.map do |smartdown_question|
        case smartdown_question
        when Smartdown::Api::DateQuestion
          SmartdownAdapter::DateQuestionPresenter.new(smartdown_question)
        when Smartdown::Api::SalaryQuestion
          SmartdownAdapter::SalaryQuestionPresenter.new(smartdown_question)
        else
          SmartdownAdapter::QuestionPresenter.new(smartdown_question)
        end
      end
    end
  end
end
