# coding:utf-8

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
  end
end
