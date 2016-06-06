require_relative '../../test_helper'

module SmartAnswer::Calculators
  class EnergyGrantsCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = EnergyGrantsCalculator.new
    end

    context '#circumstances' do
      should 'return empty array by default i.e. when no responses have been set' do
        assert_equal [], @calculator.circumstances
      end
    end

    context '#benefits_claimed' do
      should 'return empty array by default i.e. when no responses have been set' do
        assert_equal [], @calculator.benefits_claimed
      end
    end
  end
end
