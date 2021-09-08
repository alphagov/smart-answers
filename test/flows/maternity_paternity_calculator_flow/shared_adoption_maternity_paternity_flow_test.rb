require "test_helper"
require "support/flow_test_helper"
require "support/flows/maternity_paternity_calculator_flow_test_helper"

class MaternityPaternityCalculatorFlow::SharedAdoptionMaternityPaternityFlowTest < ActiveSupport::TestCase
  include FlowTestHelper
  include MaternityPaternityCalculatorFlowTestHelper

  setup { testing_flow MaternityPaternityCalculatorFlow }

  context "question: how_many_payments_weekly?" do
    setup { testing_node :how_many_payments_weekly? }

    should "render the question" do
      add_responses maternity_adoption_responses(up_to: :earnings_for_pay_period_adoption?, pay_frequency: "weekly")
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_do_you_want_the_sap_calculated? for an adoption flow" do
        add_responses maternity_adoption_responses(up_to: :earnings_for_pay_period_adoption?, pay_frequency: "weekly")
        assert_next_node :how_do_you_want_the_sap_calculated?, for_response: "8"
      end

      should "have a next node of how_do_you_want_the_smp_calculated? for a maternity flow" do
        add_responses maternity_responses(up_to: :earnings_for_pay_period?, pay_frequency: "weekly")
        assert_next_node :how_do_you_want_the_smp_calculated?, for_response: "8"
      end

      should "have a next node of how_do_you_want_the_spp_calculated? for a paternity flow" do
        add_responses paternity_responses(up_to: :earnings_for_pay_period_paternity?, pay_frequency: "weekly")
        assert_next_node :how_do_you_want_the_spp_calculated?, for_response: "8"
      end
    end
  end

  context "question: how_many_payments_every_2_weeks?" do
    setup { testing_node :how_many_payments_every_2_weeks? }

    should "render the question" do
      add_responses maternity_adoption_responses(up_to: :earnings_for_pay_period_adoption?, pay_frequency: "every_2_weeks")
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_do_you_want_the_sap_calculated? for an adoption flow" do
        add_responses maternity_adoption_responses(up_to: :earnings_for_pay_period_adoption?, pay_frequency: "every_2_weeks")
        assert_next_node :how_do_you_want_the_sap_calculated?, for_response: "4"
      end

      should "have a next node of how_do_you_want_the_smp_calculated? for a maternity flow" do
        add_responses maternity_responses(up_to: :earnings_for_pay_period?, pay_frequency: "every_2_weeks")
        assert_next_node :how_do_you_want_the_smp_calculated?, for_response: "4"
      end

      should "have a next node of how_do_you_want_the_spp_calculated? for a paternity flow" do
        add_responses paternity_responses(up_to: :earnings_for_pay_period_paternity?, pay_frequency: "every_2_weeks")
        assert_next_node :how_do_you_want_the_spp_calculated?, for_response: "4"
      end
    end
  end

  context "question: how_many_payments_every_4_weeks?" do
    setup { testing_node :how_many_payments_every_4_weeks? }

    should "render the question" do
      add_responses maternity_adoption_responses(up_to: :earnings_for_pay_period_adoption?, pay_frequency: "every_4_weeks")
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_do_you_want_the_sap_calculated? for an adoption flow" do
        add_responses maternity_adoption_responses(up_to: :earnings_for_pay_period_adoption?, pay_frequency: "every_4_weeks")
        assert_next_node :how_do_you_want_the_sap_calculated?, for_response: "1"
      end

      should "have a next node of how_do_you_want_the_smp_calculated? for a maternity flow" do
        add_responses maternity_responses(up_to: :earnings_for_pay_period?, pay_frequency: "every_4_weeks")
        assert_next_node :how_do_you_want_the_smp_calculated?, for_response: "1"
      end

      should "have a next node of how_do_you_want_the_spp_calculated? for a paternity flow" do
        add_responses paternity_responses(up_to: :earnings_for_pay_period_paternity?, pay_frequency: "every_4_weeks")
        assert_next_node :how_do_you_want_the_spp_calculated?, for_response: "1"
      end
    end
  end

  context "question: how_many_payments_monthly?" do
    setup { testing_node :how_many_payments_monthly? }

    should "render the question" do
      add_responses maternity_adoption_responses(up_to: :earnings_for_pay_period_adoption?, pay_frequency: "monthly")
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_do_you_want_the_sap_calculated? for an adoption flow" do
        add_responses maternity_adoption_responses(up_to: :earnings_for_pay_period_adoption?, pay_frequency: "monthly")
        assert_next_node :how_do_you_want_the_sap_calculated?, for_response: "2"
      end

      should "have a next node of how_do_you_want_the_smp_calculated? for a maternity flow" do
        add_responses maternity_responses(up_to: :earnings_for_pay_period?, pay_frequency: "monthly")
        assert_next_node :how_do_you_want_the_smp_calculated?, for_response: "2"
      end

      should "have a next node of how_do_you_want_the_spp_calculated? for a paternity flow" do
        add_responses paternity_responses(up_to: :earnings_for_pay_period_paternity?, pay_frequency: "monthly")
        assert_next_node :how_do_you_want_the_spp_calculated?, for_response: "2"
      end
    end
  end
end
