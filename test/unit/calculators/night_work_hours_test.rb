require_relative "../../test_helper"

module SmartAnswer::Calculators
  class RedundancyCalculatorTest < ActiveSupport::TestCase
    context "7 day work cycle" do
      setup do
        @calc = NightWorkHours.new(
          weeks_worked: 4, weeks_leave: 1,
          work_cycle: 7, nights_in_cycle: 5,
          hours_per_shift: 9, overtime_hours: 6
        )
      end

      should "calculate total hours worked" do
        expected = (4 * 5 * 9) + 6
        assert_equal expected, @calc.total_hours
      end

      should "calculate average hours worked" do
        expected = ((4 * 5 * 9) + 6) / 2
        assert_equal expected, @calc.average_hours
      end

      should "calculate potential days you could work" do
        # TODO: This doesn't seem right
        expected = 4 * 7
        assert_equal expected, @calc.potential_days
      end
    end

    context "non 7 day work cycle" do
      setup do
        @calc = NightWorkHours.new(
          weeks_worked: 5, weeks_leave: 1,
          work_cycle: 6, nights_in_cycle: 4,
          hours_per_shift: 9, overtime_hours: 6
        )
      end

      should "calculate total hours worked" do
        expected = (5 * 7 / 6 * 4 * 9) + 6
        assert_equal expected, @calc.total_hours
      end

      should "calculate average hours worked" do
        expected = ((5 * 7 / 6 * 4 * 9) + 6) / 2
        assert_equal expected, @calc.average_hours
      end

      should "calculate potential days you could work" do
        # TODO: This doesn't seem right
        expected = 5 * 7
        assert_equal expected, @calc.potential_days
      end
    end
  end
end
