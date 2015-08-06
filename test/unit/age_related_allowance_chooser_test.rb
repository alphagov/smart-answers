require_relative '../test_helper'

module SmartAnswer
  class AgeRelatedAllowanceChooserTest < ActiveSupport::TestCase
    def setup
      @personal_allowance = 8105
      @over_65_allowance = 10500
      @over_75_allowance = 10660

      @chooser = AgeRelatedAllowanceChooser.new(
        personal_allowance: @personal_allowance,
        over_65_allowance: @over_65_allowance,
        over_75_allowance: @over_75_allowance)
    end

    test "someone aged 40 has the basic personal allowance" do
      date_of_birth = Date.today - 40.years
      result = @chooser.get_age_related_allowance(date_of_birth)
      assert_equal(@personal_allowance, result)
    end

    test "someone aged 67 has the 65-75 personal allowance" do
      date_of_birth = Date.today - 67.years
      result = @chooser.get_age_related_allowance(date_of_birth)
      assert_equal(@over_65_allowance, result)
    end

    test "someone aged 65 has the 65-75 personal allowance" do
      date_of_birth = Date.today - 65.years
      result = @chooser.get_age_related_allowance(date_of_birth)
      assert_equal(@over_65_allowance, result)
    end

    test "someone aged 64 who will be 65 before 5th April has the 65-75 personal allowance" do
      date_of_birth = Date.new(Date.today.year - 65, 4, 4)
      result = @chooser.get_age_related_allowance(date_of_birth)
      assert_equal(@over_65_allowance, result)
    end

    test "someone aged 64 who will be 65 on 5th April has the 65-75 personal allowance" do
       date_of_birth = Date.new(Date.today.year - 65, 4, 5)
      result = @chooser.get_age_related_allowance(date_of_birth)
      assert_equal(@over_65_allowance, result)
     end

    test "someone aged 64 who will be 65 after 5th April has the basic personal allowance" do
       date_of_birth = Date.new(Date.today.year - 65, 4, 6)
      result = @chooser.get_age_related_allowance(date_of_birth)
      assert_equal(@over_65_allowance, result)
     end

    test "someone aged 77 has the 75+ personal allowance" do
      date_of_birth = Date.today - 77.years
      result = @chooser.get_age_related_allowance(date_of_birth)
      assert_equal(@over_75_allowance, result)
    end

    test "someone aged 75 who will be 75 before 5th April has the 75+ personal allowance" do
      date_of_birth = Date.new(Date.today.year - 75, 4, 4)
      result = @chooser.get_age_related_allowance(date_of_birth)
      assert_equal(@over_75_allowance, result)
    end

    test "someone aged 74 who will be 75 on 5th April has the 75+ personal allowance" do
       date_of_birth = Date.new(Date.today.year - 75, 4, 5)
      result = @chooser.get_age_related_allowance(date_of_birth)
      assert_equal(@over_75_allowance, result)
     end

    test "someone aged 74 who will be 75 after 5th April has the 65-75 personal allowance" do
       date_of_birth = Date.new(Date.today.year - 75, 4, 6)
      result = @chooser.get_age_related_allowance(date_of_birth)
      assert_equal(@over_75_allowance, result)
     end
  end
end
