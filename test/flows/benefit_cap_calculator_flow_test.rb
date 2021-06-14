require "test_helper"
require "support/flow_test_helper"

class BenefitCapCalculatorFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow BenefitCapCalculatorFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: receive_housing_benefit?" do
    setup { testing_node :receive_housing_benefit? }

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of working_tax_credit? for a 'yes' response" do
        assert_next_node :working_tax_credit?, for_response: "yes"
      end

      should "have a next node of outcome_not_affected_no_housing_benefit for a 'no' response" do
        assert_next_node :outcome_not_affected_no_housing_benefit, for_response: "no"
      end
    end
  end

  context "question: working_tax_credit?" do
    setup do
      testing_node :working_tax_credit?
      add_responses receive_housing_benefit?: "yes"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of outcome_not_affected_exemptions for a 'yes' response" do
        assert_next_node :outcome_not_affected_exemptions, for_response: "yes"
      end

      should "have a next node of receiving_exemption_benefits? for a 'no' response" do
        assert_next_node :receiving_exemption_benefits?, for_response: "no"
      end
    end
  end

  context "question: receiving_exemption_benefits?" do
    setup do
      testing_node :receiving_exemption_benefits?
      add_responses receive_housing_benefit?: "yes", working_tax_credit?: "no"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of outcome_not_affected_exemptions for any benefit" do
        assert_next_node :outcome_not_affected_exemptions, for_response: %w[attendance_allowance]
      end

      should "have a next node of receiving_non_exemption_benefits? for an empty response" do
        assert_next_node :receiving_non_exemption_benefits?, for_response: []
      end
    end
  end

  context "question: receiving_non_exemption_benefits?" do
    setup do
      testing_node :receiving_non_exemption_benefits?
      add_responses receive_housing_benefit?: "yes",
                    working_tax_credit?: "no",
                    receiving_exemption_benefits?: []
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of housing_benefit_amount? for an empty response" do
        assert_next_node :housing_benefit_amount?, for_response: []
      end

      should "have a next node based on the response" do
        assert_next_node :bereavement_amount?, for_response: %w[bereavement child_benefit]
      end
    end
  end

  # Dynamic questions that appear based on previous answers
  questions = SmartAnswer::Calculators::BenefitCapCalculatorConfiguration.questions
  questions.each do |benefit, question|
    # These need to be alphabetical as the answers are made alphabetical
    benefit_keys = questions.keys.sort
    remaining_benefits = benefit_keys[(benefit_keys.index(benefit) + 1)..]

    context "dynamic question: #{question}" do
      setup do
        testing_node question
        add_responses receive_housing_benefit?: "yes",
                      working_tax_credit?: "no",
                      receiving_exemption_benefits?: [],
                      receiving_non_exemption_benefits?: [benefit]
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of housing_benefit_amount? if there aren't other benfits remaining" do
          assert_next_node :housing_benefit_amount?, for_response: "1.00"
        end

        if remaining_benefits.any?
          next_question = questions[remaining_benefits.first]

          should "have a next node of the next benefit when there are other benefits" do
            add_responses receiving_non_exemption_benefits?: [benefit] + remaining_benefits
            assert_next_node next_question, for_response: "1.00"
          end
        end
      end
    end
  end

  context "question: housing_benefit_amount?" do
    setup do
      testing_node :housing_benefit_amount?
      add_responses receive_housing_benefit?: "yes",
                    working_tax_credit?: "no",
                    receiving_exemption_benefits?: [],
                    receiving_non_exemption_benefits?: []
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of single_couple_lone_parent?" do
        assert_next_node :single_couple_lone_parent?, for_response: "1.00"
      end
    end
  end

  context "question: single_couple_lone_parent?" do
    setup do
      testing_node :single_couple_lone_parent?
      add_responses receive_housing_benefit?: "yes",
                    working_tax_credit?: "no",
                    receiving_exemption_benefits?: [],
                    receiving_non_exemption_benefits?: [],
                    housing_benefit_amount?: "1.00"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of enter_postcode?" do
        assert_next_node :enter_postcode?, for_response: "single"
      end
    end
  end

  context "question: enter_postcode?" do
    setup do
      testing_node :enter_postcode?
      add_responses receive_housing_benefit?: "yes",
                    working_tax_credit?: "no",
                    receiving_exemption_benefits?: [],
                    receiving_non_exemption_benefits?: [],
                    housing_benefit_amount?: "1.00",
                    single_couple_lone_parent?: "single"
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      context "when the postcode is in London" do
        setup do
          @postcode = "WC2B 6SE"
          stub_postcode(@postcode, region: "London")
        end

        should "have a next node of outcome_affected_greater_than_cap_london for benefits greater than the cap" do
          cap = benefit_cap(region: :london)
          add_responses housing_benefit_amount?: (cap + 100).to_s
          assert_next_node :outcome_affected_greater_than_cap_london, for_response: @postcode
        end

        should "have a next node of outcome_not_affected_less_than_cap_london for benefits greater than the cap" do
          assert_next_node :outcome_not_affected_less_than_cap_london, for_response: @postcode
        end
      end

      context "when the postcode is outside London" do
        setup do
          @postcode = "B1 1PW"
          stub_postcode(@postcode, region: "West Midlands")
        end

        should "have a next node of outcome_affected_greater_than_cap_national for benefits greater than the cap" do
          cap = benefit_cap(region: :national)

          add_responses housing_benefit_amount?: (cap + 100).to_s
          assert_next_node :outcome_affected_greater_than_cap_national, for_response: @postcode
        end

        should "have a next node of outcome_not_affected_less_than_cap_national for benefits greater than the cap" do
          assert_next_node :outcome_not_affected_less_than_cap_national, for_response: @postcode
        end
      end
    end
  end

  context "outcome: outcome_affected_greater_than_cap_london" do
    setup do
      testing_node :outcome_affected_greater_than_cap_london
      stub_postcode("WC2B 6SE", region: "London")
      add_responses receive_housing_benefit?: "yes",
                    working_tax_credit?: "no",
                    receiving_exemption_benefits?: [],
                    receiving_non_exemption_benefits?: %w[jsa],
                    single_couple_lone_parent?: "single",
                    enter_postcode?: "WC2B 6SE"
    end

    should "render new housing benefit amount by subtracting housing benefit from other benefits" do
      cap = benefit_cap(region: :london)
      add_responses jsa_amount?: (cap - 20).to_s,
                    housing_benefit_amount?: cap.to_s
      assert_rendered_outcome text: "Your Housing Benefit will be: £20"
    end

    should "reduce housing benefit amount to a minimum of 50p" do
      cap = benefit_cap(region: :london)
      add_responses jsa_amount?: cap.to_s,
                    housing_benefit_amount?: cap.to_s
      assert_rendered_outcome
      assert_match "Your Housing Benefit will be: 50p", @test_flow.outcome_body_text
      assert_match "Your Housing Benefit won’t be reduced to less than 50p", @test_flow.outcome_body_text
    end
  end

  context "outcome: outcome_affected_greater_than_cap_national" do
    setup do
      testing_node :outcome_affected_greater_than_cap_national
      stub_postcode("B1 1PW", region: "West Midlands")
      add_responses receive_housing_benefit?: "yes",
                    working_tax_credit?: "no",
                    receiving_exemption_benefits?: [],
                    receiving_non_exemption_benefits?: %w[jsa],
                    single_couple_lone_parent?: "single",
                    enter_postcode?: "B1 1PW"
    end

    should "render new housing benefit amount by subtracting housing benefit from other benefits" do
      cap = benefit_cap(region: :national)
      add_responses jsa_amount?: (cap - 20).to_s,
                    housing_benefit_amount?: cap.to_s
      assert_rendered_outcome text: "Your Housing Benefit will be: £20"
    end

    should "reduce housing benefit amount to a minimum of 50p" do
      cap = benefit_cap(region: :national)
      add_responses jsa_amount?: cap.to_s,
                    housing_benefit_amount?: cap.to_s
      assert_rendered_outcome
      assert_match "Your Housing Benefit will be: 50p", @test_flow.outcome_body_text
      assert_match "Your Housing Benefit won’t be reduced to less than 50p", @test_flow.outcome_body_text
    end
  end

  context "outcome: outcome_affected_exemptions" do
    setup do
      testing_node :outcome_not_affected_exemptions
      add_responses receive_housing_benefit?: "yes",
                    working_tax_credit?: "no",
                    receiving_exemption_benefits?: %w[carers_allowance war_pensions]
    end

    should "render the exemption benefits" do
      assert_rendered_outcome
      assert_match "Carer's Allowance", @test_flow.outcome_body_text
      assert_match "War pensions", @test_flow.outcome_body_text
    end
  end

  def stub_postcode(postcode, region:, country_name: "England")
    stub_imminence_has_areas_for_postcode(
      ERB::Util.url_encode(postcode),
      [{ type: "EUR", name: region, country_name: country_name }],
    )
  end

  def benefit_cap(region:)
    SmartAnswer::Calculators::BenefitCapCalculatorConfiguration
      .weekly_benefit_cap_amount("single", region)
  end
end
