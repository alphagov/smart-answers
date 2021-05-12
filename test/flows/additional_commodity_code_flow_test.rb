require "test_helper"
require "support/flow_test_helper"

class AdditionalCommodityCodeFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow AdditionalCommodityCodeFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: starch_or_glucose" do
    setup { testing_node :starch_or_glucose }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of sucrose" do
        assert_next_node :sucrose, for_response: "0..5"
      end
    end
  end

  context "question: sucrose" do
    setup do
      testing_node :sucrose
      add_responses starch_or_glucose: "0..5"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of milk_fat for any response" do
        assert_next_node :milk_fat, for_response: "0..5"
      end
    end
  end

  context "question: milk_fat" do
    setup do
      testing_node :milk_fat
      add_responses starch_or_glucose: "0..5",
                    sucrose: "0..5"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      %w[0..1.5 1.5..3 3..6 6..9 9..12 12..18 18..26 26..40].each do |response|
        should "have a next node of milk_protein for '#{response}' response" do
          assert_next_node :milk_protein, for_response: response
        end
      end

      %w[40..55 55..70 70..85 85..100].each do |response|
        should "have a next node of commodity_code_result for '#{response}' response" do
          assert_next_node :commodity_code_result, for_response: response
        end
      end
    end
  end

  context "question: milk_protein" do
    setup do
      testing_node :milk_protein
      add_responses starch_or_glucose: "0..5",
                    sucrose: "0..5",
                    milk_fat: "0..1.5"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of commodity_code_result for any response" do
        assert_next_node :commodity_code_result, for_response: "0..2.5"
      end
    end
  end

  context "outcome: commodity_code_result" do
    setup { testing_node :commodity_code_result }

    should "render commodity code guidance for commodity_code" do
      add_responses starch_or_glucose: "0..5",
                    sucrose: "0..5",
                    milk_fat: "0..1.5",
                    milk_protein: "0..2.5"

      assert_rendered_outcome text: "The Meursing code for a product with this composition is 7000."
    end

    should "not render commodity code guidance for commodity_code of nil" do
      add_responses starch_or_glucose: "75..100",
                    sucrose: "5..100",
                    milk_fat: "85..100",
                    milk_protein: "0..100"

      assert_rendered_outcome text: "The product composition you indicated is not possible."
    end
  end
end
