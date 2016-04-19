
require_relative '../test_helper'

module SmartAnswer
  class StateTest < ActiveSupport::TestCase
    context "transitioning to a new state" do
      should "not modify the existing state" do
        old_state = State.new(:state2)
        old_state.path << :state1
        old_state.responses << 'yes'
        old_state.freeze

        new_state = old_state.transition_to(:state3, 'fooey')

        assert_equal ['yes'], old_state.responses
        assert_equal [:state1], old_state.path
      end
    end

    should "return the default values of attributes set in the constructor" do
      state = State.new(:start_node)
      assert_equal :start_node, state.current_node
      assert_equal [], state.path
      assert_equal [], state.responses
      assert_nil state.response
      assert_nil state.error
    end

    should "return the modified values of attributes originally set in the constructor" do
      state = State.new(:start_node)

      state.current_node = :node1
      assert_equal :node1, state.current_node

      state.path << :node1
      assert_equal [:node1], state.path

      state.responses << 'no'
      assert_equal ['no'], state.responses

      state.response = 'no'
      assert_equal 'no', state.response

      state.error = :error1
      assert_equal :error1, state.error
    end

    should "raise a NoMethodError exception when trying to read a value that hasn't previously been set" do
      state = State.new(:start_node)
      assert_raise(NoMethodError) do
        state.undefined_attribute
      end
    end

    should "return the value of an attribute that's previously been set" do
      state = State.new(:start_node)
      state.new_attribute = 'new-attribute-value'
      assert_equal 'new-attribute-value', state.new_attribute
    end

    should "respond_to reader method for attribute set in constructor" do
      state = State.new(:start_node)
      assert state.respond_to?(:current_node)
    end

    should "respond_to reader method for attribute that has previously been set" do
      state = State.new(:start_node)
      state.new_attribute = 'new-attribute-value'
      assert state.respond_to?(:new_attribute)
    end

    should "not respond_to reader method for attribute that hasn't previously been set" do
      state = State.new(:start_node)
      refute state.respond_to?(:new_attribute)
    end

    should "respond_to writer method for attribute set in constructor" do
      state = State.new(:start_node)
      assert state.respond_to?(:current_node=)
    end

    should "respond_to writer method for attribute that has previously been set" do
      state = State.new(:start_node)
      state.new_attribute = 'new-attribute-value'
      assert state.respond_to?(:new_attribute=)
    end

    should "respond_to writer method for attribute that hasn't previously been set" do
      state = State.new(:start_node)
      assert state.respond_to?(:new_attribute=)
    end
  end
end
