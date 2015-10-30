require_relative '../test_helper'

module SmartAnswer
  class YearRangeTest < ActiveSupport::TestCase
    setup do
      @year_range = YearRange.new(begins_on: Date.parse('2000-02-01'))
    end

    should 'begin on begins_on date' do
      assert_equal Date.parse('2000-02-01'), @year_range.begins_on
    end

    should 'end a day before a year after the begins_on date' do
      assert_equal Date.parse('2001-01-31'), @year_range.ends_on
    end
  end
end
