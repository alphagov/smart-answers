module SmartAnswer
  module FlowUnitTestHelper
    def setup_states_for_question(key, responding_with:, initial_state: {})
      @question = @flow.node(key)
      @state = SmartAnswer::State.new(@question)
      initial_state.each do |variable, value|
        @state.send("#{variable}=", value)
      end
      @new_state = @question.transition(@state, responding_with)
    end

    def assert_node_exists(key)
      assert @flow.node_exists?(key), "Node #{key} does not exist."
    end

    def assert_node_has_name(name, node, belongs_to_another_flow: false)
      assert_equal(name, node.current_node)
      assert_node_exists(name) unless belongs_to_another_flow
    end
  end
end
