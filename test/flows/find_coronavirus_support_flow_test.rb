require "test_helper"
require "support/flow_test_helper"

class FindCoronavirusSupportFlowFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow FindCoronavirusSupportFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: need_help_with" do
    setup { testing_node :need_help_with }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of nation for an empty response" do
        assert_next_node :nation, for_response: %w[none]
      end

      should "have a next node based on the response" do
        assert_next_node :self_employed, for_response: %w[being_unemployed mental_health]
      end
    end
  end

  context "question: feel_unsafe" do
    setup do
      testing_node :feel_unsafe
      add_responses need_help_with: %w[feeling_unsafe]
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of nation for any response if there aren't any other needs_help_with questions" do
        assert_next_node :nation, for_response: "yes"
      end

      should "have next node of next question group for any response if there are other needs_help_with questions" do
        add_responses need_help_with: %w[feeling_unsafe mental_health]

        assert_next_node :mental_health_worries, for_response: "yes"
      end
    end
  end

  context "question: afford_rent_mortgage_bills" do
    setup do
      testing_node :afford_rent_mortgage_bills
      add_responses need_help_with: %w[paying_bills]
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of nation for any response if there aren't any other needs_help_with questions" do
        assert_next_node :nation, for_response: "yes"
      end

      should "have next node of next question group for any response if there are other needs_help_with questions" do
        add_responses need_help_with: %w[paying_bills mental_health]

        assert_next_node :mental_health_worries, for_response: "yes"
      end
    end
  end

  context "question: afford_food" do
    setup do
      testing_node :afford_food
      add_responses need_help_with: %w[getting_food]
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of get_food for any response" do
        assert_next_node :get_food, for_response: "yes"
      end
    end
  end

  context "question: get_food" do
    setup do
      testing_node :get_food
      add_responses need_help_with: %w[getting_food],
                    afford_food: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of nation for any response if there aren't any other needs_help_with questions" do
        assert_next_node :nation, for_response: "yes"
      end

      should "have next node of next question group for any response if there are other needs_help_with questions" do
        add_responses need_help_with: %w[getting_food mental_health]

        assert_next_node :mental_health_worries, for_response: "yes"
      end
    end
  end

  context "question: self_employed" do
    setup do
      testing_node :self_employed
      add_responses need_help_with: %w[being_unemployed]
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of nation if response is yes and there aren't any other needs_help_with questions" do
        assert_next_node :nation, for_response: "yes"
      end

      should "have next node of next question group for response yes if there are other needs_help_with questions" do
        add_responses need_help_with: %w[being_unemployed mental_health]

        assert_next_node :mental_health_worries, for_response: "yes"
      end

      %w[no not_sure].each do |response|
        should "have a next node of have_you_been_made_unemployed if response is #{response}" do
          assert_next_node :have_you_been_made_unemployed, for_response: response
        end
      end
    end
  end

  context "question: have_you_been_made_unemployed" do
    setup do
      testing_node :have_you_been_made_unemployed
      add_responses need_help_with: %w[being_unemployed],
                    self_employed: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of nation for any response if there aren't any other needs_help_with questions" do
        assert_next_node :nation, for_response: "yes_i_have_been_made_unemployed"
      end

      should "have next node of next question group for any response if there are other needs_help_with questions" do
        add_responses need_help_with: %w[being_unemployed mental_health]

        assert_next_node :mental_health_worries, for_response: "yes_i_have_been_made_unemployed"
      end
    end
  end

  context "question: worried_about_work" do
    setup do
      testing_node :worried_about_work
      add_responses need_help_with: %w[going_to_work]
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of nation for any response if there aren't any other needs_help_with questions" do
        assert_next_node :nation, for_response: "yes"
      end

      should "have next node of next question group for any response if there are other needs_help_with questions" do
        add_responses need_help_with: %w[going_to_work mental_health]

        assert_next_node :mental_health_worries, for_response: "yes"
      end
    end
  end

  context "question: worried_about_self_isolating" do
    setup do
      testing_node :worried_about_self_isolating
      add_responses need_help_with: %w[self_isolating]
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of nation for any response if there aren't any other needs_help_with questions" do
        assert_next_node :nation, for_response: "yes"
      end

      should "have next node of next question group for any response if there are other needs_help_with questions" do
        add_responses need_help_with: %w[self_isolating mental_health]

        assert_next_node :mental_health_worries, for_response: "yes"
      end
    end
  end

  context "question: have_somewhere_to_live" do
    setup do
      testing_node :have_somewhere_to_live
      add_responses need_help_with: %w[somewhere_to_live]
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of have_you_been_evicted for any response" do
        assert_next_node :have_you_been_evicted, for_response: "yes"
      end
    end
  end

  context "question: have_you_been_evicted" do
    setup do
      testing_node :have_you_been_evicted
      add_responses need_help_with: %w[somewhere_to_live],
                    have_somewhere_to_live: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of nation for any response if there aren't any other needs_help_with questions" do
        assert_next_node :nation, for_response: "yes"
      end

      should "have next node of next question group for any response if there are other needs_help_with questions" do
        add_responses need_help_with: %w[somewhere_to_live mental_health]

        assert_next_node :mental_health_worries, for_response: "yes"
      end
    end
  end

  context "question: mental_health_worries" do
    setup do
      testing_node :mental_health_worries
      add_responses need_help_with: %w[mental_health]
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of nation for any response" do
        assert_next_node :nation, for_response: "yes"
      end
    end
  end

  context "question: nation" do
    setup do
      testing_node :nation
      add_responses need_help_with: %w[none]
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of results for any response" do
        assert_next_node :results, for_response: "wales"
      end
    end
  end

  context "outcome: results" do
    setup { testing_node :results }

    context "feeling_unsafe" do
      setup do
        add_responses need_help_with: %w[feeling_unsafe],
                      feel_unsafe: "yes",
                      nation: "england"
      end

      should "render feeling_unsafe guidance if need_help_with? is feeling_unsafe" do
        assert_rendered_outcome text: "If you feel unsafe where you live or you’re worried about someone else"
      end

      should "render extra guidance for Northern Ireland" do
        add_responses nation: "northern_ireland"

        assert_rendered_outcome text: "Get help from Nexus NI"
      end

      should "render extra guidance for Scotland" do
        add_responses nation: "scotland"

        assert_rendered_outcome text: "Get help from Women’s Aid Scotland"
      end

      should "render extra guidance for Wales" do
        add_responses nation: "wales"

        assert_rendered_outcome text: "Get help from Live Fear Free"
      end
    end

    context "paying_bills" do
      setup do
        add_responses need_help_with: %w[paying_bills],
                      afford_rent_mortgage_bills: "yes",
                      nation: "england"
      end

      should "render paying_bills guidance if need_help_with? is paying_bills" do
        assert_rendered_outcome text: "If you’re finding it hard to pay your rent, mortgage or bills"
      end

      should "render extra guidance for England" do
        assert_rendered_outcome text: "(Shelter)"
      end

      should "render extra guidance for Scotland" do
        add_responses nation: "scotland"

        assert_rendered_outcome text: "(Shelter Scotland)"
      end

      should "render extra guidance for Wales" do
        add_responses nation: "wales"

        assert_rendered_outcome text: "(Shelter Cymru)"
      end

      should "render extra guidance for Northern Ireland" do
        add_responses nation: "northern_ireland"

        assert_rendered_outcome text: "Get help from the housing and debt helpline for Northern Ireland"
      end
    end

    context "getting_food" do
      setup do
        add_responses need_help_with: %w[getting_food],
                      afford_food: "yes",
                      get_food: "yes",
                      nation: "england"
      end

      should "render afford_food guidance if afford_food is yes" do
        assert_rendered_outcome text: "If you’re finding it hard to afford food"
      end

      should "render extra afford_food guidance for England" do
        assert_rendered_outcome text: "Find out if you can get help from a foodbank"
      end

      should "render extra afford_food guidance for Scotland" do
        add_responses nation: "scotland"

        assert_rendered_outcome text: "Scottish Welfare Fund"
      end

      should "render extra afford_food guidance for Wales" do
        add_responses nation: "wales"

        assert_rendered_outcome text: "(Welsh Government)"
      end

      should "render extra afford_food guidance for Northern Ireland" do
        add_responses nation: "northern_ireland"

        assert_rendered_outcome text: "Community Helpline for Northern Ireland"
      end

      should "render get_food if get_food is no" do
        add_responses get_food: "no"

        assert_rendered_outcome text: "If you’re unable to get food or medicine"
      end
    end

    context "being_unemployed" do
      context "have_you_been_made_unemployed" do
        setup do
          add_responses need_help_with: %w[being_unemployed],
                        self_employed: "no",
                        have_you_been_made_unemployed: "yes_i_have_been_made_unemployed",
                        nation: "england"
        end

        should "render have_you_been_made_unemployed guidance if have_you_been_made_unemployed is yes_i_have_been_made_unemployed" do
          assert_rendered_outcome text: "If you’ve been made redundant or unemployed, or put on temporary leave (on furlough)"
        end

        should "render extra have_you_been_made_unemployed guidance for England" do
          assert_match "https://www.citizensadvice.org.uk/work/coronavirus-being-furloughed-if-you-cant-work/", @test_flow.outcome_body
        end

        should "render extra have_you_been_made_unemployed guidance for Northern Ireland" do
          add_responses nation: "northern_ireland"

          assert_rendered_outcome text: "Find out about the financial support and benefits you might be able to get (NI direct)"
        end

        should "render extra have_you_been_made_unemployed guidance for Wales" do
          add_responses nation: "wales"

          assert_match "https://www.citizensadvice.org.uk/wales/work/coronavirus-being-furloughed-if-you-cant-work/", @test_flow.outcome_body
        end

        should "render extra have_you_been_made_unemployed guidance for Scotland" do
          add_responses nation: "scotland"

          assert_rendered_outcome text: "Get help if you’ve been made redundant (mygov.scot)"
        end
      end

      context "self_employed" do
        setup do
          add_responses need_help_with: %w[being_unemployed],
                        self_employed: "yes",
                        nation: "england"
        end

        should "render self_employed guidance if get_food is yes" do
          assert_rendered_outcome text: "If you’re self employed, a freelancer, or a sole trader"
        end

        should "render extra have_you_been_made_unemployed guidance for England" do
          assert_match "https://www.citizensadvice.org.uk/benefits/universal-credit/", @test_flow.outcome_body
        end

        should "render extra have_you_been_made_unemployed guidance for Northern Ireland" do
          add_responses nation: "northern_ireland"

          assert_rendered_outcome text: "Get help with your business rates and find out about coronavirus loans (nibusinessinfo)"
        end

        should "render extra have_you_been_made_unemployed guidance for Wales" do
          add_responses nation: "wales"

          assert_rendered_outcome text: "Check if you’re eligible for the Discretionary Assistance Fund (Welsh Government)"
        end

        should "render extra have_you_been_made_unemployed guidance for Scotland" do
          add_responses nation: "scotland"

          assert_rendered_outcome text: "Find financial support for your business (Scottish Government)"
        end
      end
    end

    context "going_to_work" do
      setup do
        add_responses need_help_with: %w[going_to_work],
                      worried_about_work: "yes",
                      nation: "england"
      end

      should "render going_to_work guidance if need_help_with? is going_to_work" do
        assert_rendered_outcome text: "If you’re worried about going in to work"
      end

      should "render extra guidance for England" do
        assert_match "https://www.citizensadvice.org.uk/work/coronavirus-if-youre-worried-about-working/", @test_flow.outcome_body
      end

      should "render extra guidance for Scotland" do
        add_responses nation: "scotland"

        assert_rendered_outcome text: "What to do if you’ve been told to go back in to work and you’re worried (Citizens Advice Scotland)"
      end

      should "render extra guidance for Wales" do
        add_responses nation: "wales"

        assert_match "https://www.citizensadvice.org.uk/wales/work/coronavirus-if-youre-worried-about-working/", @test_flow.outcome_body
      end

      should "render extra guidance for Northern Ireland" do
        add_responses nation: "northern_ireland"

        assert_rendered_outcome text: "Get help from Citizens Advice"
      end
    end

    context "self_isolating" do
      setup do
        add_responses need_help_with: %w[self_isolating],
                      worried_about_self_isolating: "yes",
                      nation: "england"
      end

      should "render self_isolating guidance if need_help_with? is self_isolating" do
        assert_rendered_outcome text: "If you’re self-isolating"
      end

      should "render extra guidance for England" do
        assert_rendered_outcome text: "Apply for a Test and Trace Support Payment"
      end

      should "render extra guidance for Wales" do
        add_responses nation: "wales"

        assert_rendered_outcome text: "(Welsh Government)"
      end
    end

    context "somewhere_to_live" do
      setup do
        add_responses need_help_with: %w[somewhere_to_live],
                      have_somewhere_to_live: "no",
                      have_you_been_evicted: "yes",
                      nation: "england"
      end

      should "render have_somewhere_to_live guidance if have_somewhere_to_live is no" do
        assert_rendered_outcome text: "If you do not have somewhere to live or might become homeless"
      end

      should "render have_you_been_evicted guidance if have_you_been_evicted is yes" do
        assert_rendered_outcome text: "If you’ve been evicted or might be soon"
      end

      should "render extra have_somewhere_to_live guidance for England" do
        assert_rendered_outcome text: "(Shelter)"
      end

      should "render extra have_somewhere_to_live guidance for Wales" do
        add_responses nation: "wales"

        assert_rendered_outcome text: "(Shelter Cymru)"
      end

      should "render extra have_somewhere_to_live guidance for Scotland" do
        add_responses nation: "scotland"

        assert_rendered_outcome text: "Shelter Scotland"
      end

      should "render extra have_somewhere_to_live guidance for Northern Ireland" do
        add_responses nation: "northern_ireland"

        assert_rendered_outcome text: "Northern Ireland Housing Executive"
      end
    end

    context "mental_health" do
      setup do
        add_responses need_help_with: %w[mental_health],
                      mental_health_worries: "yes",
                      nation: "england"
      end

      should "render mental_health guidance if need_help_with? is mental_health" do
        assert_rendered_outcome text: "If you’re worried about your mental health or someone else’s mental health"
      end

      should "render extra guidance for Northern Ireland" do
        add_responses nation: "northern_ireland"

        assert_rendered_outcome text: "(NI direct)"
      end

      should "render extra guidance for Scotland" do
        add_responses nation: "scotland"

        assert_rendered_outcome text: "Scottish Association for Mental Health"
      end
    end

    context "no results" do
      setup do
        add_responses need_help_with: %w[none],
                      nation: "england"
      end

      should "render no information guidance if need_help_with? is none" do
        assert_rendered_outcome text: "There’s no specific information for you in this service at the moment."
      end

      should "render extra guidance for England" do
        assert_rendered_outcome text: "Find information about what you can do from Citizens Advice"
      end

      should "render extra guidance for Scotland" do
        add_responses nation: "scotland"

        assert_rendered_outcome text: "Citizens Advice Scotland"
      end

      should "render extra guidance for Wales" do
        add_responses nation: "wales"

        assert_rendered_outcome text: "(Welsh Government)"
      end

      should "render extra guidance for Northern Ireland" do
        add_responses nation: "northern_ireland"

        assert_rendered_outcome text: "(NI Direct)"
      end
    end
  end
end
