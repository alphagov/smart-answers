require "test_helper"
require "support/flow_test_helper"

class CheckBenefitsFinancialSupportFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow CheckBenefitsFinancialSupportFlow
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

      should "have a next node of on_benefits if there are not children living with you" do
        assert_next_node :on_benefits, for_response: "no"
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
        assert_next_node :children_with_disability, for_response: "5_to_7"
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
                    age_of_children: "5_to_7"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of on_benefits" do
        assert_next_node :on_benefits, for_response: "yes"
      end
    end
  end

  context "question: on_benefits" do
    setup do
      testing_node :on_benefits
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "yes_over_16_hours_per_week",
                    disability_or_health_condition: "no",
                    carer_disability_or_health_condition: "no",
                    children_living_with_you: "yes",
                    age_of_children: "5_to_7",
                    children_with_disability: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of current_benefits for yes" do
        assert_next_node :current_benefits, for_response: "yes"
      end

      should "have a next node of assets_and_savings for no" do
        assert_next_node :assets_and_savings, for_response: "no"
      end

      should "have a next node of assets_and_savings for dont_know" do
        assert_next_node :assets_and_savings, for_response: "dont_know"
      end
    end
  end

  context "question: current_benefits" do
    setup do
      testing_node :current_benefits
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "yes_over_16_hours_per_week",
                    disability_or_health_condition: "no",
                    carer_disability_or_health_condition: "no",
                    children_living_with_you: "yes",
                    age_of_children: "5_to_7",
                    children_with_disability: "yes",
                    on_benefits: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of assets_and_savings for universal_credit" do
        assert_next_node :assets_and_savings, for_response: "universal_credit"
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
                    age_of_children: "5_to_7",
                    children_with_disability: "yes",
                    on_benefits: "yes",
                    current_benefits: "universal_credit"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of results for under_16000" do
        assert_next_node :results, for_response: "under_16000"
      end

      should "have a next node of results for none" do
        assert_next_node :results, for_response: "none_16000"
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
                    age_of_children: "5_to_7",
                    children_with_disability: "yes",
                    on_benefits: "yes",
                    current_benefits: "universal_credit",
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

    should "render Free childcare 2 yr olds when eligible" do
      %w[england wales].each do |country|
        add_responses where_do_you_live: country,
                      children_living_with_you: "yes",
                      age_of_children: "2"

        assert_rendered_outcome text: "Free childcare for 2-year-olds"
        assert_rendered_outcome text: "Check if you’re eligible for free childcare for 2-year-olds"
      end
    end

    should "render Childcare 3 and 4 year olds Wales when eligible" do
      add_responses where_do_you_live: "wales",
                    are_you_working: "yes_over_16_hours_per_week",
                    children_living_with_you: "yes",
                    age_of_children: "3_to_4"

      assert_rendered_outcome text: "Childcare 3 and 4 year olds"
      assert_rendered_outcome text: "Find out how much free childcare you can get on the GOV.WALES website"
    end

    should "render 15 hours of free childcare for 3 and 4-year-olds when eligible" do
      add_responses where_do_you_live: "england",
                    children_living_with_you: "yes",
                    age_of_children: "3_to_4"

      assert_rendered_outcome text: "15 hours of free childcare for 3 and 4-year-olds"
      assert_rendered_outcome text: "Find out how to get free childcare for 3 and 4-year-olds"
    end

    should "render Funded early learning and childcare when eligible" do
      %w[2,3_to_4].each do |age|
        add_responses where_do_you_live: "scotland",
                      children_living_with_you: "yes",
                      age_of_children: age

        assert_rendered_outcome text: "Funded early learning and childcare"
        assert_rendered_outcome text: "Find out how much free childcare you can get on mygov.scot"
      end
    end

    should "render 30 hours of free childcare when eligible" do
      %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
        add_responses where_do_you_live: "england",
                      are_you_working: working_hours,
                      children_living_with_you: "yes",
                      age_of_children: "3_to_4"

        assert_rendered_outcome text: "30 hours of free childcare"
        assert_rendered_outcome text: "Check if you’re eligible for 30 hours free childcare"
      end
    end

    should "render Carer’s Allowance when eligible" do
      add_responses carer_disability_or_health_condition: "yes"

      assert_rendered_outcome text: "Carer’s Allowance"
      assert_rendered_outcome text: "Check if you’re eligible for Carer’s Allowance"
    end

    should "render Disability Living Allowance (DLA) for children when eligible" do
      %w[england northern-ireland wales].each do |country|
        %w[1_or_under 2 3_to_4 5_to_7 8_to_11 12_to_15].each do |age|
          add_responses where_do_you_live: country,
                        children_living_with_you: "yes",
                        age_of_children: age,
                        children_with_disability: "yes"

          assert_rendered_outcome text: "Disability Living Allowance (DLA) for children"
          assert_rendered_outcome text: "Check if you’re eligible for Disability Living Allowance (DLA) for children"
        end
      end
    end

    should "render Child Disability Payment when eligible" do
      %w[1_or_under 2 3_to_4 5_to_7 8_to_11 12_to_15].each do |age|
        add_responses where_do_you_live: "scotland",
                      children_living_with_you: "yes",
                      age_of_children: age,
                      children_with_disability: "yes"

        assert_rendered_outcome text: "Child Disability Payment"
        assert_rendered_outcome text: "Check if you’re eligible for Child Disability Payment on mygov.scot"
      end
    end

    should "render Personal Independence Payment (PIP) when eligible with a health condition" do
      %w[england scotland wales].each do |country|
        %w[no yes_limits_work yes_unable_to_work].each do |affecting_work|
          add_responses where_do_you_live: country,
                        over_state_pension_age: "no",
                        disability_or_health_condition: "yes",
                        disability_affecting_work: affecting_work

          assert_rendered_outcome text: "Personal Independence Payment (PIP)"
          assert_rendered_outcome text: "Check if you’re eligible for Personal Independence Payment"
        end
      end
    end

    should "render Personal Independence Payment (PIP) when eligible with a child with a health condition" do
      %w[england scotland wales].each do |country|
        %w[16_to_17 18_to_19].each do |age|
          add_responses where_do_you_live: country,
                        over_state_pension_age: "no",
                        disability_or_health_condition: "no",
                        children_living_with_you: "yes",
                        age_of_children: age,
                        children_with_disability: "yes"

          assert_rendered_outcome text: "Personal Independence Payment (PIP)"
          assert_rendered_outcome text: "Check if you’re eligible for Personal Independence Payment"
        end
      end
    end

    should "render Personal Independence Payment (PIP) (Northern Ireland) when eligible with a health condition" do
      %w[no yes_limits_work yes_unable_to_work].each do |affecting_work|
        add_responses where_do_you_live: "northern-ireland",
                      over_state_pension_age: "no",
                      disability_or_health_condition: "yes",
                      disability_affecting_work: affecting_work

        assert_rendered_outcome text: "Personal Independence Payment (PIP)"
        assert_rendered_outcome text: "Check if you’re eligible for Personal Independence Payment on the nidirect website"
      end
    end

    should "render Personal Independence Payment (PIP) (Northern Ireland) when eligible with a child with a health condition" do
      %w[16_to_17 18_to_19].each do |age|
        add_responses where_do_you_live: "northern-ireland",
                      over_state_pension_age: "no",
                      disability_or_health_condition: "no",
                      children_living_with_you: "yes",
                      age_of_children: age,
                      children_with_disability: "yes"

        assert_rendered_outcome text: "Personal Independence Payment (PIP)"
        assert_rendered_outcome text: "Check if you’re eligible for Personal Independence Payment on the nidirect website"
      end
    end

    should "render Attendance Allowance when eligible" do
      %w[england scotland wales northern-ireland].each do |country|
        %w[no yes_limits_work yes_unable_to_work].each do |affecting_work|
          add_responses where_do_you_live: country,
                        over_state_pension_age: "yes",
                        disability_or_health_condition: "yes",
                        disability_affecting_work: affecting_work

          assert_rendered_outcome text: "Attendance Allowance"
          assert_rendered_outcome text: "Check if you’re eligible for Attendance Allowance"
        end
      end
    end

    should "render Council Tax Reduction when eligible" do
      %w[england scotland wales].each do |country|
        add_responses where_do_you_live: country

        assert_rendered_outcome text: "Council Tax Reduction"
        assert_rendered_outcome text: "Check if you’re eligible for Council Tax Reduction"
      end
    end

    should "render Rate Relief when eligible" do
      add_responses where_do_you_live: "northern-ireland"

      assert_rendered_outcome text: "Rate Relief"
      assert_rendered_outcome text: "Check if you’re eligible for Rate Relief on the nidirect website"
    end

    should "render Child Benefit when eligible" do
      add_responses children_living_with_you: "yes"

      assert_rendered_outcome text: "Child Benefit"
      assert_rendered_outcome text: "Check if you’re eligible for Child Benefit"
    end

    should "render Free TV Licence when eligible" do
      add_responses over_state_pension_age: "yes"

      assert_rendered_outcome text: "Get a free or discounted TV licence"
      assert_rendered_outcome text: "Check if you’re eligible for a free or discounted TV licence"
    end

    should "render Budgeting Loan when eligible" do
      %w[england scotland wales].each do |country|
        add_responses where_do_you_live: country

        assert_rendered_outcome text: "Budgeting Loan"
        assert_rendered_outcome text: "Check if you’re eligible for a Budgeting Loan"
      end
    end

    should "render Social Fund Budgeting Loan when eligible" do
      add_responses where_do_you_live: "northern-ireland"

      assert_rendered_outcome text: "Social Fund Budgeting Loan"
      assert_rendered_outcome text: "Check if you’re eligible for a Budgeting Loan on the nidirect website"
    end

    should "render NHS Low Income Scheme when eligible" do
      %w[england wales].each do |country|
        add_responses where_do_you_live: country,
                      assets_and_savings: "under_16000"

        assert_rendered_outcome text: "NHS Low Income Scheme"
        assert_rendered_outcome text: "Check if you’re eligible for the NHS Low Income Scheme on the NHS website"
      end
    end

    should "render Help With Health Costs Loan when eligible" do
      add_responses where_do_you_live: "scotland"

      assert_rendered_outcome text: "Help With Health Costs"
      assert_rendered_outcome text: "Check if you’re eligible for help with health costs on the NHS Inform (Scotland) website"
    end

    should "render NHS Low Income Scheme (Northern Ireland) when eligible" do
      add_responses where_do_you_live: "northern-ireland"

      assert_rendered_outcome text: "NHS Low Income Scheme"
      assert_rendered_outcome text: "Check if you’re eligible for the NHS Low Income Scheme on the nidirect website"
    end

    should "render maternity allowance for eligible countries" do
      %w[england scotland wales northern-ireland].each do |country|
        add_responses where_do_you_live: country,
                      children_living_with_you: "yes",
                      over_state_pension_age: "no",
                      age_of_children: "1_or_under"

        assert_rendered_outcome text: "Maternity Allowance"
        assert_rendered_outcome text: "You may be eligible to get Maternity Allowance for 39 weeks if you’re employed"
      end
    end

    should "render Sure Start Maternity Grant for eligible countries" do
      %w[england wales northern-ireland].each do |country|
        add_responses where_do_you_live: country,
                      children_living_with_you: "yes",
                      age_of_children: "1_or_under",
                      on_benefits: "yes",
                      current_benefits: "universal_credit"

        assert_rendered_outcome text: "Sure Start Maternity Grant"
        assert_rendered_outcome text: "If you or your partner get certain benefits you could get a one-off payment of £500"
      end
    end

    should "render Pregnancy and Baby Payment [Scotland] for eligible countries" do
      add_responses where_do_you_live: "scotland",
                    children_living_with_you: "yes",
                    age_of_children: "1_or_under",
                    on_benefits: "yes",
                    current_benefits: "universal_credit"

      assert_rendered_outcome text: "Pregnancy and Baby Payment"
      assert_rendered_outcome text: "If you or your partner get certain benefits you could get a one-off payment"
    end
  end
end
