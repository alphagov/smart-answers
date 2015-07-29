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
        should "build a 2D (32x19) array of commodity code suffixes" do
          assert_equal 32, @calculator.commodity_code_matrix.size
          assert_equal 19, @calculator.commodity_code_matrix.first.size
          assert_equal "180", @calculator.commodity_code_matrix[10][0]
          assert_equal "030", @calculator.commodity_code_matrix[1][10]
          assert_equal "X", @calculator.commodity_code_matrix[4][9]
          assert_equal "090", @calculator.commodity_code_matrix[4][10]
        end
      end

      context "commodity_code method" do
        should "lookup and return commodity code 042" do
          options = {
            starch_glucose_weight: 0,
            sucrose_weight: 30,
            milk_fat_weight: 0,
            milk_protein_weight: 6
          }
          calculator = CommodityCodeCalculator.new(options)
          assert_equal "042", calculator.commodity_code
        end

        should "lookup and return commodity code 367" do
          options = {
            starch_glucose_weight: 5,
            sucrose_weight: 30,
            milk_fat_weight: 6,
            milk_protein_weight: 15
          }
          calculator = CommodityCodeCalculator.new(options)
          assert_equal "367", calculator.commodity_code
        end

        should "lookup and return commodity code X" do
          options = {
            starch_glucose_weight: 5,
            sucrose_weight: 30,
            milk_fat_weight: 70,
            milk_protein_weight: 0
          }
          calculator = CommodityCodeCalculator.new(options)
          assert_equal "X", calculator.commodity_code
        end
      end

      context '#has_commodity_code? method' do
        should 'return true unless the commodity code is X' do
          calculator = CommodityCodeCalculator.new({})
          calculator.stubs(:commodity_code).returns('commodity-code')
          assert_equal true, calculator.has_commodity_code?
        end

        should 'return false if the commodity code is X' do
          calculator = CommodityCodeCalculator.new({})
          calculator.stubs(:commodity_code).returns('X')
          assert_equal false, calculator.has_commodity_code?
        end
      end
    end
  end
end
