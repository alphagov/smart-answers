module Smartdown
  class State

    attr_reader :responses

    def initialize(current_node, previous_question_nodes, responses)
      @current_node = current_node
      @previous_question_nodes = previous_question_nodes
      @responses = responses
    end

    def inspect
      "#<SmartdownTransform::State( state: #{@state.get('responses')}, current_node: #{current_node_transformed} )>"
    end

    def current_elements
      current_node.elements
    end

    def started?
      !current_node_transformed.is_a? Coversheet
    end

    def finished?
      current_node_transformed.is_a? Outcome
    end

    def current_node_transformed
      if current_elements.any?{|element| element.is_a? Smartdown::Model::Element::StartButton}
        Coversheet.new(current_node)
      elsif current_elements.any?{|element| element.is_a? Smartdown::Model::NextNodeRules}
        if current_elements.any?{|element| element.is_a? Smartdown::Model::Element::MultipleChoice}
          MultipleChoice.new(current_node)
        else
          #TODO: support other types of questions
        end
      else
        Outcome.new(current_node)
      end
    end

    def previous_questions
      responses.each_with_index.map do |response, index|
        PreviousQuestion.new(
            previous_question_nodes[index],
            responses[index]
        )
      end
    end

    def current_question_number
      responses.count + 1
    end

  private

    attr_reader :smartdown_state, :current_node, :previous_question_nodes

  end
end
