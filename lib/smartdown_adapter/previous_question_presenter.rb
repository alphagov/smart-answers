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
      smartdown_previous_question.answer.humanize
    end

  private
    attr_reader :smartdown_previous_question
  end
end
