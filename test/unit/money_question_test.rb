
require_relative '../test_helper'
require 'ostruct'

module SmartAnswer
  class MoneyQuestionTest < ActiveSupport::TestCase
    def setup
      @initial_state = State.new(:example)
    end

    test "Value saved as a Money instance" do
      q = Question::Money.new(nil, :example) do
        save_input_as :my_cash
        next_node :done
      end

      new_state = q.transition(@initial_state, "123.0")
      assert_equal Money.new("123.0"), new_state.my_cash
      assert new_state.my_cash.is_a?(Money)
    end

    test "Invalid input raises InvalidResponse" do
      q = Question::Money.new(nil, :example) do
        next_node :done
      end

      assert_raises InvalidResponse do
        new_state = q.transition(@initial_state, "bad")
      end
    end
  end
end
