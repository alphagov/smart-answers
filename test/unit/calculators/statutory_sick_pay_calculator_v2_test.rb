require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StatutorySickPayCalculatorV2Test < ActiveSupport::TestCase
    context StatutorySickPayCalculatorV2 do
      should "calculate number of months between dates" do
        months = StatutorySickPayCalculatorV2.months_between(Date.parse("04/02/2012"), Date.parse("17/05/2012"))
        assert_equal 4, months
      end

      should "not count the first month if it's later than the 17th" do
        months = StatutorySickPayCalculatorV2.months_between(Date.parse("18/02/2012"), Date.parse("17/05/2012"))
        assert_equal 3, months
      end

      should "not count the last month if it's before the 15th" do
        months = StatutorySickPayCalculatorV2.months_between(Date.parse("13/02/2012"), Date.parse("14/05/2012"))
        assert_equal 3, months
      end
    end
  end
end
