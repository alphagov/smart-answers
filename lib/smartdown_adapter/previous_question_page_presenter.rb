module SmartdownAdapter
  class PreviousQuestionPagePresenter
    def initialize(flow, smartdown_previous_question_pages)
      @flow = flow
      @smartdown_previous_question_pages = smartdown_previous_question_pages[0...-1]
      @smartdown_previous_question_page = smartdown_previous_question_pages.last
    end

    def questions
      @smartdown_previous_question_page.questions.map do |smartdown_previous_question|
        PreviousQuestionPresenter.new(@flow, @smartdown_previous_question_pages, smartdown_previous_question)
      end
    end
  end
end
