require "test_helper"
require "support/flow_test_helper"

class CovidTravelAbroadFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow CovidTravelAbroadFlow
  end

  should "render start page" do
    assert_rendered_start_page
  end
  
  context "question: travelling_with_children" do
    setup do
      testing_node :travelling_with_children
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of results " \
                "for any response " do
        assert_next_node :results, for_response: "zero_to_four"
      end
    end
  end
end
