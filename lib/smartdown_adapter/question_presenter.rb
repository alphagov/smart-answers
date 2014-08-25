module SmartdownAdapter
  class QuestionPresenter
    extend Forwardable

    def_delegators :@smartdown_question, :title, :body, :hint, :options

    def initialize(flow, previous_question_pages, smartdown_question_page, smartdown_question)
      @flow = flow
      @all_question_pages = previous_question_pages + [smartdown_question_page]
      @smartdown_question = smartdown_question
    end

    def number
      if multiple_questions_per_page
        index_of_current_question_in_page + 1
      else
        index_of_current_question_in_flow + 1
      end
    end

    def has_body?
      !!body
    end

    def has_hint?
      !!hint
    end

    def partial_template_name
      case @smartdown_question
      when Smartdown::Api::MultipleChoice
        "multiple_choice_question"
      end
    end

    private

    attr_reader :flow, :all_question_pages, :smartdown_question

    def index_of_current_question_in_flow
      all_question_pages.map(&:questions).flatten.each_with_index do |question, index|
        return index if question.title == smartdown_question.title
      end
    end

    def index_of_current_question_in_page
      all_question_pages.each do |question_page|
        question_page.questions.each_with_index do |question, index|
          return index if question.title == smartdown_question.title
        end
      end
    end

    def multiple_questions_per_page
      flow.question_pages.each do |question_page|
        return true if question_page.questions.count > 1
      end
      false
    end
  end
end
