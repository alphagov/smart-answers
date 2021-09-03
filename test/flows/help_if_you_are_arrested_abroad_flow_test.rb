require "test_helper"
require "support/flow_test_helper"

class HelpIfYouAreArrestedAbroadFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow HelpIfYouAreArrestedAbroadFlow
    @location_slugs = %w[austria france iran pitcairn-island syria]
    stub_worldwide_api_has_locations(@location_slugs)
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: which_country?" do
    setup { testing_node :which_country? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of answer_three_syria for syria response" do
        assert_next_node :answer_three_syria, for_response: "syria"
      end

      should "have a next node of answer_three_british_overseas_territories for british overseas territory response" do
        assert_next_node :answer_three_british_overseas_territories, for_response: "pitcairn-island"
      end

      should "have a next node of answer_one_generic for any other response" do
        assert_next_node :answer_one_generic, for_response: "france"
      end
    end
  end

  context "outcome: answer_one_generic" do
    setup do
      testing_node :answer_one_generic
      add_responses which_country?: "france"
    end

    should "render the Iran specific text for Iran" do
      add_responses which_country?: "iran"

      assert_rendered_outcome text: "Information pack for British nationals imprisoned in Iran"
    end

    should "render the standard text for other countries" do
      assert_no_match "Information pack for British nationals imprisoned in Iran", @test_flow.outcome_text
    end

    should "render the extra dowloads if there are any for that country" do
      assert_rendered_outcome text: "English speaking lawyers and translators/interpreters in France"
    end

    should "render the transfer back option if it is a country with transfers back" do
      assert_rendered_outcome text: "Transfers back to the UK"
    end

    should "not render the transfer back option if it is not a country with transfers back" do
      add_responses which_country?: "austria"

      assert_no_match "Transfers back to the UK", @test_flow.outcome_text
    end
  end
end
