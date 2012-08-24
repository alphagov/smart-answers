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
      add_response "car-or-light-vehicle"
    end
    ## Q2
    should "ask if you have a licence" do
      assert_current_node :do_you_have_a_driving_licence?
    end
    ## A1
    context "answer yes" do
      should "give the outcome that you may already be entitled" do
        add_response :yes
        assert_current_node :you_may_already_be_entitled
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
          add_response "under-16"
          assert_current_node :not_old_enough
        end
      end
      ## A3
      context "answer 16" do
        should "state you may have mobility rate entitlement" do
          add_response "16"
          assert_current_node :mobility_rate_clause
        end
      end
      ## A4
      context "answer 17 or over" do
        should "state you may have mobility rate entitlement" do
          add_response "17-or-over"
          assert_current_node :entitled_for_provisional_licence
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
            assert_current_node :entitled_for_any_motorcycle #A5
          end
        end
        context "answer no" do
          ## A7
          should "state entitlement" do
            add_response :no
            assert_current_node :entitled_for_same_motorcycle # A6
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
            assert_current_node :entitled_for_any_motorcycle_21 #A7
          end
        end
        context "answer no" do
          ## A8
          should "state entitlement" do
            add_response :no
            assert_current_node :entitled_for_same_motorcycle_21 # A8
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
        should "state entitlement" do
          add_response "under-17"
          assert_current_node :motorcycle_entitlement_no_licence_under_17 # A10
        end
      end
      context "answer 17-20" do
        ## A11
        should "state entitlement" do
          add_response "17-20"
          assert_current_node :motorcycle_entitlement_no_licence_17_20 # A11
        end
      end
      context "answer 21 or over" do
        ## A12
        should "state entitlement" do
          add_response "21-or-over"
          assert_current_node :motorcycle_entitlement_no_licence_21_and_over # A12
        end
      end
    end
  end ## Motorcycle specs
  
  ## Moped specs
  context "answer moped" do
    setup do
      add_response :moped
    end
    ## Q9
    should "ask do you have a full driving licence?" do
      assert_current_node :do_you_have_a_full_driving_licence?
    end
    context "answer yes" do
      setup do
        add_response :yes
      end
      ## Q10
      should "ask if the licence was issued before feb 2001" do
        assert_current_node :licence_issued_before_2001?
      end
    end
    context "answer no" do
      setup do
        add_response :no
      end
      ## Q11
      should "ask how old you are" do
        assert_current_node :how_old_are_you_mpd?
      end
      context "answer under 16" do
        ## A15
        should "state you cannot ride a moped" do
          add_response "under-16"
          assert_current_node :moped_not_old_enough # A15
        end
      end
      context "answer 16 or over" do
        ## A16
        should "state provisional licence entitlement" do
          add_response "16-or-over"
          assert_current_node :moped_apply_for_provisional # A16
        end
      end
    end
  end ## Moped specs
  
  ## Medium sized vehicles
  context "answer medium sized vehicle" do
    setup do
      add_response "medium-sized-vehicle"
    end
    ## Q12
    should "ask if you have a full cat B licence" do
      assert_current_node :do_you_have_a_full_cat_b_driving_licence?
    end
    context "answer yes" do
      setup do
        add_response :yes
      end
      ## Q13
      should "ask when the licence was issued" do
        assert_current_node :when_was_licence_issued?
      end
      context "answer before jan 1997" do
        ## A17
        should "state that you are entitled" do
          add_response "before-jan-1997"
          assert_current_node :entitled_for_msv # A17
        end
      end
      context "answer from jan 1997" do
        setup do
          add_response "from-jan-1997"
        end
        ## Q14
        should "ask how old you are" do
          assert_current_node :how_old_are_you_msv?
        end
        context "answer under 18" do
          ## A18
          should "state you are not allowed to drive medium sized vehicles" do
            add_response "under-18"
            assert_current_node :not_entitled_for_msv_until_18 # A18
          end
        end
        context "answer 18 or over" do
          ## A19
          should "tell you to apply for provisional entitlement" do
            add_response "18-or-over"
            assert_current_node :apply_for_provisional_msv_entitlement #A19
          end
        end
      end
    end
    ## Full cat B licence?
    context "answer no" do
      ## A20
      should "state you need a full cat B licence" do
        add_response :no
        assert_current_node :cat_b_licence_required #A20
      end
    end
  end ## Medium sized vehicles
  
  ## Lorries and large vehicles
  context "answer large vehicle or lorry" do
    setup do
      add_response "large-vehicle-or-lorry"
    end
    ## Q15
    should "ask how old you are" do
      assert_current_node :how_old_are_you_lorry?
    end
    context "answer under 18" do
      ## A21
      should "state you are not entitled until 18" do
        add_response "under-18"
        assert_current_node :not_entitled_for_lorry_until_18 # A21
      end
    end
    context "answer 18-20" do
      ## A22
      should "state the limited entitlement for 18-20 age group" do
        add_response "18-20"
        assert_current_node :limited_entitlement_lorry # A22
      end
    end
    context "answer 21 or over" do
      setup do
        add_response "21-or-over"
      end
      ## Q16
      should "ask if you have a full cat B licence" do
        assert_current_node :do_you_have_a_full_cat_b_car_licence? # Q16
      end
      context "answer yes" do
        setup do
          add_response :yes
        end
        ## Q17
        should "ask when the licence was issued" do
          assert_current_node :when_was_cat_b_licence_issued?
        end
        context "answer before jan 1997" do
          ## A23
          should "say apply for provisional cat C entitlement" do
            add_response "before-jan-1997"
            assert_current_node :apply_for_provisional_cat_c_entitlement #A23
          end
        end
        context "answer from jan 1997" do
          ## A24
          should "state conditional provisional cat C entitlement" do
            add_response "from-jan-1997"
            assert_current_node :apply_for_conditional_provisional_cat_c_entitlement #A24
          end
        end        
      end
      ## Full cat B licence?
      context "answer no" do
        ## A25
        should "state a cat B driving licence is required" do
          add_response :no
          assert_current_node :cat_b_driving_licence_required #A25
        end
      end
    end
  end ## Lorries and large vehicles
  
  ## Minibus / PSV
  context "answer minibus" do
    setup do
      add_response :minibus
    end
    ## Q18
    should "ask if you have a cat B licence" do
      assert_current_node :full_cat_b_car_licence_psv?
    end
    context "answer yes" do
      setup do
        add_response :yes
      end
      ## Q19
      should "ask when the licence was issued" do
        assert_current_node :when_was_licence_issued_psv?
      end
      context "answer before-jan-1997" do
        ## A26
        should "state that you are entitled" do
          add_response "before-jan-1997"
          assert_current_node :psv_entitled # A26
        end
      end
      context "answer from-jan-1997" do
        setup do
          add_response "from-jan-1997"
        end
        ## Q20
        should "ask how old you are" do
          assert_current_node :how_old_are_you_psv?
        end
        context "answer under 21" do
          ## A27
          should "state conditional entitlement" do
            add_response "under-21"
            assert_current_node :psv_conditional_entitlement # A27
          end
        end
        context "answer 21 or over" do
          ## A28
          should "state limited entitlement" do
            add_response "21-or-over"
            assert_current_node :psv_limited_entitlement # A28
          end
        end
      end
    end
    context "answer no" do
      ## A27
      should "tell you about conditional entitlement" do
        add_response :no
        assert_current_node :psv_conditional_entitlement #A 27
      end
    end
  end ## Minibus / PSV
  
  ## Bus / Cat D
  context "answer bus" do
    setup do
      add_response :bus
    end
    ## Q21
    should "ask if you have a full cat B driving licence" do
      assert_current_node :full_cat_b_licence_bus?
    end
    context "answer yes" do
      setup do
        add_response :yes
      end
      ## Q22
      should "ask how old you are" do
        assert_current_node :how_old_are_you_bus?
      end
      should "state exceptions for under 18s" do
        add_response "under-18"
        assert_current_node :bus_exceptions_under_18 # A29
      end
      should "state exceptions for 18-19 year olds" do
        add_response "18-19"
        assert_current_node :bus_exceptions_18_19 # A30
      end
      should "state exceptions for 20 year olds" do
        add_response "20"
        assert_current_node :bus_exceptions_20 # A31
      end
      should "advise you to apply for a cat D licence" do
        add_response "21-or-above"
        assert_current_node :bus_apply_for_cat_d # A32
      end
    end
    context "answer no" do
      should "say apply for a cat B licence" do
        add_response :no
        assert_current_node :bus_apply_for_cat_b # A33
      end
    end
  end ## Bus / Cat D
  
  ## Tractors
  context "answer tractor" do
    setup do
      add_response :tractor
    end
    ## Q23
    should "ask if you have a full cat B licence" do
      assert_current_node :full_cat_b_licence_tractor?
    end
    context "answer yes" do
      ## A34
      should "say you are entitled" do
        add_response :yes
        assert_current_node :tractor_entitled #A34
      end
    end
    context "answer no" do
      setup do
        add_response :no
      end
      ## Q24
      should "ask how old you are" do
        assert_current_node :how_old_are_you_tractor?
      end
      context "answer under 16" do
        ## A35
        should "state you cannot drive a tractor under 16" do
          add_response "under-16"
          assert_current_node :tractor_not_old_enough # A35
        end
      end
      context "answer 16" do
        ## A36
        should "state you can apply for a provisional cat F licence" do
          add_response "16"
          assert_current_node :tractor_apply_for_provisional_conditional_licence # A36
        end
      end
      context "answer 17 or over" do
        ## A37
        should "state you can apply for provisional entitlement" do
          add_response "17-or-over"
          assert_current_node :tractor_apply_for_provisional_entitlement # A37
        end
      end
    end
  end ## Tractors
  
  ## Specialist vehicles
  context "answer specialist vehicle" do
    setup do
      add_response "specialist-vehicle"
    end
    ## Q25
    should "ask if you have a full cat B licence" do
      assert_current_node :full_cat_b_licence_sv?
    end
    context "answer yes" do
      setup do
        add_response :yes
      end
      ## Q26
      should "ask how old you are" do
        assert_current_node :how_old_are_you_licence_sv?
      end
      context "answer 17-20" do
        ## A38
        should "state ellibility" do
          add_response "17-20"
          assert_current_node :sv_entitled_cat_k # A38
        end
      end
      context "answer 21-or-over" do
        ## A39
        should "state ellibility" do
          add_response "21-or-over"
          assert_current_node :sv_entitled_cat_k_provisional_g_h # A39
        end
      end
    end
    context "answer no" do
      setup do
        add_response :no
      end
      ## Q27
      should "ask how old you are" do
        assert_current_node :how_old_are_you_no_licence_sv?
      end
      context "answer under 16" do
        ## A40
        should "state you are not entitled" do
          add_response "under-16"
          assert_current_node :sv_not_old_enough # A40
        end
      end
      context "answer 16" do
        ## A41
        should "state entitlement" do
          add_response "16"
          assert_current_node :sv_entitled_cat_k_mower # A41
        end
      end
      context "answer 17-20" do
        ## A42
        should "state entitlement" do
          add_response "17-20"
          assert_current_node :sv_entitled_cat_k_conditional_g_h # A42
        end
      end
      context "answer 21-or-over" do
        ## A43
        should "state entitlement" do
          add_response "21-or-over"
          assert_current_node :sv_entitled_no_licence # A43
        end
      end
    end
  end ## Specialist vehicles
  
  ## Quad bikes
  context "answer quad bike" do
    setup do
      add_response "quad-bike"
    end
    ## Q28
    should "ask if you have a full cat b licence" do
      assert_current_node :full_cat_b_licence_quad?
    end
    context "answer yes" do
      ## A44
      should "state entitlement" do
        add_response :yes
        assert_current_node :quad_entitled # A44
      end
    end
    context "answer no" do
      setup do
        add_response :no
      end
      ## Q29
      should "ask how old you are" do
        assert_current_node :how_old_are_you_quad?
      end
      context "answer under 16" do
        ## A45
        should "state you are not old enough" do
          add_response "under-16"
          assert_current_node :quad_not_old_enough # A45
        end
      end
      context "answer 16" do
        ## A46
        should "state disability conditional entitlement" do
          add_response "16"
          assert_current_node :quad_disability_conditional_entitlement # A46
        end
      end
      context "answer 17 or over" do
        ## A47
        should "state provisional entitlement" do
          add_response "17-or-over"
          assert_current_node :quad_apply_for_provisional_entitlement # A47
        end
      end
    end
  end
end
