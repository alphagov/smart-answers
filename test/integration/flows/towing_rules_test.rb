# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class TowingRulesTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'towing-rules'
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
      ## A3
      should "specify entitlement" do
        add_response :yes
        assert_current_node :full_entitlement
      end
    end
    
    context "answer no" do
      setup do
        add_response :no
      end
      ## Q4
      should "ask when your licence was issued" do
        assert_current_node :date_licence_was_issued?
      end
      
      context "answer before jan 1997" do
        ## A5
        should "specify entitlement" do
          add_response "before-jan-1997"
          assert_current_node :car_light_vehicle_entitlement
        end
      end
      context "from jan 1997" do
        ## A6
        should "specify entitlement" do
          add_response "from-jan-1997"
          assert_current_node :limited_trailer_entitlement
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
        end
      end
    end
  end ## Medium sized vehicles

end
