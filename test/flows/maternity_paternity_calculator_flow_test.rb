require "test_helper"
require "support/flow_test_helper"

class MaternityPaternityCalculatorFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow MaternityPaternityCalculatorFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: what_type_of_leave?" do
    setup { testing_node :what_type_of_leave? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of baby_due_date_maternity? for a 'maternity' response" do
        assert_next_node :baby_due_date_maternity?, for_response: "maternity"
      end

      should "have a next node of where_does_the_employee_live? for a 'paternity' response" do
        assert_next_node :where_does_the_employee_live?, for_response: "paternity"
      end

      should "have a next node of taking_paternity_or_maternity_leave_for_adoption? for a 'adoption' response" do
        assert_next_node :taking_paternity_or_maternity_leave_for_adoption?, for_response: "adoption"
      end
    end
  end
end
