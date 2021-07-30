require "test_helper"
require "support/flow_test_helper"

class AdditionalCommodityCodeFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow AdditionalCommodityCodeFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: how_much_starch_glucose?" do
    setup { testing_node :how_much_starch_glucose? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_much_sucrose_1? for a '0' response" do
        assert_next_node :how_much_sucrose_1?, for_response: "0"
      end

      should "have a next node of how_much_sucrose_1? for a '5' response" do
        assert_next_node :how_much_sucrose_1?, for_response: "5"
      end

      should "have a next node of how_much_sucrose_2? for a '25' response" do
        assert_next_node :how_much_sucrose_2?, for_response: "25"
      end

      should "have a next node of how_much_sucrose_3? for a '50' response" do
        assert_next_node :how_much_sucrose_3?, for_response: "50"
      end

      should "have a next node of how_much_sucrose_4? for a '75' response" do
        assert_next_node :how_much_sucrose_4?, for_response: "75"
      end
    end
  end

  context "question: how_much_sucrose_1?" do
    setup do
      testing_node :how_much_sucrose_1?
      add_responses how_much_starch_glucose?: "0"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_much_milk_fat? for any response" do
        assert_next_node :how_much_milk_fat?, for_response: "0"
      end
    end
  end

  context "question: how_much_sucrose_2?" do
    setup do
      testing_node :how_much_sucrose_2?
      add_responses how_much_starch_glucose?: "25"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_much_milk_fat? for any response" do
        assert_next_node :how_much_milk_fat?, for_response: "0"
      end
    end
  end

  context "question: how_much_sucrose_3?" do
    setup do
      testing_node :how_much_sucrose_3?
      add_responses how_much_starch_glucose?: "50"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_much_milk_fat? for any response" do
        assert_next_node :how_much_milk_fat?, for_response: "0"
      end
    end
  end

  context "question: how_much_sucrose_4?" do
    setup do
      testing_node :how_much_sucrose_4?
      add_responses how_much_starch_glucose?: "75"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_much_milk_fat? for any response" do
        assert_next_node :how_much_milk_fat?, for_response: "0"
      end
    end
  end

  context "question: how_much_milk_fat?" do
    setup do
      testing_node :how_much_milk_fat?
      add_responses how_much_starch_glucose?: "0",
                    how_much_sucrose_1?: "0"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_much_milk_protein_ab? for '0' response" do
        assert_next_node :how_much_milk_protein_ab?, for_response: "0"
      end

      should "have a next node of how_much_milk_protein_ab? for '1' response" do
        assert_next_node :how_much_milk_protein_ab?, for_response: "1"
      end

      should "have a next node of how_much_milk_protein_c? for '3' response" do
        assert_next_node :how_much_milk_protein_c?, for_response: "3"
      end

      should "have a next node of how_much_milk_protein_d? for '6' response" do
        assert_next_node :how_much_milk_protein_d?, for_response: "6"
      end

      should "have a next node of how_much_milk_protein_ef? for '9' response" do
        assert_next_node :how_much_milk_protein_ef?, for_response: "9"
      end

      should "have a next node of how_much_milk_protein_ef? for '12' response" do
        assert_next_node :how_much_milk_protein_ef?, for_response: "12"
      end

      should "have a next node of how_much_milk_protein_gh? for '18' response" do
        assert_next_node :how_much_milk_protein_gh?, for_response: "18"
      end

      should "have a next node of how_much_milk_protein_gh? for '26' response" do
        assert_next_node :how_much_milk_protein_gh?, for_response: "26"
      end

      %w[40 55 70 85].each do |response|
        should "have a next node of commodity_code_result for '#{response}' response" do
          assert_next_node :commodity_code_result, for_response: response
        end
      end
    end
  end

  context "question: how_much_milk_protein_ab?" do
    setup do
      testing_node :how_much_milk_protein_ab?
      add_responses how_much_starch_glucose?: "0",
                    how_much_sucrose_1?: "0",
                    how_much_milk_fat?: "0"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of commodity_code_result for any response" do
        assert_next_node :commodity_code_result, for_response: "0"
      end
    end
  end

  context "question: how_much_milk_protein_c?" do
    setup do
      testing_node :how_much_milk_protein_c?
      add_responses how_much_starch_glucose?: "0",
                    how_much_sucrose_1?: "0",
                    how_much_milk_fat?: "3"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of commodity_code_result for any response" do
        assert_next_node :commodity_code_result, for_response: "0"
      end
    end
  end

  context "question: how_much_milk_protein_d?" do
    setup do
      testing_node :how_much_milk_protein_d?
      add_responses how_much_starch_glucose?: "0",
                    how_much_sucrose_1?: "0",
                    how_much_milk_fat?: "6"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of commodity_code_result for any response" do
        assert_next_node :commodity_code_result, for_response: "0"
      end
    end
  end

  context "question: how_much_milk_protein_ef?" do
    setup do
      testing_node :how_much_milk_protein_ef?
      add_responses how_much_starch_glucose?: "0",
                    how_much_sucrose_1?: "0",
                    how_much_milk_fat?: "9"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of commodity_code_result for any response" do
        assert_next_node :commodity_code_result, for_response: "0"
      end
    end
  end

  context "question: how_much_milk_protein_gh?" do
    setup do
      testing_node :how_much_milk_protein_gh?
      add_responses how_much_starch_glucose?: "0",
                    how_much_sucrose_1?: "0",
                    how_much_milk_fat?: "18"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of commodity_code_result for any response" do
        assert_next_node :commodity_code_result, for_response: "0"
      end
    end
  end

  context "outcome: commodity_code_result" do
    setup { testing_node :commodity_code_result }

    should "render commodity code guidance for commodity_code" do
      add_responses how_much_starch_glucose?: "0",
                    how_much_sucrose_1?: "0",
                    how_much_milk_fat?: "0",
                    how_much_milk_protein_ab?: "0"

      assert_rendered_outcome text: "The Meursing code for a product with this composition is 7000."
    end

    should "not render commodity code guidance for commodity_code of X" do
      add_responses how_much_starch_glucose?: "5",
                    how_much_sucrose_1?: "30",
                    how_much_milk_fat?: "70",
                    how_much_milk_protein_ab?: "0"

      assert_rendered_outcome text: "The product composition you indicated is not possible."
    end
  end
end
