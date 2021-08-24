require "test_helper"
require "support/flow_test_helper"

class ReportALostOrStolenPassportFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow ReportALostOrStolenPassportFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: where_was_the_passport_lost_or_stolen?" do
    setup { testing_node :where_was_the_passport_lost_or_stolen? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of report_lost_or_stolen_passport for a 'in_the_uk' response" do
        assert_next_node :report_lost_or_stolen_passport, for_response: "in_the_uk"
      end

      should "have a next node of contact_the_embassy for a 'abroad' response" do
        assert_next_node :contact_the_embassy, for_response: "abroad"
      end
    end
  end
end
