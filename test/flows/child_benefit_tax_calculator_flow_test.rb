require "test_helper"
require "support/flow_test_helper"

class ChildBenefitTaxCalculatorFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow ChildBenefitTaxCalculatorFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: how_many_children?" do
    setup { testing_node :how_many_children? }

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for a number less than 1" do
        assert_invalid_response "0"
      end

      should "be invalid for a number greater than 30" do
        assert_invalid_response "31"
      end
    end

    context "next_node" do
      should "have a next node of which_tax_year?" do
        assert_next_node :which_tax_year?, for_response: "30"
      end
    end
  end

  context "question: which_tax_year?" do
    setup do
      testing_node :which_tax_year?
      add_responses how_many_children?: "5"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of is_part_year_claim?" do
        assert_next_node :is_part_year_claim?, for_response: "2021"
      end

      should "have a next node of between_april_june? for 2024" do
        assert_next_node :between_april_june?, for_response: "2024"
      end
    end
  end

  context "question: between_april_june?" do
    setup do
      testing_node :between_april_june?
      add_responses how_many_children?: "5",
                    which_tax_year?: "2024"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of is_part_year_claim? for a 'yes' response" do
        assert_next_node :is_part_year_claim?, for_response: "yes"
      end

      should "have a next node of is_part_year_claim? for a 'no' response" do
        assert_next_node :is_part_year_claim?, for_response: "no"
      end
    end
  end

  context "question: is_part_year_claim?" do
    setup do
      testing_node :is_part_year_claim?
      add_responses how_many_children?: "5",
                    which_tax_year?: "2021"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_many_children_part_year? for a 'yes' response" do
        assert_next_node :how_many_children_part_year?, for_response: "yes"
      end

      should "have a next node of income_details? for a 'no' response" do
        assert_next_node :income_details?, for_response: "no"
      end
    end
  end

  context "question: how_many_children_part_year?" do
    setup do
      testing_node :how_many_children_part_year?
      add_responses how_many_children?: "5",
                    which_tax_year?: "2021",
                    is_part_year_claim?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for a number less than 1" do
        assert_invalid_response "0"
      end

      should "be invalid for a number greater than the number of children" do
        assert_invalid_response "6"
      end
    end

    context "next_node" do
      should "have a next node of child_benefit_1_start?" do
        assert_next_node :child_benefit_1_start?, for_response: "1"
      end
    end
  end

  context "dynamic child benefit questions" do
    # These questions use the same code so we only need to test one of these

    context "question: child_benefit_{child_number}_start?" do
      setup do
        testing_node :child_benefit_2_start?
        add_responses how_many_children?: "2",
                      which_tax_year?: "2021",
                      is_part_year_claim?: "yes",
                      how_many_children_part_year?: "2",
                      child_benefit_1_start?: "2021-10-10",
                      add_child_benefit_1_stop?: "no"
      end

      should "render the question" do
        assert_rendered_question
      end

      context "validation" do
        should "be invalid for a date before the tax year start date" do
          # start date for 2021 is 2021-04-06
          assert_invalid_response "2021-04-05"
        end

        should "be invalid for a date after the tax year end date" do
          # end date for 2021 is 2022-04-05
          assert_invalid_response "2022-04-06"
        end
      end

      context "next_node" do
        should "have a next node of add_child_benefit_{child_number}_stop?" do
          assert_next_node "add_child_benefit_2_stop?".to_sym, for_response: "2021-04-06"
        end
      end
    end

    context "question: add_child_benefit_{child_number}_stop?" do
      setup do
        testing_node :add_child_benefit_2_stop?
        add_responses how_many_children?: "2",
                      which_tax_year?: "2021",
                      is_part_year_claim?: "yes",
                      how_many_children_part_year?: "2",
                      child_benefit_1_start?: "2021-10-10",
                      add_child_benefit_1_stop?: "no",
                      child_benefit_2_start?: "2021-10-06"
      end

      should "render the question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of child_benefit_{child_number}_stop? for a 'yes' response" do
          assert_next_node "child_benefit_2_stop?".to_sym, for_response: "yes"
        end

        should "have a next node of income_details? for a 'no' response when there are no further children" do
          assert_next_node :income_details?, for_response: "no"
        end

        should "have a next node of child_benefit_{child_number + 1}_start? for a 'no' response when there are " \
               "further children" do
          add_responses how_many_children?: "3",
                        how_many_children_part_year?: "3"
          assert_next_node :child_benefit_3_start?, for_response: "no"
        end
      end

      context "question: child_benefit_{child_number}_stop?" do
        setup do
          testing_node :child_benefit_2_stop?
          add_responses how_many_children?: "2",
                        which_tax_year?: "2021",
                        is_part_year_claim?: "yes",
                        how_many_children_part_year?: "2",
                        child_benefit_1_start?: "2021-10-10",
                        add_child_benefit_1_stop?: "no",
                        child_benefit_2_start?: "2021-10-06",
                        add_child_benefit_2_stop?: "yes"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "validation" do
          should "be invalid for a date before the child start date" do
            assert_invalid_response "2021-10-01"
          end

          should "be invalid for a date the same as the child start date" do
            assert_invalid_response "2021-10-06"
          end

          should "be invalid for a date after the tax year end date" do
            # end date for 2021 is 2022-04-05
            assert_invalid_response "2022-04-06"
          end
        end

        context "next_node" do
          should "have a next node of income_details? when there are no further children" do
            assert_next_node :income_details?, for_response: "2021-10-07"
          end

          should "have a next node of child_benefit_{child_number + 1}_start? when there are further children" do
            add_responses how_many_children?: "3",
                          how_many_children_part_year?: "3"
            assert_next_node :child_benefit_3_start?, for_response: "2021-10-07"
          end
        end
      end
    end
  end

  context "question: income_details?" do
    setup do
      testing_node :income_details?
      add_responses how_many_children?: "5",
                    which_tax_year?: "2021",
                    is_part_year_claim?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of add_allowable_deductions?" do
        assert_next_node :add_allowable_deductions?, for_response: "100"
      end
    end
  end

  context "question: add_allowable_deductions?" do
    setup do
      testing_node :add_allowable_deductions?
      add_responses how_many_children?: "5",
                    which_tax_year?: "2021",
                    is_part_year_claim?: "no",
                    income_details?: "100"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of allowable_deductions? for a 'yes' response" do
        assert_next_node :allowable_deductions?, for_response: "yes"
      end

      should "have a next node of results for a 'no' response" do
        assert_next_node :results, for_response: "no"
      end
    end
  end

  context "question: allowable_deductions?" do
    setup do
      testing_node :allowable_deductions?
      add_responses how_many_children?: "5",
                    which_tax_year?: "2021",
                    is_part_year_claim?: "no",
                    income_details?: "100",
                    add_allowable_deductions?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of add_other_allowable_deductions?" do
        assert_next_node :add_other_allowable_deductions?, for_response: "100"
      end
    end
  end

  context "question: add_other_allowable_deductions?" do
    setup do
      testing_node :add_other_allowable_deductions?
      add_responses how_many_children?: "5",
                    which_tax_year?: "2021",
                    is_part_year_claim?: "no",
                    income_details?: "100",
                    add_allowable_deductions?: "yes",
                    allowable_deductions?: "100"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of other_allowable_deductions? for a 'yes' response" do
        assert_next_node :other_allowable_deductions?, for_response: "yes"
      end

      should "have a next node of results for a 'no' response" do
        assert_next_node :results, for_response: "no"
      end
    end
  end

  context "question: other_allowable_deductions?" do
    setup do
      testing_node :other_allowable_deductions?
      add_responses how_many_children?: "5",
                    which_tax_year?: "2021",
                    is_part_year_claim?: "no",
                    income_details?: "100",
                    add_allowable_deductions?: "yes",
                    allowable_deductions?: "100",
                    add_other_allowable_deductions?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of results" do
        assert_next_node :results, for_response: "100"
      end
    end
  end

  context "outcome: results" do
    setup { testing_node :results }

    should "render no tax charge when the net income is below £50,100" do
      add_responses how_many_children?: "1",
                    which_tax_year?: "2021",
                    is_part_year_claim?: "no",
                    income_details?: "60000",
                    add_allowable_deductions?: "yes",
                    allowable_deductions?: "5000",
                    add_other_allowable_deductions?: "yes",
                    other_allowable_deductions?: "10000"

      assert_rendered_outcome text: "There is no tax charge if your income is below £50,100"
    end

    should "render no tax charge when the net income is below £60,200 in 2024" do
      add_responses how_many_children?: "1",
                    which_tax_year?: "2024",
                    between_april_june?: "no",
                    is_part_year_claim?: "no",
                    income_details?: "70000",
                    add_allowable_deductions?: "yes",
                    allowable_deductions?: "5000",
                    add_other_allowable_deductions?: "yes",
                    other_allowable_deductions?: "10000"

      assert_rendered_outcome text: "There is no tax charge if your income is below £60,200"
    end

    should "render the tax owed the net income is above £51,000" do
      add_responses how_many_children?: "2",
                    which_tax_year?: "2020",
                    is_part_year_claim?: "yes",
                    how_many_children_part_year?: "2",
                    child_benefit_1_start?: "2020-09-07",
                    add_child_benefit_1_stop?: "yes",
                    child_benefit_1_stop?: "2020-09-13",
                    child_benefit_2_start?: "2020-09-07",
                    add_child_benefit_2_stop?: "yes",
                    child_benefit_2_stop?: "2020-09-13",
                    income_details?: "100000",
                    add_allowable_deductions?: "no"

      # Two weeks of child benefit for 2020 tax year = 21.05 + 13.95
      assert_rendered_outcome text: "The estimated tax charge to pay is £35.00"
    end

    should "render estimate text when income is above £51,000 and the tax year is incomplete" do
      travel_to("2021-09-01") do
        add_responses how_many_children?: "1",
                      which_tax_year?: "2021",
                      is_part_year_claim?: "no",
                      income_details?: "100000",
                      add_allowable_deductions?: "no"

        assert_rendered_outcome text: "This is an estimate based on your adjusted net income of £100,000.00"
      end
    end

    should "render specific guidance when the tax year is 2012-2013" do
      add_responses how_many_children?: "1",
                    which_tax_year?: "2012",
                    is_part_year_claim?: "no",
                    income_details?: "50000",
                    add_allowable_deductions?: "no"

      assert_rendered_outcome text: "Received between 7 January and 5 April 2013"
    end

    should "render specific guidance when the tax year is 2024 and the claim is between April and June" do
      add_responses how_many_children?: "1",
                    which_tax_year?: "2024",
                    between_april_june?: "yes",
                    is_part_year_claim?: "no",
                    income_details?: "50000",
                    add_allowable_deductions?: "no"

      assert_rendered_outcome text: "If you made a new claim between 6 April 2024 and 7 July 2024, it may be backdated by up to 3 months"
    end

    should "render specific guidance when income is above £60,000 and the claim is after 2024 (Inclusive)" do
      add_responses how_many_children?: "1",
                    which_tax_year?: "2025",
                    is_part_year_claim?: "no",
                    income_details?: "70000",
                    add_allowable_deductions?: "no"

      assert_rendered_outcome text: "You can pay through PAYE or Self Assessment."
    end
  end
end
