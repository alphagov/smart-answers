require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/towing-rules"

class TowingRulesTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::TowingRulesFlow
  end

  context "question :towing_vehicle_type" do
    should see_question(:towing_vehicle_type).with_title("What kind of vehicle do you want to tow with?")

    should "take car or light vehicle users to existing towing entitlements question" do
      add_response "car-or-light-vehicle"
      assert_equal :existing_towing_entitlements?, next_node_name
    end

    should "take medium sized vehicle users to medium sized vehicle licenceholder question" do
      add_response "medium-sized-vehicle"
      assert_equal :medium_sized_vehicle_licenceholder?, next_node_name
    end

    should "take large vehicle users to existing large vehicle licence question" do
      add_response "large-vehicle"
      assert_equal :existing_large_vehicle_licence?, next_node_name
    end

    should "take minibus users to existing car licence before 1997 question" do
      add_response "minibus"
      assert_equal :car_licence_before_jan_1997?, next_node_name
    end

    should "take bus users to bus licenceholder question" do
      add_response "bus"
      assert_equal :bus_licenceholder?, next_node_name
    end
  end

  context "question :existing_towing_entitlements?" do
    should see_question(:existing_towing_entitlements).with_title("Do you already haveDo you already have a driving licence with any of the following entitlements on it:")

    should "take users with existing towing entitlement to how long entitlement question" do
      add_response "yes"
      assert_equal :how_long_entitlements?, next_node_name
    end

    should "take users without existing towing entitlement to date licence was issued question" do
      add_response "no"
      assert_equal :date_licence_was_issued?, next_node_name
    end
  end

  context "question :how_long_entitlements?" do
    should see_question(:how_long_entitlements).with_title("When did you get this entitlement on your licence?")

    should "take users with existing entitlement from before 19 Jan 2013 to car and light vehicle entitlement question" do
      add_response "before-19-Jan-2013"
      assert_equal :car_light_vehicle_entitlement, next_node_name
    end

    should "take users with existing entitlement from after 19 Jan 2013 to full entitlement question" do
      add_response "after-19-Jan-2013"
      assert_equal :full_entitlement?, next_node_name
    end
  end

  context "question :date_licence_was_issued?" do
    should see_question(:date_licence_was_issued).with_title("When was your driving licence issued?")

    should "take users with licence from before 19 Jan 2013 to limited trailer entitlement question" do
      add_response "licence-issued-before-19-Jan"
      assert_equal :limited_trailer_entitlement, next_node_name
    end

    should "take users with licence from after 19 Jan 2013 to limited trailer entitlement 2013 question" do
      add_response "licence-issued-after-19-Jan-2013"
      assert_equal :limited_trailer_entitlement_2013, next_node_name
    end
  end

  context "question :medium_sized_vehicle_licenceholder?" do
    should see_question(:medium_sized_vehicle_licenceholder).with_title("Do you already have a C1 medium-sized vehicle licence?")

    should "take users with medium sized vehicle licence to how old are you question" do
      add_response "yes"
      assert_equal :how_old_are_you_msv, next_node_name
    end

    should "take users without medium sized vehicle licence to existing large vehicle licence towing entielements question" do
      add_response "no"
      assert_equal :existing_large_vehicle_towing_entitlements, next_node_name
    end
  end

  context "question :how_old_are_you_msv?" do
    should see_question(:how_old_are_you_msv).with_title("How old are you?")

    should "take users under the age of 21 to limited conditional trailer entitlement outcome" do
      add_response "under-21"
      assert_equal :limited_conditional_trailer_entitlement_msv, next_node_name
    end

    should "take users over the age of 21 to limited trailer entitlement outcome" do
      add_response "under-21"
      assert_equal :limited_trailer_entitlement_msv, next_node_name
    end
  end

  context "question :existing_large_vehicle_towing_entitlements?" do
    should see_question(:existing_large_vehicle_towing_entitlements).with_title("Do you already have a driving licence with the C+E towing with a large vehicle entitlement on it?")

    should "take users with existing large vehicle towing entitlements to included entitlement outcome" do
      add_response "yes"
      assert_equal :included_entitlement_msv, next_node_name
    end

    should "take users without existing large vehicle towing entitlements to date licence was issued question" do
      add_response "no"
      assert_equal :date_licence_was_issued_msv, next_node_name
    end
  end

  context "question :date_licence_was_issued_msv?" do
    should see_question(:date_licence_was_issued_msv).with_title("When was your driving licence issued?")

    should "take users with a licence issued before January 1997 to full entitlement outcome" do
      add_response "before-jan-1997"
      assert_equal :full_entitlement_msv, next_node_name
    end

    should "take users with a licence issued after January 1997 to how old are you msv 2 question" do
      add_response "after-jan-1997"
      assert_equal :how_old_are_you_msv_2, next_node_name
    end
  end

  context "question :how_old_are_you_msv_2?" do
    should see_question(:how_old_are_you_msv_2).with_title("How old are you?")

    should "take users under the age of 18 to too young outcome" do
      add_response "under-18"
      assert_equal :too_young_msv, next_node_name
    end

    should "take users under the age of 21 to apply for provisional with exceptions msv outcome" do
      add_response "under-21"
      assert_equal :apply_for_provisional_with_exceptions_msv, next_node_name
    end

    should "take users over the age of 21 to apply for provisional msv outcome" do
      add_response "21-or-over"
      assert_equal :apply_for_provisional_msv, next_node_name
    end
  end

  context "question :existing_large_vehicle_licence?" do
    should see_question(:existing_large_vehicle_licence).with_title("Do you already have a category C large vehicle licence?")

    should "take users with existing large vehicle licence to full cat c entitlement outcome" do
      add_response "yes"
      assert_equal :full_cat_c_entitlement, next_node_name
    end

    should "take users without existing large vehicle licence to how old are you lv question" do
      add_response "no"
      assert_equal :how_old_are_you_lv, next_node_name
    end
  end

  context "question :how_old_are_you_lv?" do
    should see_question(:how_old_are_you_lv).with_title("How old are you?")

    should "take users under the age of 21 to not old enough lv outcome" do
      add_response "under-21"
      assert_equal :not_old_enough_lv, next_node_name
    end

    should "take users under the age of 21 to apply for provisional lv outcome" do
      add_response "21-or-over"
      assert_equal :apply_for_provisional_lv, next_node_name
    end
  end

  context "question :car_licence_before_jan_1997?" do
    should see_question(:car_licence_before_jan_1997).with_title("Did you pass your test before 1 January 1997?")

    should "take users with a licence from before January 1997 to full entitlement minibus outcome" do
      add_response "yes"
      assert_equal :full_entitlement_minibus, next_node_name
    end

    should "take users with a licence from after January 1997 to do you have lv or bus towing entitlement question" do
      add_response "no"
      assert_equal :do_you_have_lv_or_bus_towing_entitlement, next_node_name
    end
  end

  context "question :do_you_have_lv_or_bus_towing_entitlement?" do
    should see_question(:do_you_have_lv_or_bus_towing_entitlement).with_title("Do you have a full category D+E towing with a bus licence?")

    should "take users with lv or bus towing entitlement to included entitlemnt minibus outcome" do
      add_response "yes"
      assert_equal :included_entitlement_minibus, next_node_name
    end

    should "take users without lv or bus towing entitlement to full minibus licence question" do
      add_response "no"
      assert_equal :full_minibus_licence?, next_node_name
    end
  end

  context "question :full_minibus_licence?" do
    should see_question(:full_minibus_licence).with_title("Do you have a full category D1 minibus licence?")

    should "take users with a full minibus licence to limited towing entitlement minibus outcome" do
      add_response "yes"
      assert_equal :limited_towing_entitlement_minibus, next_node_name
    end

    should "take users without a full minibus licence to how old are you minibus question" do
      add_response "no"
      assert_equal :how_old_are_you_minibus, next_node_name
    end
  end

  context "question :how_old_are_you_minibus?" do
    should see_question(:how_old_are_you_minibus).with_title("How old are you?")

    should "take users under the age of 21 to not old enough minibus outcome" do
      add_response "under-21"
      assert_equal :not_old_enough_minibus, next_node_name
    end

    should "take users under the age of 21 to limited overall entitlement minibus outcome" do
      add_response "21-or-over"
      assert_equal :limited_overall_entitlement_minibus, next_node_name
    end
  end

  context "question :bus_licenceholder?" do
    should see_question(:bus_licenceholder).with_title("Do you already have a full category D bus licence?")

    should "take users with a bus licence to full entitlement bus outcome" do
      add_response "yes"
      assert_equal :full_entitlement_bus, next_node_name
    end

    should "take users without a bus licence to how old are you bus question" do
      add_response "no"
      assert_equal :how_old_are_you_bus?, next_node_name
    end
  end

  context "question :how_old_are_you_bus?" do
    should see_question(:how_old_are_you_bus).with_title("How old are you?")

    should "take users under the age of 21 to not old enough bus outcome" do
      add_response "under-21"
      assert_equal :not_old_enough_bus, next_node_name
    end

    should "take users under the age of 21 to apply for provisional bus outcome" do
      add_response "21-or-over"
      assert_equal :apply_for_provisional_bus, next_node_name
    end
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
