# coding:utf-8

require_relative '../test_helper'
require 'ostruct'

module SmartAnswer
  class DateQuestionTest < ActiveSupport::TestCase
    def setup
      @initial_state = State.new(:example)
    end

    test "dates are parsed from Hash into Date before being saved" do
      q = Question::Date.new(nil, :example) do
        save_input_as :date
        next_node :done
      end

      new_state = q.transition(@initial_state, {year: "2011", month: '2', day: '1'})
      assert_equal Date.parse('2011-02-01'), new_state.date
    end

    test "incomplete dates raise an error" do
      q = Question::Date.new(nil, :example) do
        save_input_as :date
        next_node :done
      end

      assert_raise SmartAnswer::InvalidResponse do
        q.transition(@initial_state, {year: "", month: '2', day: '1'})
      end
    end

    test 'range returns false when neither from nor to are set' do
      q = Question::Date.new(nil, :question_name)
      assert_equal false, q.range
    end

    test 'range returns false when only the from date is set' do
      q = Question::Date.new(nil, :question_name) do
        from { Date.today }
      end
      assert_equal false, q.range
    end

    test 'range returns false when only the to date is set' do
      q = Question::Date.new(nil, :question_name) do
        to { Date.today }
      end
      assert_equal false, q.range
    end

    test "define allowable range of dates" do
      q = Question::Date.new(nil, :example) do
        save_input_as :date
        next_node :done
        from { Date.parse('2011-01-01') }
        to { Date.parse('2011-01-03') }
      end
      assert_equal ::Date.parse('2011-01-01')..::Date.parse('2011-01-03'), q.range
    end

    test "a day before the allowed range is invalid" do
      assert_raises(InvalidResponse) do
        date_question_2011.transition(@initial_state, '2010-12-31')
      end
    end

    test "a day after the allowed range is invalid" do
      assert_raises(InvalidResponse) do
        date_question_2011.transition(@initial_state, '2012-01-01')
      end
    end

    test "the first day of the allowed range is valid" do
      new_state = date_question_2011.transition(@initial_state, '2011-01-01')
      assert @initial_state != new_state
    end

    test "the last day of the allowed range is valid" do
      new_state = date_question_2011.transition(@initial_state, '2011-12-31')
      assert @initial_state != new_state
    end

    test "do not complain when the input is within the allowed range when the dates are in descending order" do
      q = Question::Date.new(nil, :example) do
        save_input_as :date
        next_node :done
        from { Date.parse('2011-01-03') }
        to { Date.parse('2011-01-01') }
        validate_in_range
      end

      q.transition(@initial_state, '2011-01-02')
    end

    test "define default day" do
      q = Question::Date.new(nil, :example) do
        default_day { 11 }
      end
      assert_equal 11, q.default_day
    end

    test "define default month" do
      q = Question::Date.new(nil, :example) do
        default_month { 2 }
      end
      assert_equal 2, q.default_month
    end

    test "define default year" do
      q = Question::Date.new(nil, :example) do
        default_year { 2013 }
      end
      assert_equal 2013, q.default_year
    end

    test "incomplete dates are accepted if appropriate defaults are defined" do
      q = Question::Date.new(nil, :example) do
        default_day { 11 }
        default_month { 2 }
        default_year { 2013 }
        save_input_as :date
        next_node :done
      end

      new_state = q.transition(@initial_state, {year: "", month: "", day: ""})
      assert_equal Date.parse('2013-02-11'), new_state.date
    end

    test "default the day to the last in the month of an incomplete date" do
      q = Question::Date.new(nil, :example) do
        default_day { -1 }
        save_input_as :date
        next_node :done
      end

      incomplete_date = {year: "2013", month: "2", day: ""}
      new_state = q.transition(@initial_state, incomplete_date)
      assert_equal Date.parse('2013-02-28'), new_state.date
    end

    test "#date_of_birth_defaults prevent very old values" do
      assert_raise SmartAnswer::InvalidResponse do
        dob_question.transition(@initial_state, 125.years.ago.to_date.to_s)
      end
    end

    test "#date_of_birth_defaults prevent next year dates" do
      assert_raise SmartAnswer::InvalidResponse do
        next_year_start = 1.year.from_now.beginning_of_year.to_date.to_s
        dob_question.transition(@initial_state, next_year_start)
      end
    end

    test "#date_of_birth_defaults accepts 120 years old values" do
      dob_question.transition(@initial_state, 120.years.ago.to_date.to_s)
    end

  private

    def date_question_2011
      Question::Date.new(nil, :example) do
        save_input_as :date
        next_node :done
        from { Date.parse('2011-01-01') }
        to { Date.parse('2011-12-31') }
        validate_in_range
      end
    end

    def dob_question
      Question::Date.new(nil, :example) do
        date_of_birth_defaults
        save_input_as :date
        next_node :done
      end
    end
  end
end
