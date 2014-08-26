module SmartdownAdapter
  class QuestionPresenter
    extend Forwardable

    def_delegators :@smartdown_question, :title, :body, :hint, :options

    def initialize(smartdown_question)
      @smartdown_question = smartdown_question
    end

    def has_body?
      !!body
    end

    def has_hint?
      !!hint
    end

    def partial_template_name
      case smartdown_question
      when Smartdown::Api::MultipleChoice
        "multiple_choice_question"
      when Smartdown::Api::DateQuestion
        "date_question"
      end
    end

    private

    attr_reader :smartdown_question

  end
end
