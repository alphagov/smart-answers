# coding:utf-8

require_relative '../test_helper'
require 'ostruct'

module SmartAnswer
  class ValueQuestionTest < ActiveSupport::TestCase
    def setup
      @initial_state = State.new(:example)
    end
  
    test "Value can be saved" do
      q = Question::Value.new(:example) do
        save_input_as :myval
        next_node :done
      end
    
      new_state = q.transition(@initial_state, "123")
      assert_equal '123', new_state.myval
    end
  end
end