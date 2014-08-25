module SmartdownAdapter
  class PreviousQuestionPresenter
    extend Forwardable

    def_delegators :@smartdown_previous_question, :title

    def initialize(flow, smartdown_previous_question_pages, smartdown_previous_question)
      @flow = flow
      @smartdown_previous_question_pages = smartdown_previous_question_pages
      @smartdown_previous_question = smartdown_previous_question
    end

    def number(page_index, index)
      if multiple_questions_per_page
        number_previous_questions + index
      else
        page_index
      end
    end

    #TODO
    def multiple_responses?
      false
    end

    def response_label(response_key)
      case smartdown_previous_question
        when Smartdown::Api::PreviousQuestion
          smartdown_previous_question.options.find{|option| option.value == response_key}.label
      end
    end

  private
    attr_reader :flow, :smartdown_previous_question, :smartdown_previous_question_pages

    def multiple_questions_per_page
      flow.question_pages.each do |question_page|
        return true if question_page.questions.count > 1
      end
      false
    end

    def number_previous_questions
      smartdown_previous_question_pages.map(&:questions).count
    end
  end
end
