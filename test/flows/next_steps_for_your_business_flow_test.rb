require "test_helper"
require "support/flow_test_helper"

class NextStepsForYourBusinessFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow NextStepsForYourBusinessFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: annual_turnover_over_85k" do
    setup { testing_node :annual_turnover_over_85k }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of employ_someone for any response" do
        assert_next_node :employ_someone, for_response: "yes"
      end
    end
  end

  context "question: employ_someone" do
    setup do
      testing_node :employ_someone
      add_responses annual_turnover_over_85k: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of activities for any response" do
        assert_next_node :activities, for_response: "yes"
      end
    end
  end

  context "question: activities" do
    setup do
      testing_node :activities
      add_responses annual_turnover_over_85k: "yes",
                    employ_someone: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of financial_support for any response" do
        assert_next_node :financial_support, for_response: "import_goods"
      end
    end
  end

  context "question: financial_support" do
    setup do
      testing_node :financial_support
      add_responses annual_turnover_over_85k: "yes",
                    employ_someone: "yes",
                    activities: "import_goods"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of business_premises for any response" do
        assert_next_node :business_premises, for_response: "yes"
      end
    end
  end

  context "question: business_premises" do
    setup do
      testing_node :business_premises
      add_responses annual_turnover_over_85k: "yes",
                    employ_someone: "yes",
                    activities: "import_goods",
                    financial_support: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of results for any response" do
        assert_next_node :results, for_response: "home"
      end
    end
  end

  context "outcome: results" do
    setup do
      testing_node :results
      add_responses annual_turnover_over_85k: "no",
                    employ_someone: "no",
                    activities: "none",
                    financial_support: "no",
                    business_premises: "none"
    end

    should "render for result health and safety" do
      assert_rendered_outcome text: "Health and safety at work"
    end

    should "render result for how to run a limited company" do
      assert_rendered_outcome text: "How to run a limited company"
    end

    should "render result for starting overview" do
      assert_rendered_outcome text: "Starting a business overview"
    end

    should "render result for company details on stationery" do
      assert_rendered_outcome text: "Include your company details on stationery"
    end

    should "render result for how to dispose of waste" do
      assert_rendered_outcome text: "How to dispose of your company's waste"
    end

    should "render result for IP" do
      assert_rendered_outcome text: "Protect your brand or designs"
    end

    should "render result for support helpline" do
      assert_rendered_outcome text: "Get help from the Business Support Helpline"
    end

    should "render result for CH email reminders" do
      assert_rendered_outcome text: "Sign up for Companies House email reminders"
    end

    should "render result for licenses" do
      assert_rendered_outcome text: "Check if you need any licences for your business"
    end

    should "render result for insurance" do
      assert_rendered_outcome text: "Check if you need insurance"
    end

    should "render result for self assessment" do
      assert_rendered_outcome text: "Check if you need to send a Self Assessment"
    end

    should "render result for selling goods and services" do
      assert_rendered_outcome text: "Selling goods or services"
    end

    should "render result for anti-competitive activity" do
      assert_rendered_outcome text: "Avoid anti-competitive activity"
    end

    should "render result for dealing with personal information" do
      assert_rendered_outcome text: "Learn how to deal with personal information"
    end

    should "render VAT results if business has annual turnover more than 85k" do
      add_responses annual_turnover_over_85k: "yes"
      assert_rendered_outcome text: "Register for VAT"
      assert_rendered_outcome text: "How and when to charge VAT"
    end

    should "render VAT result if business is unsure of annual turnover" do
      add_responses annual_turnover_over_85k: "not_sure"
      assert_rendered_outcome text: "Check if you'll need to register for VAT"
    end

    should "render VAT result if business annual turnover is less than 85k" do
      add_responses annual_turnover_over_85k: "no"
      assert_rendered_outcome text: "You can register for VAT if you want to"
    end

    should "hide corporation tax guidance based on ct parameter" do
      assert_match "Register for Corporation Tax", @test_flow.outcome_text
      add_responses ct: "true"
      assert_no_match "Register for Corporation Tax", @test_flow.outcome_text
    end

    should "render results for financial support if user needs financial support" do
      add_responses financial_support: "yes"
      assert_rendered_outcome text: "See what finance and support is available"
      assert_rendered_outcome text: "Get financial support during coronavirus"
    end

    should "render the results if business may employ people" do
      add_responses employ_someone: "yes"
      assert_rendered_outcome text: "Check what to do before employing someone"
      assert_rendered_outcome text: "Guidance on employing people"
    end

    should "render the results if business premise is at home" do
      add_responses business_premises: %w[home]
      assert_rendered_outcome text: "Check the rules on running a business from home"
    end

    should "render the results if business premise is rented" do
      add_responses business_premises: %w[rented]
      assert_rendered_outcome text: "Your responsibilities when renting"
      assert_rendered_outcome text: "Find out about rules for business premises"
      assert_rendered_outcome text: "Show a sign where your business operates"
    end

    should "render the results if business is exporting goods and services" do
      add_responses activities: %w[export_goods_or_services]
      assert_rendered_outcome text: "How to sell items abroad"
      assert_rendered_outcome text: "Find out about export markets"
    end

    should "render the results if business is importing goods" do
      add_responses activities: %w[import_goods]
      assert_rendered_outcome text: "How to buy items from abroad"
    end
  end
end
