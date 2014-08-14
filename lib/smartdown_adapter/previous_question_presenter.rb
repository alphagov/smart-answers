module SmartdownAdapter
  class PreviousQuestionPresenter
    extend Forwardable

    def_delegators :@smartdown_previous_question, :title

    def initialize(smartdown_previous_question)
      @smartdown_previous_question = smartdown_previous_question
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
    attr_reader :smartdown_previous_question

  end
end
