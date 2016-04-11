require_relative '../test_helper'

module SmartAnswer
  class CalculationTest < ActiveSupport::TestCase
    context '#evaluate' do
      setup do
        @state = State.new(:node_key)
      end

      should 'make response available to calculation' do
        saved_response = nil
        calculation = Calculation.new(:bar) do |response|
          saved_response = response
        end
        calculation.evaluate(@state, :answer)
        assert_equal :answer, saved_response
      end

      should 'default response to nil' do
        saved_response = nil
        calculation = Calculation.new(:bar) do |response|
          saved_response = response
        end
        calculation.evaluate(@state, nil)
        assert_nil saved_response
      end

      should 'allow calculation to read state variables' do
        @state.foo = :initial_value
        saved_value = nil
        calculation = Calculation.new(:bar) do
          saved_value = foo
        end
        calculation.evaluate(@state)
        assert_equal :initial_value, saved_value
      end

      should 'allow calculation to make changes to state variables' do
        @state.foo = :initial_value
        calculation = Calculation.new(:bar) do
          self.foo = :new_value
        end
        new_state = calculation.evaluate(@state)
        assert_equal :new_value, new_state.foo
      end

      should 'assign block return value to state variable' do
        calculation = Calculation.new(:bar) do
          :new_value
        end
        new_state = calculation.evaluate(@state)
        assert_equal :new_value, new_state.bar
      end

      should 'return a new state instance' do
        calculation = Calculation.new(:bar) {}
        new_state = calculation.evaluate(@state)
        refute_same @state, new_state
      end

      should 'freeze new state' do
        calculation = Calculation.new(:bar) {}
        new_state = calculation.evaluate(@state)
        assert new_state.frozen?
      end

      should 'copy initial state variables into new state' do
        @state.foo = :initial_value
        calculation = Calculation.new(:bar) {}
        calculation.evaluate(@state)
        assert_equal :initial_value, @state.foo
      end
    end
  end
end
