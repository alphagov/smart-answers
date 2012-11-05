# coding:utf-8

require_relative '../test_helper'

module SmartAnswer
  class OptionalDateQuestionTest < ActiveSupport::TestCase
    def setup
      @initial_state = State.new(:example)
    end

    test "Accepts a valid date or 'no'" do
      q = Question::OptionalDate.new(:example) do
        next_node :success
      end

      assert_equal :success, q.transition(@initial_state, Date.today).current_node
      assert_equal :success, q.transition(@initial_state, "12-02-2012").current_node
      assert_equal :success, q.transition(@initial_state, "no").current_node

      assert_raises SmartAnswer::InvalidResponse do
        new_state = q.transition(@initial_state, "not a valid date")
      end
    end
  end
end
