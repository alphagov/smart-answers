require_relative "../test_helper"

module SmartAnswer
  class StateTest < ActiveSupport::TestCase
    context "transitioning to a new state" do
      should "not modify the existing state" do
        old_state = State.new(:state2)
        old_state.accepted_responses = { state1: "answer" }
        old_state.freeze

        state = old_state.transition_to(:state3, "fooey")

        assert_equal ({ state1: "answer" }), old_state.accepted_responses
        assert_equal ({ state1: "answer", state2: "fooey" }), state.accepted_responses
      end
    end

    should "return the default values of attributes set in the constructor" do
      state = State.new(:start_node)
      assert_equal :start_node, state.current_node
      assert_equal ({}), state.accepted_responses
      assert_equal ({}), state.forwarding_responses
      assert_nil state.current_response
      assert_nil state.error
    end

    should "raise a NoMethodError exception when trying to read a value that hasn't previously been set" do
      state = State.new(:start_node)
      assert_raise(NoMethodError) do
        state.undefined_attribute
      end
    end

    should "return the value of an attribute that's previously been set" do
      state = State.new(:start_node)
      state.new_attribute = "new-attribute-value"
      assert_equal "new-attribute-value", state.new_attribute
    end

    should "respond_to reader method for attribute set in constructor" do
      state = State.new(:start_node)
      assert state.respond_to?(:current_node)
    end

    should "respond_to reader method for attribute that has previously been set" do
      state = State.new(:start_node)
      state.new_attribute = "new-attribute-value"
      assert state.respond_to?(:new_attribute)
    end

    should "not respond_to reader method for attribute that hasn't previously been set" do
      state = State.new(:start_node)
      assert_not state.respond_to?(:new_attribute)
    end

    should "respond_to writer method for attribute set in constructor" do
      state = State.new(:start_node)
      assert state.respond_to?(:current_node=)
    end

    should "respond_to writer method for attribute that has previously been set" do
      state = State.new(:start_node)
      state.new_attribute = "new-attribute-value"
      assert state.respond_to?(:new_attribute=)
    end

    should "respond_to writer method for attribute that hasn't previously been set" do
      state = State.new(:start_node)
      assert state.respond_to?(:new_attribute=)
    end
  end
end
