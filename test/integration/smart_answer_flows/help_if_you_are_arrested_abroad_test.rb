require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/help-if-you-are-arrested-abroad"

class HelpIfYouAreArrestedAbroadTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    @location_slugs = %w[aruba belgium bermuda greece iran syria democratic-republic-of-the-congo]
    stub_world_locations(@location_slugs)
    setup_for_testing_flow SmartAnswer::HelpIfYouAreArrestedAbroadFlow
  end

  should "ask which country the arrest is in" do
    assert_current_node :which_country?
  end

  context "In a country with a prisoner pack" do
    context "Answering with a country without any specific downloads / information" do
      should "take the user to the generic answer" do
        add_response :aruba
        assert_current_node :answer_one_generic
      end
    end

    context "Answering with a country that has specific downloads / information" do
      context "Answering Democratic Republic of the Congo" do
        should "take the user to the generic answer" do
          add_response :"democratic-republic-of-the-congo"
          assert_current_node :answer_one_generic
          assert_select outcome_body, "h2", /Download prisoner packs/
        end
      end

      context "Answering Greece" do
        should "take the user to the generic answer" do
          add_response :greece
          assert_current_node :answer_one_generic
          assert_select outcome_body, "h2", /Download prisoner packs/
        end
      end
    end
  end

  context "In Iran" do
    setup do
      add_response :iran
    end

    should "take the user to the generic anwser with Iran specific downloads" do
      assert_current_node :answer_one_generic
      assert_select outcome_body, "a", /imprisoned in Iran/
    end
  end

  context "In Syria" do
    setup do
      add_response :syria
    end

    should "take the user to the Syria answer" do
      assert_current_node :answer_three_syria
    end
  end

  context "In a British overseas territory" do
    setup do
      add_response :bermuda
      assert_current_node :answer_three_british_overseas_territories
    end
  end
end
