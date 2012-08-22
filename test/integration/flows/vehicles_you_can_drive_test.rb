# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class VehiclesYouCanDriveTest < ActiveSupport::TestCase
  include FlowTestHelper
  
  setup do
    setup_for_testing_flow 'vehicles-you-can-drive'
  end  
  ## Q1
  should "ask what type of vehicle you'd like to drive" do
    assert_current_node :what_type_of_vehicle?
  end
  
  ## Car and light vehicle specs
  context "answer car or light vehicle" do
    setup do
      add_response :car_or_light_vehicle
    end
    ## Q2
    should "ask if you have a licence" do
      assert_current_node :do_you_have_a_driving_licence?
    end
    ## A1
    context "answer yes" do
      should "give the outcome that you may already be elligible" do
        add_response :yes
        assert_current_node :you_may_already_be_elligible
      end
    end
    
    context "answer no" do
      setup do
        add_response :no
      end
      ## Q3
      should "ask how old are you?" do
        assert_current_node :how_old_are_you?
      end
      ## A2
      context "answer under 16" do
        should "state you are not old enough" do
          add_response :under_16
          assert_current_node :not_old_enough
        end
      end
      ## A3
      context "answer 16" do
        should "state you may have mobility rate elligibility" do
          add_response "16"
          assert_current_node :mobility_rate_clause
        end
      end
      ## A4
      context "answer 17 or over" do
        should "state you may have mobility rate elligibility" do
          add_response "17_or_over"
          assert_current_node :elligible_for_provisional_licence
        end
      end
    end
  end ## Car and light vehicle specs
  
  ## Motorcycle specs
  context "answer motorcycle" do
    setup do
      add_response :motorcycle
    end
    
    ## Q4
    should "ask if you have a full motorcycle licence" do
      assert_current_node :do_you_have_a_full_motorcycle_licence?
    end
    
    context "answer yes" do
      setup do
        add_response :yes
      end
      
      ## Q5
      should "ask how old you are" do
        assert_current_node :how_old_are_you_mb?
      end
      context "answer 17-20" do
        setup do
          add_response "17-20"
        end
        should "ask if you've had the licence for more than 2 years" do
          assert_current_node 
        end
      end
    end
    
    context "answer no" do
      setup do
        add_response :no
      end
      ## Q8
      should "ask how old you are" do
        assert_current_node :how_old_are_you_mb_no_licence?
      end
    end
  end ## Motorcycle specs
end
