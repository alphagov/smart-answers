require "test_helper"
require "support/flow_test_helper"

class CalculateInheritanceTaxInterestFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow CalculateInheritanceTaxInterestFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: start_date_for_interest?" do
    setup { testing_node :start_date_for_interest? }

    should "render the question" do
      assert_rendered_question
    end

    should "have a next node of end_date_for_interest? for any response" do
      assert_next_node :end_date_for_interest?, for_response: "2025-01-11"
    end

    context "validation" do
      should "be invalid for submitted date before the minimum date calculated" do
        # Lower bounds of our interest calculation table is 1988-10-06
        assert_invalid_response "1988-10-05"
      end
    end
  end

  context "question: end_date_for_interest?" do
    setup do
      testing_node :end_date_for_interest?
      add_responses start_date_for_interest?: "2025-01-11"
    end

    should "render the question" do
      assert_rendered_question
    end

    should "have a next node of how_much_inheritance_tax_owed? for any response" do
      assert_next_node :how_much_inheritance_tax_owed?, for_response: "2025-05-16"
    end

    context "validation" do
      should "be invalid for submitted date after 2100-01-01" do
        # This is the upper bounds of our interest calculation table
        assert_invalid_response "2100-01-02"
      end
    end
  end

  context "question: how_much_inheritance_tax_owed?" do
    setup do
      testing_node :how_much_inheritance_tax_owed?
      add_responses start_date_for_interest?: "2025-01-11",
                    end_date_for_interest?: "2025-05-16"
    end

    should "render the question" do
      assert_rendered_question
    end

    should "have a next node of inheritance_tax_interest for any response" do
      assert_next_node :inheritance_tax_interest, for_response: "30000"
    end
  end

  context "outcome: inheritance_tax_interest" do
    setup do
      testing_node :inheritance_tax_interest
      add_responses start_date_for_interest?: "2025-01-11",
                    end_date_for_interest?: "2025-05-16",
                    how_much_inheritance_tax_owed?: "30000"
    end

    should "render the outcome text" do
      assert_rendered_outcome
    end
  end
end
