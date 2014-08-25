module SmartdownAdapter
  class QuestionPagePresenter

    def initialize(flow, previous_question_pages, smartdown_question_page)
      @flow = flow
      @previous_question_pages = previous_question_pages
      @smartdown_question_page = smartdown_question_page
    end

    def questions
      @smartdown_question_page.questions.map do |smartdown_question|
        QuestionPresenter.new(@flow, @previous_question_pages, @smartdown_question_page, smartdown_question)
      end
    end
  end
end
