require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StatePensionTopUpCalculatorTest < ActiveSupport::TestCase
    context "check rate for age" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionTopUpDataQuery.new
      end

      should "be 801 for age of 69" do
        assert_equal 801, @calculator.age_and_rates(69)
      end
      
      should "be nil for age of 101" do
        assert_equal nil, @calculator.age_and_rates(101)
      end
      
      should "be nil for age of 80" do
        assert_equal 544, @calculator.age_and_rates(80)
      end
    end
  end
end
