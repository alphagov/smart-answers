require "test_helper"
require "support/flow_test_helper"

class TowingRulesFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow TowingRulesFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: towing_vehicle_type?" do
    setup { testing_node :towing_vehicle_type? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of existing_towing_entitlements? for a 'car-or-light-vehicle' response" do
        assert_next_node :existing_towing_entitlements?, for_response: "car-or-light-vehicle"
      end

      should "have a next node of medium_sized_vehicle_licenceholder? for a 'medium-sized-vehicle' response" do
        assert_next_node :medium_sized_vehicle_licenceholder?, for_response: "medium-sized-vehicle"
      end

      should "have a next node of existing_large_vehicle_licence? for a 'large-vehicle' response" do
        assert_next_node :existing_large_vehicle_licence?, for_response: "large-vehicle"
      end

      should "have a next node of car_licence_before_jan_1997? for a 'minibus' response" do
        assert_next_node :car_licence_before_jan_1997?, for_response: "minibus"
      end

      should "have a next node of bus_licenceholder? for a 'bus' response" do
        assert_next_node :bus_licenceholder?, for_response: "bus"
      end
    end
  end

  context "question: existing_towing_entitlements?" do
    setup do
      testing_node :existing_towing_entitlements?
      add_responses towing_vehicle_type?: "car-or-light-vehicle"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_long_entitlements? for a 'yes' response" do
        assert_next_node :how_long_entitlements?, for_response: "yes"
      end

      should "have a next node of date_licence_was_issued? for a 'no' response" do
        assert_next_node :date_licence_was_issued?, for_response: "no"
      end
    end
  end

  context "question :how_long_entitlements?" do
    setup do
      testing_node :how_long_entitlements?
      add_responses towing_vehicle_type?: "car-or-light-vehicle",
                    existing_towing_entitlements?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of car_light_vehicle_entitlement for a 'before-19-Jan-2013' response" do
        assert_next_node :car_light_vehicle_entitlement, for_response: "before-19-Jan-2013"
      end

      should "have a next node of full_entitlement for a 'after-19-Jan-2013' response" do
        assert_next_node :full_entitlement, for_response: "after-19-Jan-2013"
      end
    end
  end

  context "question: date_licence_was_issued?" do
    setup do
      testing_node :date_licence_was_issued?
      add_responses towing_vehicle_type?: "car-or-light-vehicle",
                    existing_towing_entitlements?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of limited_trailer_entitlement_before_1997 for a 'licence-issued-before-19-Jan-2013' response" do
        assert_next_node :limited_trailer_entitlement_before_1997, for_response: "licence-issued-before-19-Jan-2013"
      end

      should "have a next node of limited_trailer_entitlement_after_1997 for a 'licence-issued-after-19-Jan-2013' response" do
        assert_next_node :limited_trailer_entitlement_after_1997, for_response: "licence-issued-after-19-Jan-2013"
      end
    end
  end

  context "question: medium_sized_vehicle_licenceholder?" do
    setup do
      testing_node :medium_sized_vehicle_licenceholder?
      add_responses towing_vehicle_type?: "medium-sized-vehicle"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_old_are_you_msv? for a 'yes' response" do
        assert_next_node :how_old_are_you_msv?, for_response: "yes"
      end

      should "have a next node of existing_large_vehicle_towing_entitlements? for a 'no' response" do
        assert_next_node :existing_large_vehicle_towing_entitlements?, for_response: "no"
      end
    end
  end

  context "question: how_old_are_you_msv?" do
    setup do
      testing_node :how_old_are_you_msv?
      add_responses towing_vehicle_type?: "medium-sized-vehicle",
                    medium_sized_vehicle_licenceholder?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_old_are_you_msv? for a 'under-21' response" do
        assert_next_node :limited_conditional_trailer_entitlement_msv, for_response: "under-21"
      end

      should "have a next node of limited_trailer_entitlement_msv for a '21-or-over' response" do
        assert_next_node :limited_trailer_entitlement_msv, for_response: "21-or-over"
      end
    end
  end

  context "question: existing_large_vehicle_towing_entitlements?" do
    setup do
      testing_node :existing_large_vehicle_towing_entitlements?
      add_responses towing_vehicle_type?: "medium-sized-vehicle",
                    medium_sized_vehicle_licenceholder?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of included_entitlement_msv for a 'yes' response" do
        assert_next_node :included_entitlement_msv, for_response: "yes"
      end

      should "have a next node of date_licence_was_issued_msv? for a 'no' response" do
        assert_next_node :date_licence_was_issued_msv?, for_response: "no"
      end
    end
  end

  context "question: date_licence_was_issued_msv?" do
    setup do
      testing_node :date_licence_was_issued_msv?
      add_responses towing_vehicle_type?: "medium-sized-vehicle",
                    medium_sized_vehicle_licenceholder?: "no",
                    existing_large_vehicle_towing_entitlements?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of full_entitlement_msv for a 'before-jan-1997' response" do
        assert_next_node :full_entitlement_msv, for_response: "before-jan-1997"
      end

      should "have a next node of how_old_are_you_msv_2? for a 'from-jan-1997' response" do
        assert_next_node :how_old_are_you_msv_2?, for_response: "from-jan-1997"
      end
    end
  end

  context "question: how_old_are_you_msv_2?" do
    setup do
      testing_node :how_old_are_you_msv_2?
      add_responses towing_vehicle_type?: "medium-sized-vehicle",
                    medium_sized_vehicle_licenceholder?: "no",
                    existing_large_vehicle_towing_entitlements?: "no",
                    date_licence_was_issued_msv?: "from-jan-1997"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of too_young_msv for an 'under-18' response" do
        assert_next_node :too_young_msv, for_response: "under-18"
      end

      should "have a next node of apply_for_provisional_with_expceptions_msv for an 'under-21' response" do
        assert_next_node :apply_for_provisional_with_exceptions_msv, for_response: "under-21"
      end

      should "have a next node of apply_for_provisional_msv for a '21-or-over' response" do
        assert_next_node :apply_for_provisional_msv, for_response: "21-or-over"
      end
    end
  end

  context "question: existing_large_vehicle_licence?" do
    setup do
      testing_node :existing_large_vehicle_licence?
      add_responses towing_vehicle_type?: "large-vehicle"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of full_cat_c_entitlement for a 'yes' response" do
        assert_next_node :full_cat_c_entitlement, for_response: "yes"
      end

      should "have a next node of how_old_are_you_lv? for a 'no' response" do
        assert_next_node :how_old_are_you_lv?, for_response: "no"
      end
    end
  end

  context "question: how_old_are_you_lv?" do
    setup do
      testing_node :how_old_are_you_lv?
      add_responses towing_vehicle_type?: "large-vehicle",
                    existing_large_vehicle_licence?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of not_old_enough_lv for a 'under-21' response" do
        assert_next_node :not_old_enough_lv, for_response: "under-21"
      end

      should "have a next node of apply_for_provisional_lv for a '21-or-over' response" do
        assert_next_node :apply_for_provisional_lv, for_response: "21-or-over"
      end
    end
  end

  context "question: car_licence_before_jan_1997?" do
    setup do
      testing_node :car_licence_before_jan_1997?
      add_responses towing_vehicle_type?: "minibus"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of full_entitlement_minibus for a 'yes' response" do
        assert_next_node :full_entitlement_minibus, for_response: "yes"
      end

      should "have a next node of do_you_have_lv_or_bus_towing_entitlement? for a 'no' response" do
        assert_next_node :do_you_have_lv_or_bus_towing_entitlement?, for_response: "no"
      end
    end
  end

  context "question: do_you_have_lv_or_bus_towing_entitlement?" do
    setup do
      testing_node :do_you_have_lv_or_bus_towing_entitlement?
      add_responses towing_vehicle_type?: "minibus",
                    car_licence_before_jan_1997?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of included_entitlement_minibus for a 'yes' response" do
        assert_next_node :included_entitlement_minibus, for_response: "yes"
      end

      should "have a next node of full_minibus_licence? for a 'no' response" do
        assert_next_node :full_minibus_licence?, for_response: "no"
      end
    end
  end

  context "question: full_minibus_licence?" do
    setup do
      testing_node :full_minibus_licence?
      add_responses towing_vehicle_type?: "minibus",
                    car_licence_before_jan_1997?: "no",
                    do_you_have_lv_or_bus_towing_entitlement?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of limited_towing_entitlement_minibus for a 'yes' response" do
        assert_next_node :limited_towing_entitlement_minibus, for_response: "yes"
      end

      should "have a next node of how_old_are_you_minibus? for a 'no' response" do
        assert_next_node :how_old_are_you_minibus?, for_response: "no"
      end
    end
  end

  context "question: how_old_are_you_minibus?" do
    setup do
      testing_node :how_old_are_you_minibus?
      add_responses towing_vehicle_type?: "minibus",
                    car_licence_before_jan_1997?: "no",
                    do_you_have_lv_or_bus_towing_entitlement?: "no",
                    full_minibus_licence?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of not_old_enough_minibus for a 'under-21' response" do
        assert_next_node :not_old_enough_minibus, for_response: "under-21"
      end

      should "have a next node of limited_overall_entitlement_minibus for a '21-or-over' response" do
        assert_next_node :limited_overall_entitlement_minibus, for_response: "21-or-over"
      end
    end
  end

  context "question: bus_licenceholder?" do
    setup do
      testing_node :bus_licenceholder?
      add_responses towing_vehicle_type?: "bus"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of full_entitlement_bus for a 'yes' response" do
        assert_next_node :full_entitlement_bus, for_response: "yes"
      end

      should "have a next node of how_old_are_you_bus? for a 'no' response" do
        assert_next_node :how_old_are_you_bus?, for_response: "no"
      end
    end
  end

  context "question: how_old_are_you_bus?" do
    setup do
      testing_node :how_old_are_you_bus?
      add_responses towing_vehicle_type?: "bus", bus_licenceholder?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of not_old_enough_bus for a 'under-21' response" do
        assert_next_node :not_old_enough_bus, for_response: "under-21"
      end

      should "have a next node of apply_for_provisional_bus for a '21-or-over' response" do
        assert_next_node :apply_for_provisional_bus, for_response: "21-or-over"
      end
    end
  end
end
