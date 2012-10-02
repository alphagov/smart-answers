require_relative "../../test_helper"

module SmartAnswer::Calculators
  class RedundancyCalculatorTest < ActiveSupport::TestCase
    def setup
      @calculator = RedundancyCalculator.new
    end

    context "Money formatting conforms to styleguide" do
      should "lop off trailing 00s" do
        assert_equal @calculator.format_money(12.00), "12"
      end

      should "leave trailing other numbers alone" do
        assert_equal @calculator.format_money(12.50), "12.50"
        assert_equal @calculator.format_money(99.09), "99.09"
      end

      should "use commas to separate thousands" do
        assert_equal @calculator.format_money(1200.50), "1,200.50"
        assert_equal @calculator.format_money(4500.00), "4,500"
      end
    end

    # max of 20 years and 430 per week
    context "use correct weekly pay and number of years limits" do
      should "use maximum of 20 years" do
        # the result should be 20 * 200 * 1
        assert_equal @calculator.pay("22-40", 22, 200), 4000
      end

      should "use maximum of 430 per week" do
        # the result should be 430 * 10 * 1
        assert_equal @calculator.pay("22-40", 10, 500), 4300
      end
    end
  end
end
