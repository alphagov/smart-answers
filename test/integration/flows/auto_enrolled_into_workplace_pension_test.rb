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

  context "does not work in the UK" do
    should "not be enrolled in pension" do
      add_response :no
      assert_current_node :not_enrolled
    end
  end

  context "works in the UK" do
    setup do
      add_response :yes
    end

    should "ask if self employed" do
      assert_current_node :self_employed?
    end
  end
end