require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StatePensionTopUpCalculatorTest < ActiveSupport::TestCase
    context "check rate for age" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionTopUpDataQuery.new(
          age: 69)
      end

      should "be 801" do
        assert_equal 801, @calculator.data_query.age_and_rates
      end
    end
  end
end
