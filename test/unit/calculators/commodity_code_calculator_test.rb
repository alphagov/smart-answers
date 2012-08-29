require_relative '../../test_helper'

module SmartAnswer::Calculators
  class CommodityCodeCalculatorTest < ActiveSupport::TestCase
    context CommodityCodeCalculator do
      setup do
        @calculator = CommodityCodeCalculator.new({})
      end
      
      should "load matrix data from file" do
        assert_equal Hash, @calculator.matrix_data[:starch_glucose_to_sucrose].class
        assert_equal 2, @calculator.matrix_data[:starch_glucose_to_sucrose][0][30]
      end
    end
  end
end
