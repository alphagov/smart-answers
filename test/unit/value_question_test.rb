# coding:utf-8

require_relative '../test_helper'
require 'ostruct'

module SmartAnswer
  class ValueQuestionTest < ActiveSupport::TestCase
    def setup
      @initial_state = State.new(:example)
    end

    test "Value is saved as a String by default" do
      q = Question::Value.new(:example) do
        save_input_as :myval
        next_node :done
      end

      new_state = q.transition(@initial_state, "123")
      assert_equal '123', new_state.myval
    end

    test "Value is saved as an Integer specified by parse option" do
      q = Question::Value.new(:example, parse: Integer) do
        save_input_as :myval
        next_node :done
      end

      new_state = q.transition(@initial_state, "123")
      assert_equal 123, new_state.myval
    end

    test "Value is saved as a String if parse option specifies unknown type" do
      q = Question::Value.new(:example, parse: Float) do
        save_input_as :myval
        next_node :done
      end

      new_state = q.transition(@initial_state, "123")
      assert_equal '123', new_state.myval
    end
  end
end
