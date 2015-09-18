# coding:utf-8

require_relative '../test_helper'
require 'ostruct'

module SmartAnswer
  class SalaryQuestionTest < ActiveSupport::TestCase
    def setup
      @initial_state = State.new(:example)
    end

    test "Treats input as weekly Salary by default" do
      q = Question::Salary.new(nil, :example) do
        save_input_as :my_cash
        next_node :done
      end

      new_state = q.transition(@initial_state, {amount: "123.0"})
      assert_equal Salary.new("123.0", "week"), new_state.my_cash
      assert new_state.my_cash.is_a?(Salary)
    end

    test "Records period if specified" do
      q = Question::Salary.new(nil, :example) do
        save_input_as :my_cash
        next_node :done
      end

      new_state = q.transition(@initial_state, {amount: "123.0", period: "month"})
      assert_equal Salary.new("123.0", "month"), new_state.my_cash
    end

    test "Invalid input raises InvalidResponse" do
      q = Question::Salary.new(nil, :example) do
        next_node :done
      end

      assert_raises InvalidResponse do
        new_state = q.transition(@initial_state, {amount: "bad"})
      end
    end
  end
end
