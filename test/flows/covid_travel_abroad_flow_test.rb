require "test_helper"
require "support/flow_test_helper"

class CovidTravelAbroadFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow CovidTravelAbroadFlow
    stub_worldwide_api_has_locations(%w[spain italy poland])
  end

  should "render start page" do
    assert_rendered_start_page
  end

  context "question: which_country" do
    setup do
      testing_node :which_country
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of any_other_countries_1 " \
                "for any response " do
        assert_next_node :vaccination_status, for_response: "spain"
      end
    end
  end

  context "question: vaccination_status" do
    setup do
      testing_node :vaccination_status
      add_responses which_country: "spain"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of travelling_with_children " \
                "for any response " do
        assert_next_node :travelling_with_children, for_response: "vaccinated"
      end
    end
  end

  context "question: travelling_with_children" do
    setup do
      testing_node :travelling_with_children
      add_responses which_country: "spain",
                    vaccination_status: "vaccinated"
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
