require_relative '../../test_helper'

module SmartAnswer::Calculators
  class CommodityCodeCalculatorTest < ActiveSupport::TestCase
    context CommodityCodeCalculator do
      setup do
        @calculator = CommodityCodeCalculator.new({})
      end
      
      should "load matrix data from file" do
        assert_equal Array, @calculator.matrix_data[:starch_glucose_ranges].class
        assert_equal 0, @calculator.matrix_data[:starch_glucose_ranges].first[:min]
      end
      
      context "starch_glucose_ranges method" do
        should "provide an array of hashes containing minimum and maximum values" do
          assert_equal 75, @calculator.starch_glucose_ranges.last[:min]
        end
      end
      context "sucrose_ranges method" do
        should "provide an array of hashes containing minimum and maximum values" do
          assert_equal 70, @calculator.sucrose_ranges.last[:min]
        end
      end
    end
  end
end
