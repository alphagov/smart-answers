require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/towing-rules"

class TowingRulesTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::TowingRulesFlow
  end
  ## Cars and light vehicles
  ##
  ## Q1
  should "ask which type of tow vehicle" do
    assert_current_node :towing_vehicle_type?
  end

  context "answer car or light vehicle" do
    setup do
      add_response "car-or-light-vehicle"
    end
    ## Q2
    should "ask if you have existing towing entitlements" do
      assert_current_node :existing_towing_entitlements?
    end
    context "answer yes" do
      setup do
        add_response :yes
      end
      ## Q2A
      should "ask when did you get this entitlement on your licence" do
        assert_current_node :how_long_entitlements?
      end
      context "answer before 19 jan 2013" do
        ## A3
        should "take you to car_light_vehicle_entitlement outcome" do
          add_response :"before-19-Jan-2013"
          assert_current_node :car_light_vehicle_entitlement
        end
      end
      context "answer after 19 jan 2013" do
        ## A4
        should "take you to full_entitlement outcome" do
          add_response :"after-19-Jan-2013"
          assert_current_node :full_entitlement
        end
      end
    end
    context "answer no" do
      setup do
        add_response :no
      end
      ## Q5
      should "ask when your licence was issued" do
        assert_current_node :date_licence_was_issued?
      end
      context "answer before 19 jan 2013" do
        ## A6
        should "take you to limited_trailer_entitlement outcome" do
          add_response "licence-issued-before-19-Jan-2013"
          assert_current_node :limited_trailer_entitlement
        end
      end
      context "answer after 19 jan 2013" do
        ## A7
        should "take you to limited_trailer_entitlement_2013 outcome" do
          add_response "licence-issued-after-19-Jan-2013"
          assert_current_node :limited_trailer_entitlement_2013
        end
      end
    end
  end ## Cars and light vehicles

  ## Medium sized vehicles
  context "answer medium sized vehicles" do
    setup do
      add_response "medium-sized-vehicle"
    end
    ## Q9
    should "ask if you have existing entitlement" do
      assert_current_node :medium_sized_vehicle_licenceholder?
    end
    context "answer yes" do
      setup do
        add_response :yes
      end
      ## Q9
      should "ask how old you are" do
        assert_current_node :how_old_are_you_msv?
      end
      context "answer under 21" do
        should "specify entitlement" do
          add_response "under-21"
          assert_current_node :limited_conditional_trailer_entitlement_msv
        end
      end
      context "answer 21 or over" do
        should "specify entitlement" do
          add_response "21-or-over"
          assert_current_node :limited_trailer_entitlement_msv
        end
      end
    end
    context "answer no" do
      setup do
        add_response :no
      end
      ## Q12
      should "ask if you have existing large vehicle towing entitlements" do
        assert_current_node :existing_large_vehicle_towing_entitlements?
      end
      context "answer yes" do
        should "" do
          add_response :yes
          assert_current_node :included_entitlement_msv
        end
      end
      context "answer no" do
        setup do
          add_response :no
        end
        ## Q14
        should "ask when your licence was issued" do
          assert_current_node :date_licence_was_issued_msv?
        end
        context "answer before january 1997" do
          ## A15
          should "specify entitlement" do
            add_response "before-jan-1997"
            assert_current_node :full_entitlement_msv
          end
        end
        context "answer after jan 1997" do
          setup do
            add_response "from-jan-1997"
          end
          ## Q16
          should "ask how old you are" do
            assert_current_node :how_old_are_you_msv_2?
          end
          context "answer under 18" do
            ## A17
            should "specify entitlement" do
              add_response "under-18"
              assert_current_node :too_young_msv
            end
          end
          context "answer under 21" do
            ## A18
            should "specify entitlement" do
              add_response "under-21"
              assert_current_node :apply_for_provisional_with_exceptions_msv
            end
          end
          context "answer 21 or over" do
            ## A19
            should "specify entitlement" do
              add_response "21-or-over"
              assert_current_node :apply_for_provisional_msv
            end
          end
        end
      end
    end
  end ## Medium sized vehicles

  ## Large vehicles
  context "answer large vehicle" do
    setup do
      add_response "large-vehicle"
    end
    ## Q20
    should "ask if you have a large vehicle licence" do
      assert_current_node :existing_large_vehicle_licence?
    end
    context "answer yes" do
      should "specify entitlement" do
        add_response :yes
        assert_current_node :full_cat_c_entitlement
      end
    end
    context "answer no" do
      setup do
        add_response :no
      end
      ## Q22
      should "ask how old you are" do
        assert_current_node :how_old_are_you_lv?
      end
      context "answer under 21" do
        ## A23
        should "specify entitlement" do
          add_response "under-21"
          assert_current_node :not_old_enough_lv
        end
      end
      context "answer 21 or over" do
        ## A24
        should "specify entitlement" do
          add_response "21-or-over"
          assert_current_node :apply_for_provisional_lv
        end
      end
    end
  end ## Large vehicles

  ## Minibuses
  context "answer minibus" do
    setup do
      add_response :minibus
    end
    ## Q25
    should "ask if you held a car licence before jan 1997" do
      assert_current_node :car_licence_before_jan_1997?
    end
    context "answer yes" do
      should "" do
        add_response :yes
        assert_current_node :full_entitlement_minibus
      end
    end
    context "answer no" do
      setup do
        add_response :no
      end
      ## Q27
      should "ask if you have bus or large vehicle towing entitlement" do
        assert_current_node :do_you_have_lv_or_bus_towing_entitlement?
      end
      context "answer yes" do
        ## A28
        should "specify entitlement" do
          add_response :yes
          assert_current_node :included_entitlement_minibus
        end
      end
      context "answer no" do
        setup do
          add_response :no
        end
        ## Q29
        should "ask if you have a full minibus licence" do
          assert_current_node :full_minibus_licence?
        end
        context "answer yes" do
          ## A30
          should "specify entitlement" do
            add_response :yes
            assert_current_node :limited_towing_entitlement_minibus
          end
        end
        context "answer no" do
          setup do
            add_response :no
          end
          ##  Q31
          should "ask how old you are" do
            assert_current_node :how_old_are_you_minibus?
          end
          context "answer under 21" do
            ## A32
            should "specify entitlement" do
              add_response "under-21"
              assert_current_node :not_old_enough_minibus
            end
          end
          context "answer 21 or above" do
            setup do
              add_response "21-or-over"
            end
            ## A34
            should "specify entitlement" do
              assert_current_node :limited_overall_entitlement_minibus
            end
          end
        end
      end
    end
  end ## Minibuses

  ## Buses
  context "answer bus" do
    setup do
      add_response :bus
    end
    ## Q36
    should "ask if you already have a licence to drive a bus" do
      assert_current_node :bus_licenceholder?
    end
    context "answer yes" do
      ## A37
      should "specify entitlement" do
        add_response :yes
        assert_current_node :full_entitlement_bus
      end
    end
    context "answer no" do
      setup do
        add_response :no
      end
      ## Q38
      should "ask how old you are" do
        assert_current_node :how_old_are_you_bus?
      end
      context "answer under 21" do
        ## A39
        should "specify entitlement" do
          add_response "under-21"
          assert_current_node :not_old_enough_bus
        end
      end
      context "amswer 21 or over" do
        ## A40
        should "specify entitlement" do
          add_response "21-or-over"
          assert_current_node :apply_for_provisional_bus
        end
      end
    end
  end ## Buses
end
