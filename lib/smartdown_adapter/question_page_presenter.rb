module SmartdownAdapter
  class QuestionPagePresenter
    extend Forwardable

    def_delegators :@smartdown_question_page, :title

    def initialize(smartdown_question_page)
      @smartdown_question_page = smartdown_question_page
    end

    def questions
      @smartdown_question_page.questions.map do |smartdown_question|
        QuestionPresenter.new(smartdown_question)
      end
    end
  end
end
