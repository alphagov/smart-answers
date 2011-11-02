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
  end
end