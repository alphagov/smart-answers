require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/towing-rules"

class TowingRulesTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::TowingRulesFlow
  end

  context "start page" do
    should see_start_page.with_title("  Work out if you’re old enough or have the right kind of licence to tow a trailer from different kinds of vehicle")
  end

  context "question :towing_vehicle_type" do
    should see_question(:towing_vehicle_type).with_title("What kind of vehicle do you want to tow with?")
    should accept_answer("car-or-light-vehicle").with_next_node(:existing_towing_entitlements?)
    should accept_answer("medium-sized-vehicle").with_next_node(:medium_sized_vehicle_licenceholder?)
    should accept_answer("large-vehicle").with_next_node(:existing_large_vehicle_licence?)
    should accept_answer("minibus").with_next_node(:car_licence_before_jan_1997?)
    should accept_answer("bus").with_next_node(:bus_licenceholder?)
  end

  context "question :existing_towing_entitlements?" do
    setup do
      responses = { towing_vehicle_type: "car-or-light-vehicle" }
    end

    should see_question(:existing_towing_entitlements).with_title("Do you already have a driving licence with any of the following entitlements on it:")
    should accept_answer("yes").with_next_node(:how_long_entitlements?)
    should accept_answer("no").with_next_node(:date_licence_was_issued?)
  end

  context "question :how_long_entitlements?" do
    setup do
      responses = { towing_vehicle_type: "car-or-light-vehicle", existing_towing_entitlements?: "yes" }
    end

    should see_question(:how_long_entitlements).with_title("When did you get this entitlement on your licence?")
    should accept_answer("before-19-Jan-2013").with_next_node(:car_light_vehicle_entitlement)
    should accept_answer("after-19-Jan-2013").with_next_node(:full_entitlement?)
  end

  context "question :date_licence_was_issued?" do
    setup do
      responses = { towing_vehicle_type: "car-or-light-vehicle", existing_towing_entitlements?: "no" }
    end

    should see_question(:date_licence_was_issued).with_title("When was your driving licence issued?")
    should accept_answer("licence-issued-before-19-Jan").with_next_node(:limited_trailer_entitlement)
    should accept_answer("licence-issued-after-19-Jan").with_next_node(:limited_trailer_entitlement_2013)
  end

  context "question :medium_sized_vehicle_licenceholder?" do
    setup do
      responses = { :towing_vehicle_type?: "medium-sized-vehicle" }
    end

    should see_question(:medium_sized_vehicle_licenceholder).with_title("Do you already have a C1 medium-sized vehicle licence?")
    should accept_answer("yes").with_next_node(:how_old_are_you_msv)
    should accept_answer("no").with_next_node(:existing_large_vehicle_towing_entitlements)
  end

  context "question :how_old_are_you_msv?" do
    setup do
      responses = { :towing_vehicle_type?: "medium-sized-vehicle", :medium_sized_vehicle_licenceholder?: "yes" }
    end

    should see_question(:how_old_are_you_msv).with_title("How old are you?")
    should accept_answer("under-21").with_next_node(:limited_conditional_trailer_entitlement_msv)
    should accept_answer("21-or-over").with_next_node(:limited_trailer_entitlement_msv)
  end

  context "question :existing_large_vehicle_towing_entitlements?" do
    setup do
      responses = { :towing_vehicle_type?: "medium-sized-vehicle", :medium_sized_vehicle_licenceholder?: "no" }
    end

    should see_question(:existing_large_vehicle_towing_entitlements).with_title("Do you already have a driving licence with the C+E towing with a large vehicle entitlement on it?")
    should accept_answer("yes").with_next_node(:included_entitlement_msv)
    should accept_answer("no").with_next_node(:date_licence_was_issued_msv)
  end

  context "question :date_licence_was_issued_msv?" do
    setup do
      responses = { :towing_vehicle_type?: "medium-sized-vehicle", :medium_sized_vehicle_licenceholder?: "no", :existing_large_vehicle_towing_entitlements: "no" }
    end

    should see_question(:date_licence_was_issued_msv).with_title("When was your driving licence issued?")
    should accept_answer("before-jan-1997").with_next_node(:full_entitlement_msv)
    should accept_answer("after-jan-1997").with_next_node(:how_old_are_you_msv_2)
  end

  context "question :how_old_are_you_msv_2?" do
    setup do
      responses = { :towing_vehicle_type?: "medium-sized-vehicle", :medium_sized_vehicle_licenceholder?: "no", :existing_large_vehicle_towing_entitlements: "no", :date_licence_was_issued_msv: "after-jan-1997" }
    end

    should see_question(:how_old_are_you_msv_2).with_title("How old are you?")
    should accept_answer("under-18").with_next_node(:too_young_msv)
    should accept_answer("under-21").with_next_node(:apply_for_provisional_with_exceptions_msv)
    should accept_answer("21-or-over").with_next_node(:apply_for_provisional_msv)
  end

  context "question :existing_large_vehicle_licence?" do
    setup do
      responses = { :towing_vehicle_type?: "large-vehicle"  }
    end

    should see_question(:existing_large_vehicle_licence).with_title("Do you already have a category C large vehicle licence?")
    should accept_answer("yes").with_next_node(:full_cat_c_entitlement)
    should accept_answer("no").with_next_node(:how_old_are_you_lv)
  end

  context "question :how_old_are_you_lv?" do
    setup do
      responses = { :towing_vehicle_type?: "large-vehicle", :existing_large_vehicle_licence: "no" }
    end

    should see_question(:how_old_are_you_lv).with_title("How old are you?")
    should accept_answer("under-21").with_next_node(:not_old_enough_lv)
    should accept_answer("21-or-over").with_next_node(:apply_for_provisional_lv)
  end

  context "question :car_licence_before_jan_1997?" do
    setup do
      responses = { :towing_vehicle_type?: "minibus" }
    end

    should see_question(:car_licence_before_jan_1997).with_title("Did you pass your test before 1 January 1997?")
    should accept_answer("yes").with_next_node(:full_entitlement_minibus)
    should accept_answer("no").with_next_node(:do_you_have_lv_or_bus_towing_entitlement)
  end

  context "question :do_you_have_lv_or_bus_towing_entitlement?" do
    setup do
      responses = { :towing_vehicle_type?: "minibus", :car_licence_before_jan_1997: "no" }
    end

    should see_question(:do_you_have_lv_or_bus_towing_entitlement?).with_title("Do you have a full category D+E towing with a bus licence?")
    should accept_answer("yes").with_next_node(:included_entitlement_minibus)
    should accept_answer("no").with_next_node(:full_minibus_licence?)
  end

  context "question :full_minibus_licence?" do
    setup do
      responses = { :towing_vehicle_type?: "minibus", :car_licence_before_jan_1997: "no", :do_you_have_lv_or_bus_towing_entitlement?: "no" }
    end

    should see_question(:full_minibus_licence?).with_title("Do you have a full category D1 minibus licence?")
    should accept_answer("yes").with_next_node(:limited_towing_entitlement_minibus?)
    should accept_answer("no").with_next_node(:how_old_are_you_minibus?)
  end

  context "question :how_old_are_you_minibus?" do
    setup do
      responses = { :towing_vehicle_type?: "minibus", :car_licence_before_jan_1997: "no", :do_you_have_lv_or_bus_towing_entitlement?: "no", :full_minibus_licence?: "no" }
    end

    should see_question(:how_old_are_you_minibus).with_title("How old are you?")
    should accept_answer("under-21").with_next_node(:not_old_enough_minibus)
    should accept_answer("21-or-over").with_next_node(:limited_overall_entitlement_minibus)
  end

  context "question :bus_licenceholder?" do
    setup do
      responses = { :towing_vehicle_type?: "bus" }
    end

    should see_question(:bus_licenceholder?).with_title("Do you already have a full category D bus licence?")
    should accept_answer("yes").with_next_node(:full_entitlement_bus)
    should accept_answer("no").with_next_node(:how_old_are_you_bus?)
  end

  context "question :how_old_are_you_bus?" do
    setup do
      responses = { :towing_vehicle_type?: "bus", :bus_licenceholder?: "no" }
    end

    should see_question(:how_old_are_you_bus).with_title("How old are you?")
    should accept_answer("under-21").with_next_node(:not_old_enough_bus)
    should accept_answer("21-or-over").with_next_node(:apply_for_provisional_bus)
  end

  context "outcome :car_light_vehicle_entitlement" do
    setup do
      responses = { towing_vehicle_type: "car-or-light-vehicle", existing_towing_entitlements?: "yes", how_long_entitlements?: "before-19-Jan-2013" }
    end

    should see_outcome(:car_light_vehicle_entitlement).with_text("You can already tow trailers up to 3,500kg MAM (maximum authorised mass) with a car.")
  end

  context "outcome :full_entitlement" do
    setup do
      responses = { towing_vehicle_type: "car-or-light-vehicle", existing_towing_entitlements?: "yes", how_long_entitlements?: "after-19-Jan-2013" }
    end

    should see_outcome(:full_entitlement).with_text("You can already tow trailers of any weight with a car.")
  end

  context "outcome :limited_trailer_entitlement" do
    setup do
      responses = { towing_vehicle_type: "car-or-light-vehicle", existing_towing_entitlements?: "no", date_licence_was_issued?: "licence-issued-before-19-Jan-2013" }
    end

    should see_outcome(:limited_trailer_entitlement).with_text("Check if you have category B or B+E on your licence.")
  end

  context "outcome :limited_trailer_entitlement_2013" do
    setup do
      responses = { towing_vehicle_type: "car-or-light-vehicle", existing_towing_entitlements?: "no", date_licence_was_issued?: "licence-issued-after-19-Jan-2013" }
    end

    should see_outcome(:limited_trailer_entitlement_2013).with_text("You can already tow trailers up to 750kg.")
  end

  context "outcome :limited_conditional_trailer_entitlement_msv" do
    setup do
      responses = { :towing_vehicle_type?: "medium-sized-vehicle", :medium_sized_vehicle_licenceholder?: "yes", :how_old_are_you_msv?: "under-21" }
    end

    should see_outcome(:limited_conditional_trailer_entitlement_msv).with_text("You can tow trailers up to 750kg with a standard C1 medium-sized vehicle licence as long as the vehicle weight is not more than 7,500kg.")
  end

  context "outcome :limited_trailer_entitlement_msv" do
    setup do
      responses = { :towing_vehicle_type?: "medium-sized-vehicle", :medium_sized_vehicle_licenceholder?: "yes", :how_old_are_you_msv?: "21-or-over" }
    end

    should see_outcome(:limited_trailer_entitlement_msv).with_text("You can tow trailers up to 750kg with a standard C1 medium-sized vehicle licence as long as the vehicle weight is not more than 7,500kg.")
  end

  context "outcome :included_entitlement_msv" do
    setup do
      responses = { :towing_vehicle_type?: "medium-sized-vehicle", :medium_sized_vehicle_licenceholder?: "no", :existing_large_vehicle_towing_entitlements?: "yes" }
    end

    should see_outcome(:included_entitlement_msv).with_text("You already have the C1+E towing with a medium-sized vehicle entitlement on your licence.")
  end

  context "outcome :full_entitlement_msv" do
    setup do
      responses = { :towing_vehicle_type?: "medium-sized-vehicle", :medium_sized_vehicle_licenceholder?: "no", :existing_large_vehicle_towing_entitlements?: "no", :date_licence_was_issued_msv?: "before-jan-1997" }
    end

    should see_outcome(:full_entitlement_msv).with_text("You already have a restricted C1+E towing with a medium-sized vehicle entitlement on your licence.")
  end

  context "outcome :too_young_msv" do
    setup do
      responses = { :towing_vehicle_type?: "medium-sized-vehicle", :medium_sized_vehicle_licenceholder?: "no", :existing_large_vehicle_towing_entitlements?: "no", :date_licence_was_issued_msv?: "from-jan-1997", :how_old_are_you_msv_2?: "under-18" }
    end

    should see_outcome(:too_young_msv).with_text("You’re too young to tow with a category C1 medium-sized vehicle.")
  end

  context "outcome :apply_for_provisional_with_exceptions_msv" do
    setup do
      responses = { :towing_vehicle_type?: "medium-sized-vehicle", :medium_sized_vehicle_licenceholder?: "no", :existing_large_vehicle_towing_entitlements?: "no", :date_licence_was_issued_msv?: "from-jan-1997", :how_old_are_you_msv_2?: "under-21" }
    end

    should see_outcome(:apply_for_provisional_with_exceptions_msv).with_text("You can tow trailers up to 750kg with a standard C1 medium-sized vehicle licence as long as the vehicle weight is not more than 7,500kg.")
  end

  context "outcome :apply_for_provisional_msv" do
    setup do
      responses = { :towing_vehicle_type?: "medium-sized-vehicle", :medium_sized_vehicle_licenceholder?: "no", :existing_large_vehicle_towing_entitlements?: "no", :date_licence_was_issued_msv?: "from-jan-1997", :how_old_are_you_msv_2?: "21-or-over" }
    end

    should see_outcome(:apply_for_provisional_msv).with_text("If you apply for a provisional C1 medium-sized vehicle licence then pass the C1 test you can tow trailers up to 750kg, as long as the combined vehicle and trailer weight is not more than 7,500kg.")
  end

  context "outcome :full_cat_c_entitlement" do
    setup do
      responses = { :towing_vehicle_type?: "large-vehicle", :existing_large_vehicle_licence?: "yes" }
    end

    should see_outcome(:full_cat_c_entitlement).with_text("You can tow trailers up to 750kg with a standard category C large vehicle licence.")
  end

  context "outcome :not_old_enough_lv" do
    setup do
      responses = { :towing_vehicle_type?: "large-vehicle", :existing_large_vehicle_licence?: "no", :how_old_are_you_lv?: "under-21" }
    end

    should see_outcome(:not_old_enough_lv).with_text("In most cases you have to wait until you’re 21 to drive, or tow, with a category C large vehicle.")
  end

  context "outcome :apply_for_provisional_lv" do
    setup do
      responses = { :towing_vehicle_type?: "large-vehicle", :existing_large_vehicle_licence?: "no", :how_old_are_you_lv?: "21-or-over" }
    end

    should see_outcome(:apply_for_provisional_lv).with_text("If you get provisional category C large vehicle entitlement then pass the category C test you can tow trailers up to 750kg.")
  end

  context "outcome :full_entitlement_minibus" do
    setup do
      responses = { :towing_vehicle_type?: "minibus", :car_licence_before_jan_1997?: "yes" }
    end

    should see_outcome(:full_entitlement_minibus).with_text("You can already tow with minibuses, but ‘not for hire or reward’.")
  end

  context "outcome :included_entitlement_minibus" do
    setup do
      responses = { :towing_vehicle_type?: "minibus", :car_licence_before_jan_1997?: "no", :do_you_have_lv_or_bus_towing_entitlement?: "yes" }
    end

    should see_outcome(:included_entitlement_minibus).with_text("You can already tow with minibuses.")
  end

  context "outcome :limited_towing_entitlement_minibus" do
    setup do
      responses = { :towing_vehicle_type?: "minibus", :car_licence_before_jan_1997?: "no", :do_you_have_lv_or_bus_towing_entitlement?: "no", :full_minibus_licence?: "yes" }
    end

    should see_outcome(:limited_towing_entitlement_minibus).with_text("You can already tow trailers up to 750kg with your D1 minibus licence.")
  end

  context "outcome :not_old_enough_minibus" do
    setup do
      responses = { :towing_vehicle_type?: "minibus", :car_licence_before_jan_1997?: "no", :do_you_have_lv_or_bus_towing_entitlement?: "no", :full_minibus_licence?: "no", :how_old_are_you_minibus?: "under-21" }
    end

    should see_outcome(:not_old_enough_minibus).with_text("You cannot normally drive or tow with a minibus until you’re 21. You then need to first take the D1 minibus test to tow trailers up to 750kg. To tow heavier trailers you’ll then need to take the D1+E towing test.")
  end

  context "outcome :limited_overall_entitlement_minibus" do
    setup do
      responses = { :towing_vehicle_type?: "minibus", :car_licence_before_jan_1997?: "no", :do_you_have_lv_or_bus_towing_entitlement?: "no", :full_minibus_licence?: "no", :how_old_are_you_minibus?: "21-or-over" }
    end

    should see_outcome(:limited_overall_entitlement_minibus).with_text("You need to apply for a provisional D1 minibus licence then pass a D1 minibus test to tow trailers up to 750kg.")
  end

  context "outcome :full_entitlement_bus" do
    setup do
      responses = { :towing_vehicle_type?: "bus", :bus_licenceholder?: "yes" }
    end

    should see_outcome(:full_entitlement_bus).with_text("You can already tow trailers up to 750kg. To tow heavier trailers you need to apply for provisional D+E towing with a bus entitlement then pass the D+E test.")
  end

  context "outcome :not_old_enough_bus" do
    setup do
      responses = { :towing_vehicle_type?: "bus", :bus_licenceholder?: "no", :how_old_are_you_bus?: "under-21" }
    end

    should see_outcome(:not_old_enough_bus).with_text("You cannot normally tow with a bus until you’re 21. You’ll then need to pass the category D test to tow trailers up to 750kg, and then pass the D+E test to tow heavier trailers.")
  end

  context "outcome :apply_for_provisional_bus" do
    setup do
      responses = { :towing_vehicle_type?: "bus", :bus_licenceholder?: "no", :how_old_are_you_bus?: "21-or-over" }
    end

    should see_outcome(:apply_for_provisional_bus).with_text("You need to apply for provisional category D bus entitlement then pass a category D test. You can then tow trailers up to 750kg.")
  end
end
