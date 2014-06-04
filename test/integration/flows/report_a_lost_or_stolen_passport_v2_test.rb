require_relative "../../test_helper"
require_relative "flow_test_helper"
require 'gds_api/test_helpers/worldwide'

class ReportALostOrStolenPassportV2Test < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide

  setup do
    @location_slugs = %w(azerbaijan)
    worldwide_api_has_locations(@location_slugs)
    json = read_fixture_file('worldwide/azerbaijan_organisations.json')
    worldwide_api_has_organisations_for_location('azerbaijan', json)
    setup_for_testing_flow "report-a-lost-or-stolen-passport-v2"
  end

  should "ask where the passport was lost or stolen" do
    assert_current_node :where_was_the_passport_lost_or_stolen?
  end

  context "in the UK " do
      setup do
	add_response :in_the_uk
      end

    should "ask whether the passport is for a child or an adult" do
      assert_current_node :adult_or_child_passport?
    end

    context "for an Adult" do
	setup do
	  add_response :adult
	end

        should "tell you to fill out the LS01 form" do
          assert_current_node :complete_LS01_form
          assert_phrase_list :child_advice, []
        end
      end
      context "child" do
        setup do
          add_response :child
        end
        should "tell you to fill out the LS01 form" do
          assert_current_node :complete_LS01_form
          assert_phrase_list :child_advice, [:child_forms]
        end
      end
    end
    context "abroad" do
    setup do
      add_response :abroad
    end

      should "ask whether the passport is for a child or an adult" do
        assert_current_node :adult_or_child_passport?
      end

      context "for an Adult" do
      setup do
	add_response :adult
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
          assert_phrase_list :child_advice, []
          assert_match /British Embassy Baku/, outcome_body
        end
      end
    end
    context "for a Child" do
      setup do
        add_response :child
      end
    should "ask which country you lost your passport in" do
        assert_current_node :which_country?
      end
      context "in Azerbaijan" do
        setup do
          add_response "azerbaijan"
        end

        should "tell you to report it to the embassy" do
          assert_current_node :contact_the_embassy
          assert_phrase_list :child_advice, [:child_forms]
        end
      end
    end
  end
end
