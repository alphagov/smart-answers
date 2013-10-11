# coding:utf-8

require_relative '../test_helper'
require 'ostruct'

module SmartAnswer
  class DateQuestionTest < ActiveSupport::TestCase
    def setup
      @initial_state = State.new(:example)
    end

    test "dates are parsed from hash form before being saved" do
      q = Question::Date.new(:example) do
        save_input_as :date
        next_node :done
      end

      new_state = q.transition(@initial_state, {year: "2011", month: '2', day: '1'})
      assert_equal '2011-02-01', new_state.date
    end

    test "incomplete dates raise an error" do
      q = Question::Date.new(:example) do
        save_input_as :date
        next_node :done
      end
      
      assert_raise SmartAnswer::InvalidResponse do
        q.transition(@initial_state, {year: "", month: '2', day: '1'})
      end
    end

    test "define allowable range of dates" do
      q = Question::Date.new(:example) do
        save_input_as :date
        next_node :done
        from { Date.parse('2011-01-01') }
        to { Date.parse('2011-01-03') }
      end
      assert_equal ::Date.parse('2011-01-01')..::Date.parse('2011-01-03'), q.range
    end

    test "define default date" do
      q = Question::Date.new(:example) do
        default { Date.today }
      end
      assert_equal Date.today, q.default
    end

    test "define default day" do
      q = Question::Date.new(:example) do
        default_day 11
      end
      assert_equal 11, q.default_day
    end

    test "define default month" do
      q = Question::Date.new(:example) do
        default_month 2
      end
      assert_equal 2, q.default_month
    end

    test "define default year" do
      q = Question::Date.new(:example) do
        default_year 2013
      end
      assert_equal 2013, q.default_year
    end

    test "incomplete dates are accepted if appropriate defaults are defined" do
      q = Question::Date.new(:example) do
        default_day 11
        default_month 2
        default_year 2013
        save_input_as :date
        next_node :done
      end

      new_state = q.transition(@initial_state, {year: "", month: "", day: ""})
      assert_equal '2013-02-11', new_state.date
    end

    test "default the day to the last in the month of an incomplete date" do
      q = Question::Date.new(:example) do
        default_day -1
        save_input_as :date
        next_node :done
      end

      incomplete_date = {year: "2013", month: "2", day: ""}
      new_state = q.transition(@initial_state, incomplete_date)
      assert_equal '2013-02-28', new_state.date
    end
  end
end
