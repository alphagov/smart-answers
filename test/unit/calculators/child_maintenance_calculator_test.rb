require_relative '../../test_helper'

module SmartAnswer::Calculators
  class ChildMaintenanceCalculatorTest < ActiveSupport::TestCase
    context ChildMaintenanceCalculator do
      should "determine the rate scheme based on the constructor params" do
        @calculator = ChildMaintenanceCalculator.new(3)
        assert_equal :old, @calculator.calculation_scheme
        @calculator = ChildMaintenanceCalculator.new(5)
        assert_equal :new, @calculator.calculation_scheme
      end
    end
    context "rate_type method" do
      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(3) 
        @calculator.net_income = 6 # old scheme at flat rate.
        assert_equal :flat, @calculator.rate_type
      end
    end
#    context "new scheme calculations" do
#      setup do
#        @calculator = ChildMaintenanceCalculator.new(5)
#        @calculator.net_income = 173.00
#      end 
#      context "reduced_rate_mulitplier method" do
#        should "give the multiplier to use when calculating the new reduced rate" do
#          @calculator.number_of_other_children = 2
#          assert_equal 0.375, @calculator.reduced_rate_mulitplier
#          @calculator.number_of_other_children = 1
#          assert_equal 0.37, @calculator.reduced_rate_mulitplier
#        end
#      end
#      context "shared_care_multiplier method" do
#        should "give the multiplier to use when adjusting the new reduced rate" do
#          @calculator.number_of_shared_care_nights = 2
#          assert_equal 0.28, @calculator.shared_care_multiplier
#        end
#      end
#    end
    context "calculate_reduced_rate_payment method" do
      should "give the reduced rate payment total" do
        @calculator = ChildMaintenanceCalculator.new(2)
        @calculator.net_income = 173.00
        @calculator.number_of_other_children = 1
        @calculator.number_of_shared_care_nights = 1
        assert_equal 0.29, @calculator.reduced_rate_mulitplier
        assert_equal 0.14, @calculator.shared_care_multiplier
        assert_equal 24.23, @calculator.calculate_reduced_rate_payment
      end
    end
    context "calculate_basic_rate_payment method" do
      should "give the reduced rate payment total" do
        @calculator = ChildMaintenanceCalculator.new(1)
        @calculator.net_income = 307.00
        @calculator.number_of_other_children = 2
        @calculator.number_of_shared_care_nights = 2
        assert_equal 0.16, @calculator.relevant_other_child_multiplier
        assert_equal 0.131, @calculator.basic_rate_multiplier
        assert_equal 0.28, @calculator.shared_care_multiplier
        assert_equal 24.32, @calculator.calculate_basic_rate_payment
      end
    end
  end
end
