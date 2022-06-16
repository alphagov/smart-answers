require "test_helper"
require "support/flow_test_helper"

class CheckBenefitsSupportFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow CheckBenefitsSupportFlow
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: where_do_you_live" do
    setup { testing_node :where_do_you_live }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of over_state_pension_age" do
        assert_next_node :over_state_pension_age, for_response: "england"
      end
    end
  end

  context "question: over_state_pension_age" do
    setup do
      testing_node :over_state_pension_age
      add_responses where_do_you_live: "england"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of are_you_working" do
        assert_next_node :are_you_working, for_response: "yes"
      end
    end
  end

  context "question: are_you_working" do
    setup do
      testing_node :are_you_working
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of disability_or_health_condition" do
        assert_next_node :disability_or_health_condition, for_response: "yes_over_16_hours_per_week"
      end
    end
  end

  context "question: disability_or_health_condition" do
    setup do
      testing_node :disability_or_health_condition
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "yes_over_16_hours_per_week"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of carer_disability_or_health_condition if there is no conditon" do
        assert_next_node :carer_disability_or_health_condition, for_response: "no"
      end

      should "have a next node of disability_affecting_work if there is a conditon" do
        assert_next_node :disability_affecting_work, for_response: "yes"
      end
    end
  end

  context "question: disability_affecting_work" do
    setup do
      testing_node :disability_affecting_work
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "yes_over_16_hours_per_week",
                    disability_or_health_condition: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of carer_disability_or_health_condition" do
        assert_next_node :carer_disability_or_health_condition, for_response: "yes_limits_work"
      end
    end
  end

  context "question: carer_disability_or_health_condition" do
    setup do
      testing_node :carer_disability_or_health_condition
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "yes_over_16_hours_per_week",
                    disability_or_health_condition: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of children_living_with_you" do
        assert_next_node :children_living_with_you, for_response: "yes"
      end
    end
  end

  context "question: children_living_with_you" do
    setup do
      testing_node :children_living_with_you
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "yes_over_16_hours_per_week",
                    disability_or_health_condition: "no",
                    carer_disability_or_health_condition: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of age_of_children if there are children living with you" do
        assert_next_node :age_of_children, for_response: "yes"
      end

      should "have a next node of assets_and_savings if there are not children living with you" do
        assert_next_node :assets_and_savings, for_response: "no"
      end
    end
  end

  context "question: age_of_children" do
    setup do
      testing_node :age_of_children
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "yes_over_16_hours_per_week",
                    disability_or_health_condition: "no",
                    carer_disability_or_health_condition: "no",
                    children_living_with_you: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of children_with_disability" do
        assert_next_node :children_with_disability, for_response: "5_to_11"
      end
    end
  end

  context "question: children_with_disability" do
    setup do
      testing_node :children_with_disability
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "yes_over_16_hours_per_week",
                    disability_or_health_condition: "no",
                    carer_disability_or_health_condition: "no",
                    children_living_with_you: "yes",
                    age_of_children: "5_to_11"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of assets_and_savings" do
        assert_next_node :assets_and_savings, for_response: "yes"
      end
    end
  end

  context "question: assets_and_savings" do
    setup do
      testing_node :assets_and_savings
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "yes_over_16_hours_per_week",
                    disability_or_health_condition: "no",
                    carer_disability_or_health_condition: "no",
                    children_living_with_you: "yes",
                    age_of_children: "5_to_11",
                    children_with_disability: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of results" do
        assert_next_node :results, for_response: "under_16000"
      end
    end
  end

  context "outcome: results" do
    setup do
      testing_node :results
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "yes_over_16_hours_per_week",
                    disability_or_health_condition: "no",
                    carer_disability_or_health_condition: "no",
                    children_living_with_you: "yes",
                    age_of_children: "5_to_11",
                    children_with_disability: "yes",
                    assets_and_savings: "under_16000"
    end

    should "render the results outcome with number of eligible benefits" do
      assert_rendered_outcome text: "Based on your answers, you may be eligible for the following 9 things."
    end

    should "render Employment and Support Allowance when eligible" do
      %w[england scotland wales].each do |country|
        %w[no yes_under_16_hours_per_week].each do |work_hours|
          %w[yes_limits_work yes_unable_to_work].each do |work_limits|
            add_responses where_do_you_live: country,
                          over_state_pension_age: "no",
                          are_you_working: work_hours,
                          disability_or_health_condition: "yes",
                          disability_affecting_work: work_limits

            assert_rendered_outcome text: "Employment and Support Allowance (ESA)"
            assert_rendered_outcome text: "You may be able to apply for 'new style' Employment and Support Allowance (ESA) if you have a disability or health condition that affects how much you can work."
          end
        end
      end
    end

    should "render Employment and Support Allowance (NI) when eligible" do
      %w[no yes_under_16_hours_per_week].each do |work_hours|
        %w[yes_limits_work yes_unable_to_work].each do |work_limits|
          add_responses where_do_you_live: "northern-ireland",
                        over_state_pension_age: "no",
                        are_you_working: work_hours,
                        disability_or_health_condition: "yes",
                        disability_affecting_work: work_limits

          assert_rendered_outcome text: "Employment and Support Allowance (ESA)"
          assert_rendered_outcome text: "You may be able to apply for 'new style' Employment and Support Allowance (ESA) if you have a disability or health condition that affects how much you can work."
        end
      end
    end

    should "render Job Seekers Allowance when eligible" do
      %w[england scotland wales].each do |country|
        %w[no yes_under_16_hours_per_week].each do |work_hours|
          %w[yes_limits_work no].each do |work_limits|
            add_responses where_do_you_live: country,
                          over_state_pension_age: "no",
                          are_you_working: work_hours,
                          disability_or_health_condition: "yes",
                          disability_affecting_work: work_limits

            assert_rendered_outcome text: "Jobseeker's Allowance (JSA)"
            assert_rendered_outcome text: "Check if you’re eligible for New Style Jobseeker’s Allowance"
          end
        end
      end
    end

    should "render Job Seekers Allowance (NI) when eligible" do
      %w[no yes_under_16_hours_per_week].each do |work_hours|
        %w[yes_limits_work no].each do |work_limits|
          add_responses where_do_you_live: "northern-ireland",
                        over_state_pension_age: "no",
                        are_you_working: work_hours,
                        disability_or_health_condition: "yes",
                        disability_affecting_work: work_limits

          assert_rendered_outcome text: "Jobseeker's Allowance (JSA)"
          assert_rendered_outcome text: "Check if you’re eligible for New Style Jobseeker’s Allowance on the nidirect website"
        end
      end
    end

    should "render Pension Credit when eligible" do
      %w[england scotland wales].each do |country|
        add_responses where_do_you_live: country

        assert_rendered_outcome text: "Pension Credit"
        assert_rendered_outcome text: "Check if you’re eligible for Pension Credit"
      end
    end

    should "render Pension Credit (NI) when eligible" do
      add_responses where_do_you_live: "northern-ireland"

      assert_rendered_outcome text: "Pension Credit"
      assert_rendered_outcome text: "Check if you’re eligible for Pension Credit on the nidirect website"
    end

    should "render Housing Benefit when eligible" do
      %w[england wales].each do |country|
        add_responses where_do_you_live: country

        assert_rendered_outcome text: "Housing Benefit"
        assert_rendered_outcome text: "Check if you’re eligible for Housing Benefit"
      end
    end

    should "render Housing Benefit (Scotland) when eligible" do
      add_responses where_do_you_live: "scotland"

      assert_rendered_outcome text: "Housing Benefit"
      assert_rendered_outcome text: "Check if you’re eligible for Housing Benefit on the mygov.scot website"
    end

    should "render Housing Benefit (Northern Ireland) when eligible" do
      add_responses where_do_you_live: "northern-ireland"

      assert_rendered_outcome text: "Housing Benefit"
      assert_rendered_outcome text: "Check if you’re eligible for Housing Benefit on the NI Housing Executive website"
    end

    should "render Access to Work when eligible" do
      %w[england scotland wales].each do |country|
        %w[yes_limits_work no].each do |work_limits|
          add_responses where_do_you_live: country,
                        disability_or_health_condition: "yes",
                        disability_affecting_work: work_limits

          assert_rendered_outcome text: "Access to Work"
          assert_rendered_outcome text: "Check if you’re eligible for Access to Work"
        end
      end
    end

    should "render Access to Work (Northern Ireland) when eligible" do
      %w[yes_limits_work no].each do |work_limits|
        add_responses where_do_you_live: "northern-ireland",
                      disability_or_health_condition: "yes",
                      disability_affecting_work: work_limits

        assert_rendered_outcome text: "Access to Work"
        assert_rendered_outcome text: "Check if you’re eligible for Access to Work on the nidirect website"
      end
    end

    should "render Universal Credit when eligible" do
      %w[england scotland wales].each do |country|
        add_responses where_do_you_live: country,
                      over_state_pension_age: "no",
                      assets_and_savings: "under_16000"

        assert_rendered_outcome text: "Universal Credit"
        assert_rendered_outcome text: "Check if you’re eligible for Universal Credit"
      end
    end

    should "render Universal Credit (Northern Ireland) when eligible" do
      add_responses where_do_you_live: "northern-ireland",
                    over_state_pension_age: "no",
                    assets_and_savings: "under_16000"

      assert_rendered_outcome text: "Universal Credit"
      assert_rendered_outcome text: "Check if you’re eligible for Universal Credit on the nidirect website"
    end

    should "render Tax-free childcare when eligible without a disabled child" do
      %w[england scotland wales northern-ireland].each do |country|
        add_responses where_do_you_live: country,
                      children_with_disability: "no"

        assert_rendered_outcome text: "Tax-free childcare"
        assert_rendered_outcome text: "Check if you’re eligible for Tax-Free childcare"
      end
    end

    should "render Tax Free childcare when eligible with a disabled child" do
      %w[england scotland wales northern-ireland].each do |country|
        add_responses where_do_you_live: country,
                      age_of_children: "16_to_17"

        assert_rendered_outcome text: "Tax-free childcare"
        assert_rendered_outcome text: "Check if you’re eligible for Tax-Free childcare"
      end
    end
  end
end
