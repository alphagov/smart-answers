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

    context "use correct weekly pay and number of years limits" do
      
      # Aged 45, 12 years service, 350 per week
      should "be 4900" do
        assert_equal 4900, @calculator.pay("45", 12, 350) 
      end

      # Aged 42, 22 years of service, 500 per week
      should "use maximum of 20 years and maximum of 430 per week" do
        assert_equal 8815, @calculator.pay("42", 22, 500)
      end

      should "" do
        assert_equal 1935, @calculator.pay("42", 4, 1500)
      end
    end
  end
end
