# coding:utf-8

require_relative '../test_helper'

class DateQuestionTest < ActiveSupport::TestCase
  def setup
    @initial_state = OpenStruct.new(current_state: :example).freeze
  end
  
  test "Dates are parsed from array form before being saved" do
    q = SmartAnswer::Question::Date.new(:example) do
      save_input_as :date
    end
    
    new_state = q.transition(@initial_state, ["2011", '2', '1'])
    assert_equal Date.new(2011, 2, 1), new_state.date
  end

  test "Can define allowable range of dates" do
    q = SmartAnswer::Question::Date.new(:example) do
      save_input_as :date
      from { Date.parse('2011-01-01') }
      to { Date.parse('2011-01-03') }
    end
    assert_equal Date.parse('2011-01-01')..Date.parse('2011-01-03'), q.range
  end
end