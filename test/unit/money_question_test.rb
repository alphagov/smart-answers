# coding:utf-8

require_relative '../test_helper'
require 'ostruct'

module SmartAnswer
  class MoneyQuestionTest < ActiveSupport::TestCase
    def setup
      @initial_state = State.new(:example)
    end
  
    test "Value saved as a Money instance" do
      q = Question::Money.new(:example) do
        save_input_as :my_cash
        next_node :done
      end
    
      new_state = q.transition(@initial_state, "123")
      assert_equal Money.new("123"), new_state.my_cash
      assert new_state.my_cash.is_a?(Money)
    end
  end
end