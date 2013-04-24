# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class BenefitsAbroadBackInUkTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'benefits-abroad'
  end

  # Q0
  should "ask which case applies" do
    assert_current_node :which_case?
  end

  context "when going abroad" do
    setup do
      add_response "back_in_the_uk"
    end

    # Q1
    should "ask which country you worked in" do
      assert_current_node :which_country_did_you_work_in?
    end
  end
end
