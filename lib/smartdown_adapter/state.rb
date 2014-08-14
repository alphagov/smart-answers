module SmartdownAdapter
  class State

    attr_reader :responses, :current_node

    def initialize(current_node, previous_questionpage_smartdown_nodes, responses)
      @current_node = current_node
      @previous_question_page_nodes = previous_questionpage_smartdown_nodes
      @responses = responses
    end

    def inspect
      "#<SmartdownTransform::State( state: #{@state.get('responses')}, current_node: #{current_node} )>"
    end

    def started?
      !current_node.is_a? Coversheet
    end

    def finished?
      current_node.is_a? Outcome
    end

    def previous_questions
      response_index = 0
      previous_question_nodes.map.each_with_index do |previous_questions, node_index|
        previous_questions.map.each_with_index do |previous_question, index|
          previous_question = PreviousQuestion.new(
              previous_question_title_nodes[node_index][index].content,
              previous_question,
              responses[response_index],
              index == 0
          )
          response_index+=1
          previous_question
        end
      end.flatten
    end

    def previous_question_nodes
      @previous_question_page_nodes.map(&:questions)
    end

    def previous_question_title_nodes
      @previous_question_page_nodes.map(&:question_titles)
    end

    def current_question_number
      responses.count + 1
    end

  private

    attr_reader :smartdown_state, :previous_question_page_nodes

  end
end
