module SmartdownAdapter
  class PreviousQuestion

    attr_reader :response, :title

    def initialize(title, question_element, response, modifiable)
      @title = title
      @question_element = question_element
      @response = response
      @modifiable = modifiable
    end

    def modifiable?
      @modifiable
    end

    #TODO
    def multiple_responses?
      false
    end

    def response_label(value=response)
      @question_element.choices.fetch(value)
    end

  end
end
