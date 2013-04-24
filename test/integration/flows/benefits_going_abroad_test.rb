# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class BenefitsGoingAbroadTest < ActiveSupport::TestCase
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
      add_response "going_abroad"
    end

    # Q1
    should "ask 'have you paid ni in the uk?'" do
      assert_current_node :have_you_paid_ni_in_the_uk?
    end

    # See test/integration/flows/benefits_going_abroad_test.rb
    # for the rest of this shared logic flow test.
  end
end
