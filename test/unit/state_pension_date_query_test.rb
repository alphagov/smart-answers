require_relative '../../lib/data/state_pension_date_query'
require_relative '../test_helper'

class StatePensionDateQueryTest < ActiveSupport::TestCase
  test ".pension_credit_date initializes the class with the 'female' gender" do
    today = Date.today
    query_double = OpenStruct.new(find_date: :date)
    StatePensionDateQuery.expects(:new).with(today, :female).returns(query_double)

    StatePensionDateQuery.pension_credit_date(today)
  end

  test ".bus_pass_qualification_date initializes the class with the 'female' gender" do
    today = Date.today
    query_double = OpenStruct.new(find_date: :date)
    StatePensionDateQuery.expects(:new).with(today, :female).returns(query_double)

    StatePensionDateQuery.bus_pass_qualification_date(today)
  end
end
