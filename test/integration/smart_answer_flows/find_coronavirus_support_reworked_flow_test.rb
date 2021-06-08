require_relative "../../test_helper"
require_relative "experimental_flow_test_helper"

require "smart_answer_flows/find-coronavirus-support"

class FindCoronavirusSupportReworkedFlowTest < ActiveSupport::TestCase
  include ExperimentalFlowTestHelper

  setup { testing_flow SmartAnswer::FindCoronavirusSupportFlow }

  should render_start_page

  context "question: need_help_with" do
    setup { testing_node :need_help_with }
    should render_question

    context "next_node" do
      should have_next_node(:nation).for_response(%w[none])
    end
  end

  context "question: feel_unsafe" do
    setup do
      testing_node :feel_unsafe
      add_responses need_help_with: %w[feeling_unsafe]
    end

    should render_question

    context "next_node" do
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: afford_rent_mortgage_bills" do
    setup do
      testing_node :afford_rent_mortgage_bills
      add_responses need_help_with: %w[paying_bills]
    end

    should render_question

    context "next_node" do
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: afford_food" do
    setup do
      testing_node :afford_food
      add_responses need_help_with: %w[getting_food]
    end

    should render_question

    context "next_node" do
      should have_next_node(:get_food).for_response("yes")
    end
  end

  context "question: get_food" do
    setup do
      testing_node :get_food
      add_responses need_help_with: %w[getting_food], afford_food: "yes"
    end

    should render_question

    context "next_node" do
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: self_employed" do
    setup do
      testing_node :self_employed
      add_responses need_help_with: %w[being_unemployed]
    end

    should render_question

    context "next_node" do
      should have_next_node(:have_you_been_made_unemployed).for_response("no")
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: have_you_been_made_unemployed" do
    setup do
      testing_node :have_you_been_made_unemployed
      add_responses need_help_with: %w[being_unemployed], self_employed: "no"
    end

    should render_question

    context "next_node" do
      should have_next_node(:nation).for_response("yes_i_have_been_made_unemployed")
    end
  end

  context "question: worried_about_work" do
    setup do
      testing_node :worried_about_work
      add_responses need_help_with: %w[going_to_work]
    end

    should render_question

    context "next_node" do
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: worried_about_self_isolating" do
    setup do
      testing_node :worried_about_self_isolating
      add_responses need_help_with: %w[self_isolating]
    end

    should render_question

    context "next_node" do
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: have_somewhere_to_live" do
    setup do
      testing_node :have_somewhere_to_live
      add_responses need_help_with: %w[somewhere_to_live]
    end

    should render_question

    context "next_node" do
      should have_next_node(:have_you_been_evicted).for_response("yes")
    end
  end

  context "question: have_you_been_evicted" do
    setup do
      testing_node :have_you_been_evicted
      add_responses need_help_with: %w[somewhere_to_live],
                    have_somewhere_to_live: "yes"
    end

    should render_question

    context "next_node" do
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: mental_health_worries" do
    setup do
      testing_node :mental_health_worries
      add_responses need_help_with: %w[mental_health]
    end

    should render_question

    context "next_node" do
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: nation" do
    setup do
      testing_node :nation
      add_responses need_help_with: %w[none]
    end

    should render_question

    context "next_node" do
      should have_next_node(:results).for_response("england")
    end
  end

  context "outcome: results" do
    setup { testing_node :results }

    should "render feeling unsafe help when the appropriate responses are given" do
      add_responses need_help_with: %w[feeling_unsafe],
                    feel_unsafe: "yes",
                    nation: "england"

      assert_rendered_outcome text: "If you feel unsafe where you live or you’re worried about someone else"
    end

    should "render paying bills help when the appropriate responses are given" do
      add_responses need_help_with: %w[paying_bills],
                    afford_rent_mortgage_bills: "yes",
                    feel_unsafe: "yes",
                    nation: "england"

      assert_rendered_outcome text: "If you’re finding it hard to pay your rent, mortgage or bills"
    end

    should "render afford food help when the appropriate responses are given" do
      add_responses need_help_with: %w[getting_food],
                    afford_food: "yes",
                    get_food: "yes",
                    nation: "england"

      assert_rendered_outcome text: "If you’re finding it hard to afford food"
    end

    should "render getting food help when the appropriate responses are given" do
      add_responses need_help_with: %w[getting_food],
                    afford_food: "yes",
                    get_food: "no",
                    nation: "england"

      assert_rendered_outcome text: "If you’re unable to get food or medicine"
    end

    should "render employment help when the appropriate responses are given" do
      add_responses need_help_with: %w[being_unemployed],
                    self_employed: "no",
                    have_you_been_made_unemployed: "yes_i_have_been_made_unemployed",
                    nation: "england"

      assert_rendered_outcome text: "If you’ve been made redundant or unemployed, or put on temporary leave (on furlough)"
    end

    should "render self-employed help when the appropriate responses are given" do
      add_responses need_help_with: %w[being_unemployed],
                    self_employed: "yes",
                    have_you_been_made_unemployed: "no",
                    nation: "england"

      assert_rendered_outcome text: "If you’re self employed, a freelancer, or a sole trader"
    end

    should "render going to work help when the appropriate responses are given" do
      add_responses need_help_with: %w[going_to_work],
                    worried_about_work: "yes",
                    nation: "england"

      assert_rendered_outcome text: "If you’re worried about going in to work"
    end

    should "render self-isolating help when the appropriate responses are given" do
      add_responses need_help_with: %w[self_isolating],
                    worried_about_self_isolating: "yes",
                    nation: "england"

      assert_rendered_outcome text: "If you’re self-isolating"
    end

    should "render where to live help when the appropriate responses are given" do
      add_responses need_help_with: %w[somewhere_to_live],
                    have_somewhere_to_live: "no",
                    have_you_been_evicted: "no",
                    nation: "england"

      assert_rendered_outcome text: "If you do not have somewhere to live or might become homeless"
    end

    should "render eviction help when the appropriate responses are given" do
      add_responses need_help_with: %w[somewhere_to_live],
                    have_somewhere_to_live: "yes",
                    have_you_been_evicted: "yes",
                    nation: "england"

      assert_rendered_outcome text: "If you’ve been evicted or might be soon"
    end

    should "render mental health help when the appropriate responses are given" do
      add_responses need_help_with: %w[mental_health],
                    mental_health_worries: "yes",
                    nation: "england"

      assert_rendered_outcome text: "If you’re worried about your mental health or someone else’s mental health"
    end

    should "render Northern Ireland guidance to people in that nation" do
      add_responses need_help_with: %w[none], nation: "northern_ireland"
      assert_rendered_outcome text: "Additional information for Northern Ireland"
    end

    should "render Scotland guidance to people in that nation" do
      add_responses need_help_with: %w[none], nation: "scotland"
      assert_rendered_outcome text: "Additional information for Scotland"
    end

    should "render Wales guidance to people in that nation" do
      add_responses need_help_with: %w[none], nation: "wales"
      assert_rendered_outcome text: "Additional information for Wales"
    end
  end
end
