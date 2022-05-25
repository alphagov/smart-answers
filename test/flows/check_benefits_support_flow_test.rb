require "test_helper"
require "support/flow_test_helper"

class CheckBenefitsSupportFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow CheckBenefitsSupportFlow
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: where_do_you_live" do
    setup { testing_node :where_do_you_live }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of over_state_pension_age" do
        assert_next_node :over_state_pension_age, for_response: "england"
      end
    end
  end
end
