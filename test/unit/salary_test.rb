
require_relative '../test_helper'

module SmartAnswer
  class SalaryTest < ActiveSupport::TestCase
    test "Can convert monthly to weekly salary" do
      monthly = Salary.new("520", "month")
      expected_weekly = Money.new("120")
      assert_equal expected_weekly, monthly.per_week
    end

    test "Can compare salarys with same period" do
      m1 = Salary.new("520", "month")
      m2 = Salary.new("120", "month")
      m3 = Salary.new("520", "month")
      assert m1 > m2
      assert m2 < m1
      assert m1 == m3
    end

    test "Converts to string" do
      assert_equal "520.0-month", Salary.new("520", "month").to_s
    end

    test "Parses from string" do
      assert_equal Salary.new("520", "month"), Salary.new("520-month")
    end
  end
end
