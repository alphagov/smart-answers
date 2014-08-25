module SmartdownAdapter
  class QuestionPagePresenter

    def initialize(flow, smartdown_question_page)
      @flow = flow
      @smartdown_question_page = smartdown_question_page
    end

    def questions
      @smartdown_question_page.questions.map do |smartdown_question|
        QuestionPresenter.new(@flow, smartdown_question)
      end
    end
  end
end
