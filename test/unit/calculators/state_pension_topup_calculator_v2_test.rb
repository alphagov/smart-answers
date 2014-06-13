require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StatePensionTopupCalculatorV2Test < ActiveSupport::TestCase
    context "check rate for age" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionTopupDataQueryV2.new
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

      should "return upper_age - dob in years" do
        upper_date = Date.parse('2017-04-01')
        dob = Date.parse('1920-01-01')
        assert_equal 97, @calculator.date_difference_in_years(dob, upper_date)
      end
      should "return lower_age - dob in years" do
        lower_date = Date.parse('2015-10-12')
        dob = Date.parse('1920-01-01')
        assert_equal 95, @calculator.date_difference_in_years(dob, lower_date)
      end

      should "return upper_rate - dob in years" do
        assert_equal 1590.0, @calculator.money_rate_cost(97, 10)
      end
      should "return lower_rate - dob in years" do
        assert_equal 1850.0, @calculator.money_rate_cost(95, 10)
      end
    end
  end
end
