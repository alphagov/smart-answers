require_relative '../test_helper'

module SmartAnswer
  class BlockTest < ActiveSupport::TestCase
    context '#evaluate' do
      setup do
        @state = State.new(:node_key)
      end

      should 'make response available to block' do
        saved_response = nil
        block = Block.new do |response|
          saved_response = response
        end
        block.evaluate(@state, :answer)
        assert_equal :answer, saved_response
      end

      should 'default response to nil' do
        saved_response = nil
        block = Block.new do |response|
          saved_response = response
        end
        block.evaluate(@state, nil)
        assert_nil saved_response
      end

      should 'allow block to read state variables' do
        @state.foo = :initial_value
        saved_value = nil
        block = Block.new do
          saved_value = foo
        end
        block.evaluate(@state)
        assert_equal :initial_value, saved_value
      end

      should 'allow block to make changes to state variables' do
        @state.foo = :initial_value
        block = Block.new do
          self.foo = :new_value
        end
        new_state = block.evaluate(@state)
        assert_equal :new_value, new_state.foo
      end

      should 'return a new state instance' do
        block = Block.new {}
        new_state = block.evaluate(@state)
        refute_same @state, new_state
      end

      should 'freeze new state' do
        block = Block.new {}
        new_state = block.evaluate(@state)
        assert new_state.frozen?
      end

      should 'copy initial state variables into new state' do
        @state.foo = :initial_value
        block = Block.new {}
        block.evaluate(@state)
        assert_equal :initial_value, @state.foo
      end
    end
  end
end
