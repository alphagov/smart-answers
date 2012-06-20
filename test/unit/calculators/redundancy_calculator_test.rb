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
  end
end
