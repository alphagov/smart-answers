require_relative '../../test_helper'

module SmartAnswer::Calculators
  class PersonalAllowanceCalculatorTest < ActiveSupport::TestCase
    def setup
      @personal_allowance = 8105
      @higher_allowance_1 = 10500
      @higher_allowance_2 = 10660

      @calculator = PersonalAllowanceCalculator.new
      @calculator.stubs(
        personal_allowance: @personal_allowance,
        higher_allowance_1: @higher_allowance_1,
        higher_allowance_2: @higher_allowance_2
      )
    end

    context 'before 2013 to 2014 tax year' do
      setup do
        Timecop.freeze(Date.parse('2013-04-05'))
      end

      teardown do
        Timecop.return
      end

      should "return the basic allowance for someone aged 64 who will be 65 after 5th April" do
        date_of_birth = Date.new(Date.today.year - 65, 4, 6)
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@personal_allowance, result)
      end

      should "return the 1st higher allowance for someone aged 64 who will be 65 on 5th April" do
        date_of_birth = Date.new(Date.today.year - 65, 4, 5)
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@higher_allowance_1, result)
      end

      should "return the 1st higher allowance for someone aged 74 who will be 75 after 5th April" do
        date_of_birth = Date.new(Date.today.year - 75, 4, 6)
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@higher_allowance_1, result)
      end

      should "return the 2nd higher allowance for someone aged 74 who will be 75 on 5th April" do
        date_of_birth = Date.new(Date.today.year - 75, 4, 5)
        result = @calculator.age_related_allowance(date_of_birth)
        assert_equal(@higher_allowance_2, result)
      end
    end
  end
end
