# coding:utf-8

require_relative '../test_helper'

module SmartAnswer
  class MultipleChoiceQuestionTest < ActiveSupport::TestCase
  
    test "Can list options" do
      q = Question::MultipleChoice.new(:example) do
        option :yes => :fred
        option :no => :bob
      end
    
      assert_equal ["yes", "no"], q.options 
    end
  
    test "Can determine next state on provision of an input" do
      q = Question::MultipleChoice.new(:example) do
        option :yes => :fred
        option :no => :bob
      end

      current_state = State.new(:example)
      new_state = q.transition(current_state, :yes)
      assert_equal :fred, new_state.current_node
      assert new_state.frozen?
    end

    test "Next node can be overridden by block" do
      q = Question::MultipleChoice.new(:example) do
        option :yes => :fred
        next_node { :baz }
      end

      new_state = q.transition(State.new(:example), :yes)
      assert_equal :baz, new_state.current_node
    end
    
    test "Error raised on illegal input" do
      q = Question::MultipleChoice.new(:example) do
        option :yes => :fred
      end

      current_state = State.new(:example)
      assert_raises SmartAnswer::InvalidResponse do
        new_state = q.transition(current_state, :invalid)
      end
    end
    
  end
end