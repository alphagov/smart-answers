require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/report-a-lost-or-stolen-passport"

class ReportALostOrStolenPassportTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    @location_slugs = %w(azerbaijan canada)
    stub_world_locations(@location_slugs)
    setup_for_testing_flow SmartAnswer::ReportALostOrStolenPassportFlow
  end

  should "ask where the passport was lost or stolen" do
    assert_current_node :where_was_the_passport_lost_or_stolen?
  end

  context "in the UK " do
    setup do
      add_response :in_the_uk
    end

    should "tell you to fill out the LS01 form" do
      assert_current_node :complete_LS01_form
    end
  end

  context "abroad" do
    setup do
      add_response :abroad
    end

    should "ask in which country has been lost/stolen" do
      assert_current_node :which_country?
    end

    context "in Azerbaijan" do
      setup do
        add_response "azerbaijan"
      end

      should "tell you to report it to the embassy" do
        assert_current_node :contact_the_embassy
      end
    end
  end

  context "abroad" do
    setup do
      add_response :abroad
    end

    should "ask in which country has been lost/stolen" do
      assert_current_node :which_country?
    end

    context "in Canada" do
      setup do
        add_response "canada"
      end

      should "tell you to fill in a form and visit the embassy" do
        assert_current_node :contact_the_embassy_canada
        assert_match(/Fill in form LS01 and post it to your nearest British embassy, high commission or consulate./, outcome_body)
      end
    end
  end
end
