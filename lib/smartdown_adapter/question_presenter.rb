module SmartdownAdapter
  class QuestionPresenter
    extend Forwardable

    def_delegators :@smartdown_question, :title, :hint, :options

    def initialize(smartdown_question, smartdown_answer)
      @smartdown_question = smartdown_question
      @smartdown_answer = smartdown_answer
    end

    def body
      @smartdown_question.body && Govspeak::Document.new(smartdown_question.body).to_html.html_safe
    end

    def post_body
      @smartdown_question.post_body && Govspeak::Document.new(smartdown_question.post_body).to_html.html_safe
    end

    def has_body?
      !!body
    end

    def has_hint?
      !!hint
    end

    def has_post_body?
      !!post_body
    end

    def error
      @smartdown_answer.error if @smartdown_answer
    end

    def partial_template_name
      case smartdown_question
      when Smartdown::Api::MultipleChoice
        "multiple_choice_question"
      when Smartdown::Api::DateQuestion
        "date_question"
      when Smartdown::Api::CountryQuestion
        "country_question"
      when Smartdown::Api::SalaryQuestion
        "salary_question"
      when Smartdown::Api::TextQuestion
        "text_question"
      end
    end

    private

    attr_reader :smartdown_question

  end
end
