require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class OverseasPassportsCalculatorTest < ActiveSupport::TestCase
      context '#current_location' do
        setup do
          @calculator = OverseasPassportsCalculator.new
        end

        should 'allow current_location to be written and read' do
          @calculator.current_location = 'springfield'
          assert_equal @calculator.current_location, 'springfield'
        end
      end
    end
  end
end
