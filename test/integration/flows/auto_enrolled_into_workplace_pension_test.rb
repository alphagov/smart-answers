# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class AutoEnrolledIntoWorkplacePensionTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'auto-enrolled-into-workplace-pension'
  end

  should "ask if you work in the UK" do
    assert_current_node :work_in_uk?
  end
end