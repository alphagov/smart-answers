require_relative '../../test_helper'

module SmartAnswer::Calculators
  class PersonalAllowanceCalculatorTest < ActiveSupport::TestCase
    def setup
      @personal_allowance = 8105
      @over_65_allowance = 10500
      @over_75_allowance = 10660

      @calculator = PersonalAllowanceCalculator.new
      @calculator.stubs(
        personal_allowance: @personal_allowance,
        over_65_allowance: @over_65_allowance,
        over_75_allowance: @over_75_allowance
      )
    end

    context 'before 2013 to 2014 tax year' do
      setup do
        Timecop.freeze(Date.parse('2013-04-05'))
      end

      teardown do
        Timecop.return
      end

      should "return the basic personal allowance for someone aged 64 who will be 65 after 5th April" do
        date_of_birth = Date.new(Date.today.year - 65, 4, 6)
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@personal_allowance, result)
      end

      should "return the 65-75 personal allowance for someone aged 64 who will be 65 on 5th April" do
        date_of_birth = Date.new(Date.today.year - 65, 4, 5)
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@over_65_allowance, result)
      end

      should "return the 65-75 personal allowance for someone aged 74 who will be 75 after 5th April" do
        date_of_birth = Date.new(Date.today.year - 75, 4, 6)
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@over_65_allowance, result)
      end

      should "return the 75+ personal allowance for someone aged 74 who will be 75 on 5th April" do
        date_of_birth = Date.new(Date.today.year - 75, 4, 5)
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@over_75_allowance, result)
      end
    end
  end
end
