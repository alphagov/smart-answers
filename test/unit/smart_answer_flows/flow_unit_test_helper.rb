module SmartAnswer
  module FlowUnitTestHelper
    def setup_states_for_question(key, responding_with:, initial_state: {})
      @question = @flow.node(key)
      @state = SmartAnswer::State.new(@question)
      initial_state.each do |variable, value|
        @state.send("#{variable}=", value)
      end
      @precalculated_state = @question.evaluate_precalculations(@state)
      @new_state = @question.transition(@precalculated_state, responding_with)
    end

    def assert_node_exists(key)
      assert @flow.node_exists?(key), "Node #{key} does not exist."
    end
  end
end
