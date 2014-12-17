module SmartdownAdapter
  class QuestionPagePresenter
    extend Forwardable

    def_delegators :@smartdown_question_page, :title

    def initialize(smartdown_question_page, smartdown_answers)
      @smartdown_question_page = smartdown_question_page
      @smartdown_answers = smartdown_answers
    end

    def questions
      @smartdown_question_page.questions.map do |smartdown_question|
        smartdown_answer = @smartdown_answers.find { |smartdown_answer| smartdown_answer.question.name == smartdown_question.name }
        case smartdown_question
        when Smartdown::Api::DateQuestion
          SmartdownAdapter::DateQuestionPresenter.new(smartdown_question, smartdown_answer)
        when Smartdown::Api::SalaryQuestion
          SmartdownAdapter::SalaryQuestionPresenter.new(smartdown_question, smartdown_answer)
        when Smartdown::Api::TextQuestion
          SmartdownAdapter::TextQuestionPresenter.new(smartdown_question, smartdown_answer)
        when Smartdown::Api::PostcodeQuestion
          SmartdownAdapter::TextQuestionPresenter.new(smartdown_question, smartdown_answer)
        else
          SmartdownAdapter::QuestionPresenter.new(smartdown_question, smartdown_answer)
        end
      end
    end
  end
end
