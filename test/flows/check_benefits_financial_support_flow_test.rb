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
      should "have a next node of how_many_paid_hours_work if working" do
        assert_next_node :how_many_paid_hours_work, for_response: "yes"
      end

      should "have a next node of disability_or_health_condition if not working" do
        assert_next_node :disability_or_health_condition, for_response: "no"
      end
    end
  end

  context "question: how_many_paid_hours_work" do
    setup do
      testing_node :how_many_paid_hours_work
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of disability_or_health_condition" do
        assert_next_node :disability_or_health_condition, for_response: "sixteen_or_more_per_week"
      end
    end
  end

  context "question: disability_or_health_condition" do
    setup do
      testing_node :disability_or_health_condition
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of carer_disability_or_health_condition if there is no conditon" do
        assert_next_node :carer_disability_or_health_condition, for_response: "no"
      end

      should "have a next node of disability_affecting_daily_tasks if there is a conditon" do
        assert_next_node :disability_affecting_daily_tasks, for_response: "yes"
      end
    end
  end

  context "question: disability_affecting_daily_tasks" do
    setup do
      testing_node :disability_affecting_daily_tasks
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "no",
                    disability_or_health_condition: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of disability_affecting_work" do
        assert_next_node :disability_affecting_work, for_response: "no"
      end
    end
  end

  context "question: disability_affecting_work" do
    setup do
      testing_node :disability_affecting_work
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "no",
                    disability_or_health_condition: "yes",
                    disability_affecting_daily_tasks: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of carer_disability_or_health_condition" do
        assert_next_node :carer_disability_or_health_condition, for_response: "no"
      end
    end
  end

  context "question: carer_disability_or_health_condition" do
    setup do
      testing_node :carer_disability_or_health_condition
      add_responses where_do_you_live: "england",
                    over_state_pension_age: "yes",
                    are_you_working: "no",
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
                    are_you_working: "no",
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
                    are_you_working: "no",
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
                    are_you_working: "no",
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
                    are_you_working: "no",
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
                    are_you_working: "no",
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
                    are_you_working: "no",
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
                    are_you_working: "yes",
                    how_many_paid_hours_work: "sixteen_or_less_per_week",
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
      assert_rendered_outcome text: "Based on your answers, you may be eligible for the following 14 things."
    end

    should "render Employment and Support Allowance when eligible" do
      %w[england scotland wales].each do |country|
        %w[no yes].each do |working|
          %w[sixteen_or_more_per_week sixteen_or_less_per_week].each do |working_hours|
            %w[yes no].each do |daily_tasks_limits|
              %w[yes_unable_to_work yes_limits_work].each do |work_limits|
                add_responses where_do_you_live: country,
                              over_state_pension_age: "no",
                              are_you_working: working,
                              how_many_paid_hours_work: working_hours,
                              disability_or_health_condition: "yes",
                              disability_affecting_daily_tasks: daily_tasks_limits,
                              disability_affecting_work: work_limits

                assert_rendered_outcome text: "Employment and Support Allowance (ESA)"
                assert_rendered_outcome text: "You may be able to apply for 'new style' Employment and Support Allowance (ESA) if you have a disability or health condition that affects how much you can work."
              end
            end
          end
        end
      end
    end

    should "render Employment and Support Allowance (NI) when eligible" do
      %w[no yes].each do |working|
        %w[sixteen_or_more_per_week sixteen_or_less_per_week].each do |working_hours|
          %w[yes no].each do |daily_tasks_limits|
            %w[yes_unable_to_work yes_limits_work].each do |work_limits|
              add_responses where_do_you_live: "northern-ireland",
                            over_state_pension_age: "no",
                            are_you_working: working,
                            how_many_paid_hours_work: working_hours,
                            disability_or_health_condition: "yes",
                            disability_affecting_daily_tasks: daily_tasks_limits,
                            disability_affecting_work: work_limits

              assert_rendered_outcome text: "Employment and Support Allowance (ESA)"
              assert_rendered_outcome text: "You may be able to apply for 'new style' Employment and Support Allowance (ESA) if you have a disability or health condition that affects how much you can work."
            end
          end
        end
      end
    end

    should "render Job Seekers Allowance when eligible (in paid work)" do
      %w[england scotland wales].each do |country|
        %w[no yes].each do |disability_affecting_daily_tasks|
          %w[yes_limits_work no].each do |work_limits|
            add_responses where_do_you_live: country,
                          over_state_pension_age: "no",
                          disability_or_health_condition: "yes",
                          disability_affecting_daily_tasks:,
                          disability_affecting_work: work_limits

            assert_rendered_outcome text: "Jobseeker's Allowance (JSA)"
            assert_rendered_outcome text: "Check if you’re eligible for New Style Jobseeker’s Allowance"
          end
        end
      end
    end

    should "render Job Seekers Allowance when eligible (not in paid work)" do
      %w[england scotland wales].each do |country|
        %w[no yes].each do |disability_affecting_daily_tasks|
          %w[yes_limits_work no].each do |work_limits|
            add_responses where_do_you_live: country,
                          over_state_pension_age: "no",
                          are_you_working: "no",
                          disability_or_health_condition: "yes",
                          disability_affecting_daily_tasks:,
                          disability_affecting_work: work_limits

            assert_rendered_outcome text: "Jobseeker's Allowance (JSA)"
            assert_rendered_outcome text: "Check if you’re eligible for New Style Jobseeker’s Allowance"
          end
        end
      end
    end

    should "render Job Seekers Allowance (NI) when eligible (in paid work)" do
      %w[no yes].each do |disability_affecting_daily_tasks|
        %w[yes_limits_work no].each do |work_limits|
          add_responses where_do_you_live: "northern-ireland",
                        over_state_pension_age: "no",
                        disability_or_health_condition: "yes",
                        disability_affecting_daily_tasks:,
                        disability_affecting_work: work_limits

          assert_rendered_outcome text: "Jobseeker's Allowance (JSA)"
          assert_rendered_outcome text: "Check if you’re eligible for New Style Jobseeker’s Allowance on the nidirect website"
        end
      end
    end

    should "render Job Seekers Allowance (NI) when eligible (not in paid work)" do
      %w[no yes].each do |disability_affecting_daily_tasks|
        %w[yes_limits_work no].each do |work_limits|
          add_responses where_do_you_live: "northern-ireland",
                        over_state_pension_age: "no",
                        are_you_working: "no",
                        disability_or_health_condition: "yes",
                        disability_affecting_daily_tasks:,
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
                        disability_affecting_daily_tasks: "no",
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
                      disability_affecting_daily_tasks: "no",
                      disability_affecting_work: work_limits

        assert_rendered_outcome text: "Access to Work"
        assert_rendered_outcome text: "Check if you’re eligible for Access to Work on the nidirect website"
      end
    end

    should "render Universal Credit when eligible" do
      %w[england scotland wales].each do |country|
        add_responses where_do_you_live: country,
                      over_state_pension_age: "no",
                      assets_and_savings: "under_16000",
                      on_benefits: "no"

        assert_rendered_outcome text: "Universal Credit"
        assert_rendered_outcome text: "Check if you’re eligible for Universal Credit"
      end
    end

    should "render Universal Credit (Northern Ireland) when eligible" do
      add_responses where_do_you_live: "northern-ireland",
                    over_state_pension_age: "no",
                    assets_and_savings: "under_16000",
                    on_benefits: "yes",
                    current_benefits: "housing_benefit"

      assert_rendered_outcome text: "Universal Credit"
      assert_rendered_outcome text: "Check if you’re eligible for Universal Credit on the nidirect website"
    end

    should "render Scottish Child Payment when eligible" do
      add_responses where_do_you_live: "scotland",
                    children_living_with_you: "yes",
                    age_of_children: "2",
                    on_benefits: "yes",
                    current_benefits: "pension_credit"

      assert_rendered_outcome text: "Scottish Child Payment"
      assert_rendered_outcome text: "Check if you're eligible for Scottish Child Payment and how to apply on the mygov.scot website"
    end

    should "render Tax-free childcare when eligible without a disabled child" do
      %w[england scotland wales northern-ireland].each do |country|
        add_responses where_do_you_live: country,
                      children_with_disability: "no"

        assert_rendered_outcome text: "Tax-Free Childcare"
        assert_rendered_outcome text: "Check if you’re eligible for Tax-Free Childcare"
      end
    end

    should "render Tax Free childcare when eligible with a disabled child" do
      %w[england scotland wales northern-ireland].each do |country|
        add_responses where_do_you_live: country,
                      age_of_children: "16_to_17"

        assert_rendered_outcome text: "Tax-Free Childcare"
        assert_rendered_outcome text: "up to £4,000 if a child is disabled."
      end
    end

    should "render Free childcare 2 yr olds when eligible" do
      add_responses where_do_you_live: "england",
                    children_living_with_you: "yes",
                    age_of_children: "2",
                    on_benefits: "yes",
                    current_benefits: "pension_credit"

      assert_rendered_outcome text: "Free childcare for 2-year-olds"
      assert_rendered_outcome text: "Check if you’re eligible for free childcare for 2-year-olds"
    end

    should "render Free childcare 2 yr olds when eligible [Wales]" do
      add_responses where_do_you_live: "wales",
                    children_living_with_you: "yes",
                    age_of_children: "2",
                    on_benefits: "dont_know"

      assert_rendered_outcome text: "Free childcare for 2-year-olds"
      assert_rendered_outcome text: "Check if you’re eligible for free childcare for 2-year-olds"
    end

    should "render Childcare 3 and 4 year olds Wales when eligible" do
      add_responses where_do_you_live: "wales",
                    children_living_with_you: "yes",
                    age_of_children: "3_to_4"

      assert_rendered_outcome text: "Childcare for 3 and 4-year-olds"
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

    should "render free childcare if you’re working when eligible" do
      %w[1_or_under,2,3_to_4].each do |age|
        add_responses where_do_you_live: "england",
                      children_living_with_you: "yes",
                      age_of_children: age

        assert_rendered_outcome text: "Free childcare if you’re working"
        assert_rendered_outcome text: "Check if you’re eligible for free childcare if you're working"
      end
    end

    should "render Winter Fuel Payment" do
      %w[england wales].each do |country|
        add_responses where_do_you_live: country, over_state_pension_age: "yes"

        assert_rendered_outcome text: "Winter Fuel Payment"
        assert_rendered_outcome text: "You'll automatically get a Winter Fuel Payment if you’ve reached State Pension age."
        assert_rendered_outcome text: "If your taxable income is over £35,000, HMRC will take back your Winter Fuel Payment through the tax system."
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
      %w[england wales].each do |country|
        %w[no yes_limits_work yes_unable_to_work].each do |affecting_work|
          add_responses where_do_you_live: country,
                        over_state_pension_age: "no",
                        disability_or_health_condition: "yes",
                        disability_affecting_daily_tasks: "no",
                        disability_affecting_work: affecting_work

          assert_rendered_outcome text: "Personal Independence Payment (PIP)"
          assert_rendered_outcome text: "Check if you’re eligible for Personal Independence Payment"
        end
      end
    end

    should "render Personal Independence Payment (PIP) when eligible with a child with a health condition" do
      %w[england wales].each do |country|
        %w[16_to_17 18_to_19].each do |age|
          add_responses where_do_you_live: country,
                        over_state_pension_age: "no",
                        age_of_children: age

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
                      disability_affecting_daily_tasks: "no",
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

    should "render Adult Disability Payment [Scotland]" do
      add_responses where_do_you_live: "scotland",
                    over_state_pension_age: "no",
                    disability_or_health_condition: "yes",
                    disability_affecting_daily_tasks: "yes",
                    disability_affecting_work: "no"

      assert_rendered_outcome text: "Adult Disability Payment"
      assert_rendered_outcome text: "You may be able to get help with extra living costs if you have a long-term physical or mental health condition or disability."
    end

    should "render Attendance Allowance when eligible" do
      %w[england scotland wales northern-ireland].each do |country|
        add_responses where_do_you_live: country,
                      disability_or_health_condition: "yes",
                      disability_affecting_daily_tasks: "yes",
                      disability_affecting_work: "no"

        assert_rendered_outcome text: "Attendance Allowance"
        assert_rendered_outcome text: "Check if you’re eligible for Attendance Allowance"
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

    should "render Free TV Licence when eligible (over state pension age)" do
      %w[england scotland wales northern-ireland].each do |country|
        add_responses where_do_you_live: country,
                      on_benefits: "dont_know"

        assert_rendered_outcome text: "Get a free or discounted TV licence"
        assert_rendered_outcome text: "Check if you’re eligible for a free or discounted TV licence"
      end
    end

    should "render Free TV Licence when eligible (with disability or health condition)" do
      %w[england scotland wales northern-ireland].each do |country|
        add_responses where_do_you_live: country,
                      disability_or_health_condition: "yes",
                      disability_affecting_daily_tasks: "yes",
                      disability_affecting_work: "no"

        assert_rendered_outcome text: "Get a free or discounted TV licence"
        assert_rendered_outcome text: "Check if you’re eligible for a free or discounted TV licence"
      end
    end

    should "render Budgeting Loan when eligible" do
      %w[england scotland wales].each do |country|
        add_responses where_do_you_live: country, on_benefits: "dont_know"

        assert_rendered_outcome text: "Budgeting Loan"
        assert_rendered_outcome text: "Check if you’re eligible for a Budgeting Loan"
      end
    end

    should "render Social Fund Budgeting Loan when eligible" do
      add_responses where_do_you_live: "northern-ireland",
                    on_benefits: "yes",
                    current_benefits: "pension_credit"

      assert_rendered_outcome text: "Social Fund Budgeting Loan"
      assert_rendered_outcome text: "Check if you’re eligible for a Budgeting Loan on the nidirect website"
    end

    should "render NHS Help with health costs when eligible" do
      %w[england wales].each do |country|
        add_responses where_do_you_live: country

        assert_rendered_outcome text: "NHS Help with health costs"
        assert_rendered_outcome text: "You may be able to get help with prescriptions, dental care, healthcare travel and other health costs"
      end
    end

    should "render Help With Health Costs Loan when eligible" do
      add_responses where_do_you_live: "scotland"

      assert_rendered_outcome text: "Help with health costs"
      assert_rendered_outcome text: "Check if you’re eligible for help with health costs"
    end

    should "render NHS Help with health costs (Northern Ireland) when eligible" do
      add_responses where_do_you_live: "northern-ireland"

      assert_rendered_outcome text: "NHS Help with health costs"
      assert_rendered_outcome text: "You may be able to get help with prescriptions, dental care, healthcare travel and other health costs"
    end

    should "render maternity allowance for eligible countries" do
      %w[england scotland wales northern-ireland].each do |country|
        add_responses where_do_you_live: country,
                      over_state_pension_age: "no",
                      children_living_with_you: "yes",
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
        assert_rendered_outcome text: "If you or your partner get certain benefits you could get a payment to help towards the costs of having a child."
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

    should "render Healthy Start for eligible countries" do
      %w[england wales northern-ireland].each do |country|
        add_responses where_do_you_live: country,
                      children_living_with_you: "yes",
                      age_of_children: "1_or_under",
                      on_benefits: "dont_know"

        assert_rendered_outcome text: "Healthy Start"
        assert_rendered_outcome text: "If you’re getting certain benefits and are more than 10 weeks pregnant"
      end
    end

    should "render Best Start Food for eligible countries" do
      add_responses where_do_you_live: "scotland",
                    children_living_with_you: "yes",
                    age_of_children: "1_or_under",
                    on_benefits: "yes",
                    current_benefits: "universal_credit"

      assert_rendered_outcome text: "Best Start Foods"
      assert_rendered_outcome text: "If you’re getting certain benefits and are pregnant or have a child under 3"
    end

    should "render Free school meals [England] for eligible countries" do
      add_responses where_do_you_live: "england",
                    children_living_with_you: "yes",
                    age_of_children: "3_to_4",
                    on_benefits: "yes",
                    current_benefits: "universal_credit"

      assert_rendered_outcome text: "Free school meals"
      assert_rendered_outcome text: "If you’re on certain benefits your child may be able to get free school meals."
    end

    should "render Free school meals [Scotland]" do
      add_responses where_do_you_live: "scotland",
                    children_living_with_you: "yes",
                    age_of_children: "3_to_4",
                    on_benefits: "yes",
                    current_benefits: "universal_credit"

      assert_rendered_outcome text: "Free school meals"
      assert_rendered_outcome text: "If you’re on certain benefits your child may be able to get free school meals."
    end

    should "render Free school meals [Wales]" do
      add_responses where_do_you_live: "wales",
                    children_living_with_you: "yes",
                    age_of_children: "3_to_4",
                    on_benefits: "yes",
                    current_benefits: "universal_credit"

      assert_rendered_outcome text: "Free school meals"
      assert_rendered_outcome text: "If you’re on certain benefits your child may be able to get free school meals."
    end

    should "render Free school meals [NI]" do
      add_responses where_do_you_live: "northern-ireland",
                    children_living_with_you: "yes",
                    age_of_children: "3_to_4",
                    on_benefits: "yes",
                    current_benefits: "universal_credit"

      assert_rendered_outcome text: "Free school meals"
      assert_rendered_outcome text: "If you’re on certain benefits your child may be able to get free school meals."
    end

    should "render School Clothing Grant [Scotland]" do
      add_responses where_do_you_live: "scotland",
                    children_living_with_you: "yes",
                    age_of_children: "18_to_19",
                    on_benefits: "yes",
                    current_benefits: "universal_credit"

      assert_rendered_outcome text: "School Clothing Grant"
      assert_rendered_outcome text: "If you’re on certain benefits you may be able to get help from your local council with the cost of school uniforms."
    end

    should "render Uniform Grant [NI]" do
      add_responses where_do_you_live: "northern-ireland",
                    children_living_with_you: "yes",
                    age_of_children: "16_to_17",
                    on_benefits: "yes",
                    current_benefits: "universal_credit"

      assert_rendered_outcome text: "Uniform Grant"
      assert_rendered_outcome text: "If you’re on certain benefits you may be able to get help from your local council with the cost of school uniforms."
    end

    should "render Pupil Development Grant [Wales]" do
      add_responses where_do_you_live: "wales",
                    children_living_with_you: "yes",
                    age_of_children: "16_to_17",
                    on_benefits: "yes",
                    current_benefits: "universal_credit"

      assert_rendered_outcome text: "Pupil Development Grant"
      assert_rendered_outcome text: "If you’re on certain benefits you may be able to get help from your local council with the cost of school uniforms."
    end

    should "render Home to school transport for eligible countries" do
      %w[england wales].each do |country|
        add_responses where_do_you_live: country,
                      children_living_with_you: "yes",
                      age_of_children: "18_to_19",
                      on_benefits: "dont_know"

        assert_rendered_outcome text: "Home to school transport"
        assert_rendered_outcome text: "You may be able to get help with the cost of home to school transport through your local council."
      end
    end

    should "render Free school transport [Scotland]" do
      add_responses where_do_you_live: "scotland",
                    children_living_with_you: "yes",
                    age_of_children: "18_to_19",
                    on_benefits: "dont_know"

      assert_rendered_outcome text: "Free school transport"
      assert_rendered_outcome text: "You may be able to get help with the cost of home to school transport through your local council."
    end

    should "render Home to school transport [NI]" do
      add_responses where_do_you_live: "northern-ireland",
                    children_living_with_you: "yes",
                    age_of_children: "18_to_19",
                    on_benefits: "dont_know"

      assert_rendered_outcome text: "Home to school transport"
      assert_rendered_outcome text: "Check if your child is eligible for help with the cost of home to school transport"
    end

    should "render Apply for an older person's bus pass" do
      %w[england wales].each do |country|
        add_responses where_do_you_live: country

        assert_rendered_outcome text: "Apply for an older person's bus pass"
        assert_rendered_outcome text: "In England you can get a bus pass for free travel when you reach the State Pension age"
      end
    end

    should "render Apply for an older person's bus pass Scotland" do
      add_responses where_do_you_live: "scotland"

      assert_rendered_outcome text: "Apply for an older person's bus pass"
      assert_rendered_outcome text: "You can get a bus pass for free travel if you are 60 or over."
    end

    should "render Apply for an older person's bus pass NI" do
      add_responses where_do_you_live: "northern-ireland"

      assert_rendered_outcome text: "Apply for an older person's bus pass"
      assert_rendered_outcome text: "You can get a bus pass for free travel if you are 60 or over."
    end

    should "render Apply for a disabled person's bus pass" do
      add_responses where_do_you_live: "england",
                    disability_or_health_condition: "yes",
                    disability_affecting_daily_tasks: "no",
                    disability_affecting_work: "no"

      assert_rendered_outcome text: "Apply for a disabled person's bus pass"
      assert_rendered_outcome text: "You can get free travel on buses if you’re eligible."
    end

    should "render Apply for a disabled person's bus pass Wales" do
      add_responses where_do_you_live: "wales",
                    disability_or_health_condition: "yes",
                    disability_affecting_daily_tasks: "no",
                    disability_affecting_work: "yes_limits_work"

      assert_rendered_outcome text: "Apply for a disabled person's bus pass"
      assert_rendered_outcome text: "Find out how to apply for a disabled person’s bus pass on the GOV.WALES website"
    end

    should "render Apply for a disabled person's bus pass Scotland" do
      add_responses where_do_you_live: "scotland",
                    disability_or_health_condition: "yes",
                    disability_affecting_daily_tasks: "no",
                    disability_affecting_work: "yes_unable_to_work"

      assert_rendered_outcome text: "Apply for a disabled person's bus pass"
      assert_rendered_outcome text: "Find out how to apply for a disabled person’s bus pass on the mygov.scot website"
    end

    should "render Apply for a disabled person's bus pass NI" do
      add_responses where_do_you_live: "northern-ireland",
                    disability_or_health_condition: "yes",
                    disability_affecting_daily_tasks: "no",
                    disability_affecting_work: "yes_unable_to_work"

      assert_rendered_outcome text: "Apply for a disabled person's bus pass"
      assert_rendered_outcome text: "Find out how to apply for a disabled person’s bus pass on the nidirect website"
    end

    should "render Support for Mortgage Interest (SMI)" do
      %w[england wales northern-ireland scotland].each do |country|
        add_responses where_do_you_live: country, on_benefits: "dont_know"

        assert_rendered_outcome text: "Support for Mortgage Interest (SMI)"
        assert_rendered_outcome text: "If you’re a homeowner, you might be able to get help towards interest payments on your mortgage"
      end
    end

    should "render Education Maintenance Allowance NI" do
      add_responses where_do_you_live: "northern-ireland",
                    children_living_with_you: "yes",
                    age_of_children: "16_to_17"

      assert_rendered_outcome text: "Education Maintenance Allowance"
      assert_rendered_outcome text: "You may be able to get a weekly Education Maintenance Allowance (EMA)"
    end

    should "render Warm Home Discount Scheme" do
      %w[england wales].each do |country|
        add_responses where_do_you_live: country, on_benefits: "yes"

        assert_rendered_outcome text: "Warm Home Discount Scheme"
        assert_rendered_outcome text: "Check if you’re eligible for the Warm Home Discount scheme"
      end
    end

    should "render Warm Home Discount Scheme Scotland" do
      add_responses where_do_you_live: "scotland", on_benefits: "yes"

      assert_rendered_outcome text: "Warm Home Discount Scheme"
      assert_rendered_outcome text: "Check if you’re eligible and whether you need to apply for the Warm Home Discount scheme"
    end

    should "render Wales fuel support scheme payment" do
      add_responses where_do_you_live: "wales"

      assert_rendered_outcome text: "Wales fuel support scheme payment"
      assert_rendered_outcome text: "Check if you're eligible for a Wales fuel support scheme payment on the GOV.WALES website"
    end

    should "render Eligible for help to save (on benefits)" do
      add_responses over_state_pension_age: "no",
                    current_benefits: "universal_credit"

      assert_rendered_outcome text: "You can get a bonus of 50p for every £1 you save over 4 years through Help to Save if you get certain benefits."
      assert_rendered_outcome text: "Find out more about Help to Save"
    end

    should "render Eligible for help to save (don't know if on benefits)" do
      add_responses over_state_pension_age: "no",
                    on_benefits: "dont_know"

      assert_rendered_outcome text: "You can get a bonus of 50p for every £1 you save over 4 years through Help to Save if you get certain benefits."
      assert_rendered_outcome text: "Find out more about Help to Save"
    end

    should "render Eligible for Disabled Facilities Grant? (Disabled adult in England or Wales)" do
      %w[england wales].each do |country|
        %w[none_16000 under_16000].each do |asset|
          add_responses where_do_you_live: country,
                        disability_or_health_condition: "yes",
                        disability_affecting_daily_tasks: "no",
                        disability_affecting_work: "no",
                        assets_and_savings: asset

          assert_rendered_outcome text: "You could get a grant from your local council to make changes to your home if you’re disabled or you live with someone who is."
          assert_rendered_outcome text: "Check if you’re eligible for a Disabled Facilities Grant"
        end
      end
    end

    should "render Eligible for Disabled Facilities Grant? (Disabled child in England or Wales)" do
      %w[england wales].each do |country|
        %w[none_16000 under_16000].each do |asset|
          add_responses where_do_you_live: country,
                        assets_and_savings: asset

          assert_rendered_outcome text: "You could get a grant from your local council to make changes to your home if you’re disabled or you live with someone who is."
          assert_rendered_outcome text: "Check if you’re eligible for a Disabled Facilities Grant"
        end
      end
    end

    should "render Eligible for Disabled Facilities Grant? (Disabled adult in Northern Ireland)" do
      %w[none_16000 under_16000].each do |asset|
        add_responses where_do_you_live: "northern-ireland",
                      disability_or_health_condition: "yes",
                      disability_affecting_daily_tasks: "no",
                      disability_affecting_work: "no",
                      assets_and_savings: asset

        assert_rendered_outcome text: "You could get a grant from your local health and social services trust to make changes to your home if you’re disabled or you live with someone who is."
        assert_rendered_outcome text: "Check if you’re eligible for a Disabled Facilities Grant on the NI Housing Executive website"
      end
    end

    should "render Eligible for Disabled Facilities Grant? (Disabled child in Northern Ireland)" do
      %w[none_16000 under_16000].each do |asset|
        add_responses where_do_you_live: "northern-ireland",
                      assets_and_savings: asset

        assert_rendered_outcome text: "You could get a grant from your local health and social services trust to make changes to your home if you’re disabled or you live with someone who is."
        assert_rendered_outcome text: "Check if you’re eligible for a Disabled Facilities Grant on the NI Housing Executive website"
      end
    end

    should "render Eligible for help with house adaptations if you are disabled? (Disabled adult in Scotland)" do
      add_responses where_do_you_live: "scotland",
                    disability_or_health_condition: "yes",
                    disability_affecting_daily_tasks: "no",
                    disability_affecting_work: "no"

      assert_rendered_outcome text: "You could get help from your local council to make changes to your home if you’re disabled or you live with someone who is."
      assert_rendered_outcome text: "Check if you’re eligible for help with house adaptations on the mygov.scot website"
    end

    should "render Eligible for help with house adaptations if you are disabled? (Disabled child in Scotland)" do
      add_responses where_do_you_live: "scotland"

      assert_rendered_outcome text: "You could get help from your local council to make changes to your home if you’re disabled or you live with someone who is."
      assert_rendered_outcome text: "Check if you’re eligible for help with house adaptations on the mygov.scot website"
    end

    should "render Discretionary Assistance Fund" do
      add_responses where_do_you_live: "wales"

      assert_rendered_outcome text: "Discretionary Assistance Fund"
      assert_rendered_outcome text: "Check if you’re eligible for the Discretionary Assistance Fund on the GOV.WALES website"
    end
  end
end
