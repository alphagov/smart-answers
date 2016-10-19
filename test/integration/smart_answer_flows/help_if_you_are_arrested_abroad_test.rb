require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/help-if-you-are-arrested-abroad"

class HelpIfYouAreArrestedAbroadTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    @location_slugs = %w(aruba belgium greece iran syria democratic-republic-of-the-congo)
    stub_world_locations(@location_slugs)
    setup_for_testing_flow SmartAnswer::HelpIfYouAreArrestedAbroadFlow
  end

  should "ask which country the arrest is in" do
    assert_current_node :which_country?
  end

  context "In a country with a prisoner pack" do
    context "Answering with a country without any specific downloads / information" do
      context "Answering Aruba" do
        setup do
          add_response :aruba
        end

        should "take the user to the generic answer" do
          assert_current_node :answer_one_generic
        end

        should "correctly calculate and store the country variables" do
          assert_state_variable :country, "aruba"
          assert_state_variable :country_name, "Aruba"
        end

        should "correctly set up phrase lists" do
          assert_state_variable :has_extra_downloads, false
        end
      end # context: Andorra
    end # context: country without specific info

    context "Answering with a country that has specific downloads / information" do
      context "Answering Democratic Republic of the Congo" do
        setup do
          add_response :"democratic-republic-of-the-congo"
        end

        should "take the user to the generic answer" do
          assert_current_node :answer_one_generic
        end

        should "set up the country specific downloads" do
          assert_state_variable :has_extra_downloads, true
        end
      end

      context "Answering Greece" do
        setup do
          add_response :greece
        end

        should "take the user to the generic answer" do
          assert_current_node :answer_one_generic
        end

        should "set up the country specific downloads" do
          assert_state_variable :has_extra_downloads, true
        end
      end
    end # context: country with specific info
  end # context: non special case

  context "In Syria" do
    setup do
      add_response :syria
    end

    should "take the user to the Syria answer" do
      assert_current_node :answer_three_syria
    end
  end
end
