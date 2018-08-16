require_relative '../test_helper'

module SmartAnswer
  class RoundingHelperTest < ActiveSupport::TestCase
    include RoundingHelper

    context '#round_up_to_the_next_pence' do
      should 'not round up 100' do
        assert_equal 100, round_up_to_the_next_pence(100)
      end

      should 'not round up 100.01' do
        assert_equal 100.01, round_up_to_the_next_pence(100.01)
      end

      should 'not round up 100.5' do
        assert_equal 100.5, round_up_to_the_next_pence(100.5)
      end

      should 'not round up 100.0002' do
        assert_equal 100.0, round_up_to_the_next_pence(100.0002)
      end

      should 'round up 100.011' do
        assert_equal 100.02, round_up_to_the_next_pence(100.011)
      end
    end
  end
end
