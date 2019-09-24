require_relative "../../test_helper"
require_relative "flow_unit_test_helper"
require_relative "test_node"

require "smart_answer_flows/maternity-paternity-calculator/adoption_calculator_flow"

module SmartAnswer
  class AdoptionCalculatorFlowTest < ActiveSupport::TestCase
    include FlowUnitTestHelper

    setup do
      @flow = MaternityPaternityCalculatorFlow::AdoptionCalculatorFlow.build
    end

    should "start taking_paternity_or_maternity_leave_for_adoption? question" do
      assert_equal :taking_paternity_or_maternity_leave_for_adoption?, @flow.start_state.current_node
    end

    context "when answering taking_paternity_or_maternity_leave_for_adoption?" do
      setup do
        @question = TestNode.new(@flow, :taking_paternity_or_maternity_leave_for_adoption?)
          .with_stubbed_calculator
      end

      should "respond to 'maternity' with adoption_is_from_overseas?" do
        @question.answer_with("maternity")
        assert_node_has_name(:adoption_is_from_overseas?, @question.next_node)
      end

      should "respond to 'paternity' with employee_date_matched_paternity_adoption?" do
        @question.answer_with("paternity")
        assert_node_has_name(:employee_date_matched_paternity_adoption?, @question.next_node, belongs_to_another_flow: true)
      end
    end

    context "when answering adoption_is_from_overseas?" do
      setup do
        @question = TestNode.new(@flow, :adoption_is_from_overseas?)
      end

      should "respond with date_of_adoption_match?" do
        @question.answer_with("no")
        assert_node_has_name(:date_of_adoption_match?, @question.next_node)
      end

      should "set adoption_is_from_overseas to true when answering with 'yes'" do
        @question.answer_with("yes")
        assert(@question.next_node.adoption_is_from_overseas)
      end

      should "set adoption_is_from_overseas to false when answering with 'no'" do
        @question.answer_with("no")
        refute(@question.next_node.adoption_is_from_overseas)
      end
    end

    context "when answering date_of_adoption_match?" do
      setup do
        @question = TestNode.new(@flow, :date_of_adoption_match?)
          .with_stubbed_calculator
      end

      should "ask date_of_adoption_placement? next" do
        @question.answer_with(Date.today)
        assert_node_has_name(:date_of_adoption_placement?, @question.next_node)
      end
    end

    context "when answering date_of_adoption_placement?" do
      setup do
        @question = TestNode.new(@flow, :date_of_adoption_placement?)
          .with_stubbed_calculator
          .with(match_date: Date.parse("1 October 2017"))
      end

      context "with an adoption from the UK" do
        setup do
          @question.with(adoption_is_from_overseas: false)
        end

        should "ask adoption_did_the_employee_work_for_you? next" do
          @question.answer_with(Date.today)
          assert_node_has_name(:adoption_did_the_employee_work_for_you?, @question.next_node)
        end

        context "with a placement date of 15 November 2017" do
          setup do
            @question.answer_with(Date.parse("15 November 2017"))
          end

          should "have an earliest leave start date 14 days prior" do
            assert_equal(Date.parse("1 November 2017"), @question.next_node.a_leave_earliest_start)
          end

          should "have a latest start date 1 day after placement" do
            assert_equal(Date.parse("16 November 2017"), @question.next_node.a_leave_latest_start)
          end
        end
      end

      context "with an adoption from overseas and the child entering the UK on 1 November 2017" do
        setup do
          @question.with(adoption_is_from_overseas: true)
            .answer_with(Date.parse("1 November 2017"))
        end

        should "ask adoption_date_leave_starts next" do
          assert_node_has_name(:adoption_date_leave_starts?, @question.next_node)
        end

        should "have an earliest start date of 1 November 2017" do
          assert_equal(Date.parse("1 November 2017"), @question.next_node.a_leave_earliest_start)
        end

        should "have a latest start date of 28 November 2017" do
          assert_equal(Date.parse("28 November 2017"), @question.next_node.a_leave_latest_start)
        end
      end
    end

    context "when answering adoption_did_the_employee_work_for_you?" do
      context "with an adoption from the uk" do
        setup do
          @question = TestNode.new(@flow, :adoption_did_the_employee_work_for_you?)
          @question.with(adoption_is_from_overseas: false)
        end

        should "respond to 'yes' with adoption_employment_contract?" do
          @question.answer_with("yes")
          assert_node_has_name(:adoption_employment_contract?, @question.next_node)
        end

        should "respond to 'no' with adoption_not_entitled_to_leave_or_pay" do
          @question.answer_with("no")
          assert_node_has_name(:adoption_not_entitled_to_leave_or_pay, @question.next_node)
        end
      end

      context "with an adoption from overseas" do
        setup do
          @question = TestNode.new(@flow, :adoption_did_the_employee_work_for_you?)
          @question.with(adoption_is_from_overseas: true)
        end

        should "respond to 'yes' with adoption_is_the_employee_on_your_payroll?" do
          @question.answer_with("yes")
          assert_node_has_name(:adoption_is_the_employee_on_your_payroll?, @question.next_node)
        end

        should "respond to 'no' with adoption_not_entitled_to_leave_or_pay" do
          @question.answer_with("no")
          assert_node_has_name(:adoption_not_entitled_to_leave_or_pay, @question.next_node)
        end
      end
    end

    context "when answering adoption_employment_contract?" do
      context "with an adoption from the UK" do
        setup do
          @question = TestNode.new(@flow, :adoption_employment_contract?)
            .with_stubbed_calculator
          @question.with(adoption_is_from_overseas: false)
        end

        should "respond with adoption_is_the_employee_on_your_payroll?" do
          @question.answer_with("yes")
          assert_node_has_name(:adoption_is_the_employee_on_your_payroll?, @question.next_node)
        end
      end

      context "with an adoption from overseas" do
        setup do
          @question = TestNode.new(@flow, :adoption_employment_contract?)
            .with_stubbed_calculator
          @question.with(adoption_is_from_overseas: true)
        end

        should "respond with adoption_did_the_employee_work_for_you?" do
          @question.answer_with("yes")
          assert_node_has_name(:adoption_did_the_employee_work_for_you?, @question.next_node)
        end
      end
    end

    context "when answering adoption_is_the_employee_on_your_payroll?" do
      context "with an adoption from the UK" do
        setup do
          @question = TestNode.new(@flow, :adoption_is_the_employee_on_your_payroll?)
            .with_stubbed_calculator(matched_week: [])
          @question.with(adoption_is_from_overseas: false)
        end

        should "respond to no contract and not on the payroll with 'adoption_not_entitled_to_leave_or_pay'" do
          @question
            .with_stubbed_calculator(no_contract_not_on_payroll?: true)
            .answer_with("no")

          assert_node_has_name(:adoption_not_entitled_to_leave_or_pay, @question.next_node)
        end

        should "respond to no contract and is on the payroll with adoption_date_leave_starts?" do
          @question
            .with_stubbed_calculator(no_contract_not_on_payroll?: false)
            .answer_with("yes")

          assert_node_has_name(:adoption_date_leave_starts?, @question.next_node)
        end
      end

      context "with an adoption from overseas" do
        setup do
          @question = TestNode.new(@flow, :adoption_is_the_employee_on_your_payroll?)
            .with_stubbed_calculator(matched_week: [])
          @question.with(adoption_is_from_overseas: true)
        end

        should "respond to no contract and not on the payroll with 'adoption_not_entitled_to_leave_or_pay'" do
          @question
            .with_stubbed_calculator(no_contract_not_on_payroll?: true)
            .answer_with("no")

          assert_node_has_name(:adoption_not_entitled_to_leave_or_pay, @question.next_node)
        end

        should "respond to no contract and is on the payroll with last_normal_payday_adoption?" do
          @question
            .with_stubbed_calculator(no_contract_not_on_payroll?: false)
            .answer_with("yes")

          assert_node_has_name(:last_normal_payday_adoption?, @question.next_node)
        end
      end
    end

    context "when answering adoption_date_leave_starts?" do
      context "with valid dates" do
        setup do
          @question = TestNode.new(@flow, :adoption_date_leave_starts?)
          @question
              .with(a_leave_earliest_start: Date.parse("1 November 2017"))
              .with(a_leave_latest_start: Date.parse("16 November 2017"))
              .answer_with(Date.parse("15 November 2017"))
        end

        context "with an adoption from the UK" do
          setup do
            @question.with(adoption_is_from_overseas: false)
          end

          should "respond to having a contract and not being on the payroll with adoption_leave_and_pay" do
            @question.with_stubbed_calculator(has_contract_not_on_payroll?: true)
            assert_node_has_name(:adoption_leave_and_pay, @question.next_node)
          end

          should "respond to having no contract and not being on the payroll with last_normal_payday_adoption?" do
            @question.with_stubbed_calculator(has_contract_not_on_payroll?: false)
            assert_node_has_name(:last_normal_payday_adoption?, @question.next_node)
          end
        end

        context "with an adoption from overseas" do
          setup do
            @question.with(adoption_is_from_overseas: true)
          end

          should "respond with adoption_employment_contract" do
            @question.with_stubbed_calculator(has_contract_not_on_payroll?: true)
            assert_node_has_name(:adoption_employment_contract?, @question.next_node)
          end
        end
      end

      context "with invalid dates" do
        setup do
          @question = TestNode.new(@flow, :adoption_date_leave_starts?)
          @question
            .with_stubbed_calculator
            .with(a_leave_earliest_start: Date.parse("2 November 2017"))
            .with(a_leave_latest_start: Date.parse("29 November 2017"))
          @question.with(adoption_is_from_overseas: true)
        end

        should "raise an InvalidResponse when leave starts before the earliest date" do
          @question.answer_with(Date.parse("1 November 2017"))
          error = assert_raises(SmartAnswer::InvalidResponse) { @question.next_node }
          assert_equal "leave_starts_too_early", error.message
        end

        should "raise an InvalidResponse when leave starts after the latest date" do
          @question.answer_with(Date.parse("30 November 2017"))
          error = assert_raises(SmartAnswer::InvalidResponse) { @question.next_node }
          assert_equal "leave_starts_too_late", error.message
        end
      end
    end

    context "when answering last_normal_payday_adoption?" do
      setup do
        @question = TestNode.new(@flow, :last_normal_payday_adoption?)
          .with_stubbed_calculator
          .with(to_saturday: Date.today)
      end

      should "ask payday_eight_weeks_adoption?" do
        @question.answer_with(Date.yesterday)
        assert_node_has_name(:payday_eight_weeks_adoption?, @question.next_node)
      end
    end

    context "when answering payday_eight_weeks_adoption?" do
      setup do
        @question = TestNode.new(@flow, :payday_eight_weeks_adoption?)
          .with_stubbed_calculator(payday_offset: Date.today)
      end

      should "ask pay_frequency_adoption?" do
        @question.answer_with(Date.yesterday)
        assert_node_has_name(:pay_frequency_adoption?, @question.next_node)
      end
    end

    context "when answering pay_frequency_adoption?" do
      setup do
        @question = TestNode.new(@flow, :pay_frequency_adoption?)
          .with_stubbed_calculator
      end

      should "ask earnings_for_pay_period_adoption?" do
        @question.answer_with("weekly")
        assert_node_has_name(:earnings_for_pay_period_adoption?, @question.next_node)
      end
    end

    context "when answering earnings_for_pay_period_adoption?" do
      setup do
        @question = TestNode.new(@flow, :earnings_for_pay_period_adoption?)
          .answer_with(100)
          .with_stubbed_calculator(lower_earning_limit: 200)
      end

      should "respond to under the lower earning limit with adoption_leave_and_pay" do
        @question.with_stubbed_calculator(average_weekly_earnings_under_lower_earning_limit?: true)
        assert_node_has_name(:adoption_leave_and_pay, @question.next_node)
      end

      should "respond to weekly pay with how_many_payments_weekly?" do
        @question.with_stubbed_calculator(weekly?: true)
        assert_node_has_name(:how_many_payments_weekly?, @question.next_node, belongs_to_another_flow: true)
      end

      should "respond to fortnightly pay with how_many_payments_every_2_weeks?" do
        @question.with_stubbed_calculator(every_2_weeks?: true)
        assert_node_has_name(:how_many_payments_every_2_weeks?, @question.next_node, belongs_to_another_flow: true)
      end

      should "respond to pay every four weeks with how_many_payments_every_4_weeks?" do
        @question.with_stubbed_calculator(every_4_weeks?: true)
        assert_node_has_name(:how_many_payments_every_4_weeks?, @question.next_node, belongs_to_another_flow: true)
      end

      should "respond to monthly pay with how_many_payments_monthly?" do
        @question.with_stubbed_calculator(monthly?: true)
        assert_node_has_name(:how_many_payments_monthly?, @question.next_node, belongs_to_another_flow: true)
      end

      should "respond to other pay periods with how_do_you_want_the_sap_calculated?" do
        assert_node_has_name(:how_do_you_want_the_sap_calculated?, @question.next_node)
      end
    end

    context "when answering how_do_you_want_the_sap_calculated?" do
      setup do
        @question = TestNode.new(@flow, :how_do_you_want_the_sap_calculated?)
          .with_stubbed_calculator
      end

      should "respond to 'weekly_starting' with adoption_leave_and_pay" do
        @question.answer_with("weekly_starting")
        assert_node_has_name(:adoption_leave_and_pay, @question.next_node)
      end

      context "answering with 'usual_paydates'" do
        setup do
          @question.answer_with("usual_paydates")
        end

        should "respond to monthly pay with monthly_pay_paternity?" do
          @question.with_stubbed_calculator(pay_pattern: "monthly")
          assert_node_has_name(:monthly_pay_paternity?, @question.next_node, belongs_to_another_flow: true)
        end

        should "respond to non-monthly pay with next_pay_day_paternity?" do
          @question.with_stubbed_calculator(pay_pattern: "weekly")
          assert_node_has_name(:next_pay_day_paternity?, @question.next_node, belongs_to_another_flow: true)
        end
      end
    end
  end
end
