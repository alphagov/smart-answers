require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/student-finance-forms"

class StudentFinanceFormsTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::StudentFinanceFormsFlow
  end

end
