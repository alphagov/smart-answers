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
      
      context "populate_commodity_code_matrix method" do
        should "build a 2D array of commodity code suffixes" do
#          puts @matrix_data[:commodity_code_matrix].lines
#          assert_equal "030", @calculator.commodity_code_matrix[1][10]
#          # assert_equal "000", @calculator.commodity_code_matrix[0][20]
        end
      end
    end
  end
end
