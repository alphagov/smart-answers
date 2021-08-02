require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PersonalAllowanceCalculatorTest < ActiveSupport::TestCase
    def setup
      @personal_allowance = 8105
      @higher_allowance1 = 10_500
      @higher_allowance2 = 10_660

      @calculator = PersonalAllowanceCalculator.new
      @calculator.stubs(
        personal_allowance: @personal_allowance,
        higher_allowance_1: @higher_allowance1,
        higher_allowance_2: @higher_allowance2,
      )
    end

    context "before 2013 to 2014 tax year" do
      setup do
        travel_to("2012-11-11")
      end

      should "return the basic allowance for someone aged 64 at end of tax year" do
        date_of_birth = Date.parse("1948-04-06")
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@personal_allowance, result)
      end

      should "return the 1st higher allowance for someone aged 65 at end of tax year" do
        date_of_birth = Date.parse("1948-04-05")
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@higher_allowance1, result)
      end

      should "return the 1st higher allowance for someone aged 74 at end of tax year" do
        date_of_birth = Date.parse("1938-04-06")
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@higher_allowance1, result)
      end

      should "return the 2nd higher allowance for someone aged 75 at end of tax year" do
        date_of_birth = Date.parse("1938-04-05")
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@higher_allowance2, result)
      end
    end

    context "in or after 2013 to 2014 tax year" do
      setup do
        travel_to("2014-04-06")
      end

      should "return the basic allowance for someone born on 6th April 1948" do
        date_of_birth = Date.parse("1948-04-06")
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@personal_allowance, result)
      end

      should "return the 1st higher allowance for someone born on 5th April 1948" do
        date_of_birth = Date.parse("1948-04-05")
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@higher_allowance1, result)
      end

      should "return the 1st higher allowance for someone born on 6th April 1938" do
        date_of_birth = Date.parse("1938-04-06")
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@higher_allowance1, result)
      end

      should "return the 2nd higher allowance for someone born on 5th April 1938" do
        date_of_birth = Date.parse("1938-04-05")
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@higher_allowance2, result)
      end
    end
  end
end
