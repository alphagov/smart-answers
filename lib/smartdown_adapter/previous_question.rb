module SmartdownAdapter
  class PreviousQuestion < Node

    attr_reader :response

    def initialize(node, response)
      super(node)
      @response = response
    end

    #TODO
    def multiple_responses?
      false
    end

    def response_label(value=response)
      question_element = elements.find{ |element| element.is_a? Smartdown::Model::Element::MultipleChoice }
      question_element.choices.fetch(value)
    end

  end
end
