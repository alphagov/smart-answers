require "test_helper"
require "support/flow_test_helper"
require "active_support/testing/time_helpers"

class EstimateSelfAssessmentPenaltiesFlowTest < ActiveSupport::TestCase
  include FlowTestHelper
  include ActiveSupport::Testing::TimeHelpers

  setup { testing_flow EstimateSelfAssessmentPenaltiesFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: which_year?" do
    setup { testing_node :which_year? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_submitted? for any response" do
        assert_next_node :how_submitted?, for_response: "2019-20"
      end
    end
  end

  context "question: how_submitted?" do
    setup do
      testing_node :how_submitted?
      add_responses which_year?: "2019-20"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of when_submitted? for any response" do
        assert_next_node :when_submitted?, for_response: "online"
      end
    end
  end

  context "question: when_submitted?" do
    setup do
      testing_node :when_submitted?
      add_responses which_year?: "2019-20",
                    how_submitted?: "online"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for submitted date before start of next tax year" do
        assert_invalid_response "2020-04-05"
      end

      should "be invalid for submitted date after the upper bounds tax date" do
        # Upper bounds tax date is the end of the tax year in two years time e.g. we're in 2021 so date is April 05 2023
        travel_to "2021-08-01"
        assert_invalid_response "2023-04-06"
      end
    end

    context "next_node" do
      should "have a next node of when_paid? for any valid response" do
        assert_next_node :when_paid?, for_response: "2020-04-06"
      end
    end
  end

  context "question: when_paid?" do
    setup do
      testing_node :when_paid?
      add_responses which_year?: "2019-20",
                    how_submitted?: "online",
                    when_submitted?: "2020-04-06"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if not in current tax year" do
        add_responses which_year?: "2018-19"
        assert_invalid_response "2020-04-05"
      end

      should "be invalid for submitted date after the upper bounds tax date" do
        add_responses which_year?: "2021-22",
                      when_submitted?: "2022-08-06"
        # Upper bounds repayment date is the end of the tax year in four years time e.g. we're in 2021 so date is April 05 2025
        travel_to "2021-08-01"
        assert_invalid_response "2025-04-06"
      end
    end

    context "next_node" do
      should "have a next node of filed_and_paid_on_time if paid on time" do
        assert_next_node :filed_and_paid_on_time, for_response: "2020-04-06"
      end

      should "have a next node of how_much_tax? if not paid on time" do
        assert_next_node :how_much_tax?, for_response: "2021-04-06"
      end
    end
  end

  context "question: how_much_tax?" do
    setup do
      testing_node :how_much_tax?
      add_responses which_year?: "2019-20",
                    how_submitted?: "online",
                    when_submitted?: "2020-04-06",
                    when_paid?: "2021-04-06"
    end

    should "render the question" do
      assert_rendered_question
    end

    should "have a next node of late for any response" do
      assert_next_node :late, for_response: "1.00"
    end
  end

  context "outcome: late" do
    setup do
      testing_node :late
      add_responses which_year?: "2019-20",
                    how_submitted?: "online",
                    when_submitted?: "2020-04-06",
                    when_paid?: "2021-05-06",
                    how_much_tax?: "1.00"
    end

    should "render 100% penalty text if payment is over year after penalty start date" do
      add_responses which_year?: "2018-19"
      assert_rendered_outcome text: "Your penalty can be up to 100% of your tax bill if you deliberately don’t pay it."
    end

    should "render 'none' if late filing penalty is zero" do
      add_responses when_paid?: "2021-04-06"
      assert_rendered_outcome text: "none"
    end
  end
end
