require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/find-coronavirus-support"

class FindCoronavirusSupportReworkedFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { setup_for_testing_flow SmartAnswer::FindCoronavirusSupportFlow }

  should render_start_page

  context "question: need_help_with" do
    should render_question(:need_help_with)

    context "next_node" do
      should have_next_node(:nation).for_response(["none"])
    end
  end

  context "question: feel_unsafe" do
    setup { responses = { need_help_with: %w[feeling_unsafe] } }
    should render_question(:feel_unsafe)

    context "next_node" do
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: afford_rent_mortgage_bills" do
    setup { responses = { need_help_with: %w[paying_bills] } }
    should render_question(:afford_rent_mortgage_bills)

    context "next_node" do
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: afford_food" do
    setup { responses = { need_help_with: %w[getting_food] } }
    should render_question(:afford_food)

    context "next_node" do
      should have_next_node(:get_food).for_response("yes")
    end
  end

  context "question: get_food" do
    setup { responses = { need_help_with: %w[getting_food], afford_food: "yes" } }
    should render_question(:get_food)

    context "next_node" do
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: self_employed" do
    setup { responses = { need_help_with: %w[being_unemployed] } }
    should render_question(:self_employed)

    context "next_node" do
      should have_next_node(:have_you_been_made_unemployed).for_response("no")
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: have_you_been_made_unemployed" do
    setup { responses = { need_help_with: %w[being_unemployed], self_employed: "no" } }
    should render_question(:have_you_been_made_unemployed)

    context "next_node" do
      should have_next_node(:nation).for_response("yes_i_have_been_made_unemployed")
    end
  end

  context "question: worried_about_work" do
    setup { responses = { need_help_with: %w[going_to_work] } }
    should render_question(:worried_about_work)

    context "next_node" do
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: worried_about_self_isolating" do
    setup { responses = { need_help_with: %w[self_isolating] } }
    should render_question(:worried_about_self_isolating)

    context "next_node" do
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: have_somewhere_to_live" do
    setup { responses = { need_help_with: %w[somewhere_to_live] } }
    should render_question(:have_somewhere_to_live)

    context "next_node" do
      should have_next_node(:have_you_been_evicted).for_response("yes")
    end
  end

  context "question: have_you_been_evicted" do
    setup do
      responses = { need_help_with: %w[somewhere_to_live],
                    have_somewhere_to_live: "yes" }
    end
    should render_question(:have_you_been_evicted)

    context "next_node" do
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: mental_health_worries" do
    setup { responses = { need_help_with: %w[mental_health] } }
    should render_question(:mental_health_worries)

    context "next_node" do
      should have_next_node(:nation).for_response("yes")
    end
  end

  context "question: nation" do
    setup { responses = { need_help_with: %w[none] } }
    should render_question(:nation)

    context "next_node" do
      should have_next_node(:results).for_response("england")
    end
  end

  context "outcome: results" do
    context "when a user is feeling unsafe" do
      setup do
        responses = { need_help_with: %w[feeling_unsafe],
                      feeling_unsafe: "yes",
                      nation: "england" }
      end

      should render_outcome(:results).with_text(
        "If you feel unsafe where you live or you’re worried about someone else",
      )
    end

    context "when a user is finding it hard to pay bills" do
      setup do
        responses = { need_help_with: %w[paying_bills],
                      afford_rent_mortgage_bills: "yes",
                      nation: "england" }
      end

      should render_outcome(:results).with_text(
        "If you’re finding it hard to pay your rent, mortgage or bills",
      )
    end

    context "when a user is finding it hard to afford food" do
      setup do
        responses = { need_help_with: %w[getting_food],
                      afford_food: "yes",
                      nation: "england" }
      end

      should render_outcome(:results).with_text("If you're finding it hard to afford food")
    end

    context "when a user is finding it hard to get food" do
      setup do
        responses = { need_help_with: %w[getting_food],
                      afford_food: "yes",
                      get_food: "no",
                      nation: "england" }
      end

      should render_outcome(:results).with_text("If you're unable to get food or medicine")
    end

    context "when a user is struggling with employment" do
      setup do
        responses = { need_help_with: %w[being_unemployed],
                      self_employed: "no",
                      have_you_been_made_unemployed: "yes",
                      nation: "england" }
      end

      should render_outcome(:results).with_text(
        "If you’ve been made redundant or unemployed, or put on temporary leave (on furlough)",
      )
    end

    context "when a user is self-employed" do
      setup do
        responses = { need_help_with: %w[being_unemployed],
                      self_employed: "yes",
                      have_you_been_made_unemployed: "no",
                      nation: "england" }
      end

      should render_outcome(:results).with_text("If you’re self employed, a freelancer, or a sole trader")
    end

    context "when a user is worried about going to work" do
      setup do
        responses = { need_help_with: %w[going_to_work],
                      worried_about_work: "yes",
                      nation: "england" }
      end

      should render_outcome(:results).with_text("If you’re worried about going in to work")
    end

    context "when a user is worried about self-isolating" do
      setup do
        responses = { need_help_with: %w[self_isolating],
                      worried_about_self_isolating: "yes",
                      nation: "england" }
      end

      should render_outcome(:results).with_text("If you're self-isolating")
    end

    context "when a user is worried about where to live" do
      setup do
        responses = { need_help_with: %w[somewhere_to_live],
                      have_somewhere_to_live: "no",
                      nation: "england" }
      end

      should render_outcome(:results).with_text(
        "If you do not have somewhere to live or might become homeless"
      )
    end

    context "when a user is or might be evicted" do
      setup do
        responses = { need_help_with: %w[somewhere_to_live],
                      have_somewhere_to_live: "yes",
                      have_you_been_eviceted: "yes",
                      nation: "england" }
      end

      should render_outcome(:results).with_text("If you’ve been evicted or might be soon")
    end

    context "when a user has worries about mental health" do
      setup do
        responses = { need_help_with: %w[mental_health],
                      mental_health_worries: "yes",
                      nation: "england" }
      end

      should render_outcome(:results).with_text(
        "If you’re worried about your mental health or someone else’s mental health",
      )
    end

    context "when a user is in Northern Ireland" do
      setup { responses = { need_help_with: %w[none], nation: "northern_ireland" } }
      should render_outcome(:results).with_text("Additional information for Northern Ireland")
    end

    context "when a user is in Scotland" do
      setup { responses = { need_help_with: %w[none], nation: "scotland" } }
      should render_outcome(:results).with_text("Additional information for Scotland")
    end

    context "when a user is in Wales" do
      setup { responses = { need_help_with: %w[none], nation: "wales" } }
      should render_outcome(:results).with_text("Additional information for Wales")
    end
  end
end
