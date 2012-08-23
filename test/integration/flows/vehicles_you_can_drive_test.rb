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
    ## full motorcycle licence?
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
        ## Q6
        should "ask if you've had the licence for more than 2 years" do
          assert_current_node :had_mb_licence_for_more_than_2_years_17_20?
        end
        context "answer yes" do
          ## A6
          should "state elligility" do
            add_response :yes
            assert_current_node :ellibile_for_any_motorcycle #A5
          end
        end
        context "answer no" do
          ## A7
          should "state elligibility" do
            add_response :no
            assert_current_node :elligible_for_same_motorcycle # A6
          end
        end
      end
      context "answer 21" do
        setup do
          add_response "21"
        end
        ## Q6
        should "ask if you've had the licence for more than 2 years" do
          assert_current_node :had_mb_licence_for_more_2_years_21?
        end
        context "answer yes" do
          ## A7
          should "state elligility" do
            add_response :yes
            assert_current_node :elligible_for_any_motorcycle_21 #A7
          end
        end
        context "answer no" do
          ## A8
          should "state elligibility" do
            add_response :no
            assert_current_node :elligible_for_same_motorcycle_21 # A8
          end
        end
      end
    end
    ## full motorcycle licence?
    context "answer no" do
      setup do
        add_response :no
      end
      ## Q8
      should "ask how old you are" do
        assert_current_node :how_old_are_you_mb_no_licence?
      end
      context "answer under 17" do
        ## A10
        should "state elligibility" do
          add_response "under_17"
          assert_current_node :motorcycle_elligibility_no_licence_under_17 # A10
        end
      end
      context "answer 17-20" do
        ## A11
        should "state elligibility" do
          add_response "17-20"
          assert_current_node :motorcycle_elligibility_no_licence_17_20 # A11
        end
      end
      context "answer 21 or over" do
        ## A12
        should "state elligibility" do
          add_response "21_or_over"
          assert_current_node :motorcycle_elligibility_no_licence_21_and_over # A12
        end
      end
    end
  end ## Motorcycle specs
end
