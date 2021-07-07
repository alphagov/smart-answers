require_relative "../test_helper"

module SmartAnswer
  class RadioQuestionTest < ActiveSupport::TestCase
    test "Can add options as keys" do
      q = Question::Radio.new(nil, :example) do
        option :yes
        option :no
      end

      assert_equal %w[yes no], q.option_keys
    end

    test "Can add options as a block" do
      q = Question::Radio.new(nil, :example) do
        options { %i[x y] }
      end

      assert_equal %i[x y], q.options_block.call
    end

    test "Can determine next state on provision of an input" do
      q = Question::Radio.new(nil, :example) do
        option :yes
        option :no
        next_node { outcome :fred }
      end

      current_state = State.new(:example)
      new_state = q.transition(current_state, :yes)
      assert_equal :fred, new_state.current_node_name
      assert new_state.frozen?
    end

    test "Next node default can be given by block" do
      q = Question::Radio.new(nil, :example) do
        option :yes
        option :no
        next_node { outcome :baz }
      end

      new_state = q.transition(State.new(:example), :no)
      assert_equal :baz, new_state.current_node_name
    end

    test "Error raised on illegal input" do
      q = Question::Radio.new(nil, :example) do
        option :yes
      end

      current_state = State.new(:example)
      assert_raises SmartAnswer::InvalidResponse do
        q.transition(current_state, :invalid)
      end
    end
  end
end
