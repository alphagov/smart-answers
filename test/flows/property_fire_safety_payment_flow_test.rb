require "test_helper"
require "support/flow_test_helper"

class PropertyFireSafetyPaymentFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow PropertyFireSafetyPaymentFlow
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: building_over_11_metres?" do
    setup { testing_node :building_over_11_metres? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of own_freehold? if yes" do
        assert_next_node :own_freehold?, for_response: "yes"
      end

      should "have an outcome of unlikely_to_need_fixing if no" do
        assert_next_node :unlikely_to_need_fixing, for_response: "no"
      end
    end
  end


  context "outcomes" do
    context "when building is under 11 metres" do
      setup do
        testing_node :unlikely_to_need_fixing
        add_responses building_over_11_metres?: "no"
      end

      should "render outcome text" do
        assert_rendered_outcome text: "Your building is unlikely to need fixing"
      end
    end
  end
end
