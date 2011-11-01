# coding:utf-8

require 'ostruct'
require_relative '../test_helper'

class QuestionBaseTest < ActiveSupport::TestCase
  def setup
    @initial_state = OpenStruct.new(something_else: "Carried over").freeze
  end
  
  test "State is carried over on a state transition" do
    q = SmartAnswer::Question::Base.new(:example)
    new_state = q.transition(@initial_state, :yes)
    assert_equal "Carried over", new_state.something_else
  end
  
  test "Next node is taken from next_node_for method" do
    q = SmartAnswer::Question::Base.new(:example)
    q.stubs(:next_node_for).returns(:done)
    new_state = q.transition(@initial_state, :anything)
    assert_equal :done, new_state.current_node
  end

  test "Can define next_node by passing a value" do
    q = SmartAnswer::Question::Base.new(:example)
    q.next_node :done
    new_state = q.transition(@initial_state, :anything)
    assert_equal :done, new_state.current_node
  end

  test "Can define next_node by giving a block" do
    q = SmartAnswer::Question::Base.new(:example)
    q.next_node { :done_done }
    new_state = q.transition(@initial_state, :anything)
    assert_equal :done_done, new_state.current_node
  end
  
  test "Input can be saved into the state" do
    q = SmartAnswer::Question::Base.new(:favourite_colour?) do
      save_input_as :colour_preference
    end
    new_state = q.transition(@initial_state, :red)
    assert_equal :red, new_state.colour_preference
  end
  
  test "Input is saved into responses as well" do
    q = SmartAnswer::Question::Base.new(:favourite_colour?)
    new_state = q.transition(@initial_state, :red)
    assert_equal [:red], new_state.responses
  end
  
  test "Can calculate other variables based input" do
    q = SmartAnswer::Question::Base.new(:favourite_colour?) do
      save_input_as :colour_preference
      calculate :complementary_colour do
        colour_preference == :red ? :green : :red
      end
    end
    new_state = q.transition(@initial_state, :red)
    assert_equal :green, new_state.complementary_colour
    assert new_state.frozen?
  end
end