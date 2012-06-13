# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class WhatCanIDriveTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'what-can-i-drive'
  end

  should "ask what kind of vehicle you want to drive" do
    assert_current_node :what_do_you_want_to_drive?
  end

  context "Car (category B)" do
    setup do
      add_response :car
    end

    should "ask if you have a licence" do
      assert_current_node :car_do_you_have_a_licence?
    end

    should "be allowed if you have a licence" do
      add_response :yes
      assert_current_node :car_yes_have_licence
    end

    context "without a licence" do
      setup do
        add_response :no
      end

      should "ask how old you are" do
        assert_current_node :car_how_old_are_you?
      end

      should "not be able to drive if under 16" do
        add_response :age_16_under
        assert_current_node :car_no_under_16
      end

      should "be able to drive if 17 or over" do
        add_response :age_17_over
        assert_current_node :car_yes
      end

      context "if aged 16" do
        setup do
          add_response :age_16
        end

        should "ask if you're getting DLA" do
          assert_current_node :car_are_you_getting_dla?
        end

        should "be able to drive if getting DLA" do
          add_response :yes
          assert_current_node :car_yes_with_dla
        end

        should "not be able to drive otherwise" do
          add_response :no
          assert_current_node :car_no_under_16
        end
      end # aged 16
    end # without a licence
  end # Car

  context "Moped (Category P)" do
    setup do
      add_response :moped
    end

    should "ask if you have a car licence" do
      assert_current_node :moped_do_you_have_a_car_licence?
    end

    context "with a car licence" do
      setup do
        add_response :yes
      end

      should "ask if your licence was issues before Feb 2001" do
        assert_current_node :moped_when_was_licence_issued?
      end

      should "be allowed if issued before Feb 2001" do
        add_response :yes
        assert_current_node :moped_yes_licence_ok
      end

      should "require CBT if issues after Feb 2001" do
        add_response :no
        assert_current_node :moped_yes_with_cbt
      end
    end # With a car licence

    context "without a car licence" do
      setup do
        add_response :no
      end

      should "ask how old you are" do
        assert_current_node :moped_how_old_are_you?
      end

      should "not be allowed if under 16" do
        add_response :age_16_under
        assert_current_node :moped_no_under_16
      end

      should "be allowed if 16 or over" do
        add_response :age_16_over
        assert_current_node :moped_yes
      end
    end # without a car licence
  end # Moped

  context "Motorbike (category A)" do
    setup do
      add_response :motorbike
    end

    should "ask how old you are" do
      assert_current_node :motorbike_how_old_are_you?
    end

    should "not be allowrd when under 17" do
      add_response :age_17_under
      assert_current_node :motorbike_no_under_17
    end

    should "be allowed when 22 or over" do
      add_response :age_22_over
      assert_current_node :motorbike_yes_direct_access
    end

    context "when 17-20" do
      setup do
        add_response :age_17_to_20
      end

      should "ask if you already have a full motorcycle licence" do
        assert_current_node :motorbike_do_you_have_a_licence?
      end

      should "allow limited without a full licence" do
        add_response :no
        assert_current_node :motorbike_yes_within_limits
      end

      context "with a full licence" do
        setup do
          add_response :yes
        end

        should "ask if you've had your licence for more than 2 years" do
          assert_current_node :motorbike_have_you_had_licence_for_two_years?
        end

        should "Allow any bike if had licence for more than 2 years" do
          add_response :yes
          assert_current_node :motorbike_yes_with_upgrade
        end

        should "Allow limited bikes if had licence for less than 2 years" do
          add_response :no
          assert_current_node :motorbike_yes_but_no_upgrade_available_yet
        end
      end # full licence
    end #17-20

    context "when 21" do
      setup do
        add_response :age_21
      end

      should "ask if you have a full motorbike licence" do
        assert_current_node :motorbike_do_you_have_a_licence_21?
      end

      should "allow limited without a full licence" do
        add_response :no
        assert_current_node :motorbike_yes_direct_access
      end

      context "with a full licence" do
        setup do
          add_response :yes
        end

        should "ask if you've had licence for 2 years" do
          assert_current_node :motorbike_have_you_had_licence_for_two_years_21?
        end

        should "Allow any bike if had licence for more than 2 years" do
          add_response :yes
          assert_current_node :motorbike_yes_full_licence
        end

        should "Allow limited bikes if had licence for less than 2 years" do
          add_response :no
          assert_current_node :motorbike_yes_accelerated_access
        end
      end # full licence
    end # 21
  end # Motorbike

  context "Medium vehicle (category C1)" do
    setup do
      add_response :medium
    end

    should "ask if you have a full car licence" do
      assert_current_node :medium_do_you_have_a_car_licence?
    end

    should "not be allowed without a full car licence" do
      add_response :no
      assert_current_node :medium_no_need_car_licence
    end

    context "with a full car licence" do
      setup do
        add_response :yes
      end

      should "ask for your age" do
        assert_current_node :medium_how_old_are_you?
      end

      should "allow C1 and E if 21 or over" do
        add_response :age_21_over
        assert_current_node :medium_yes_c1_plus_e
      end

      should "allow C1 if 18-20" do
        add_response :age_18_to_20
        assert_current_node :medium_yes_c1
      end

      should "not be allowed if 17 unless in army" do
        add_response :age_17
        assert_current_node :medium_no_unless_armed_forces
      end

      should "not be allowed if under 17" do
        add_response :age_17_under
        assert_current_node :medium_no_under_17
      end
    end
  end # Medium vehicle

  context "Large vehicle (category C)" do
    setup do
      add_response :large
    end

    should "ask if you have a full car licence" do
      assert_current_node :large_do_you_have_a_car_licence?
    end

    should "not be allowed without a full car licence" do
      add_response :no
      assert_current_node :large_no_need_car_licence
    end

    context "with a full car licence" do
      setup do
        add_response :yes
      end

      should "ask for your age" do
        assert_current_node :large_how_old_are_you?
      end

      should "allow C1 and E if 21 or over" do
        add_response :age_21_over
        assert_current_node :large_yes
      end

      should "allow C1 if 18-20" do
        add_response :age_18_to_20
        assert_current_node :large_yes_with_special_circumstances
      end

      should "not be allowed if 17 unless in army" do
        add_response :age_17
        assert_current_node :large_no_unless_armed_forces
      end

      should "not be allowed if under 17" do
        add_response :age_17_under
        assert_current_node :large_no_under_17
      end
    end # with a car licence
  end # Large vehicle

  context "Bus (category D)" do
    setup do
      add_response :bus
    end

    should "ask if you have a full car licence" do
      assert_current_node :bus_do_you_have_a_car_licence?
    end

    should "not be allowed without a full car licence" do
      add_response :no
      assert_current_node :bus_no_need_car_licence
    end

    context "with a full car licence" do
      setup do
        add_response :yes
      end

      should "ask for your age" do
        assert_current_node :bus_how_old_are_you?
      end

      should "be allowed if 21 or over" do
        add_response :age_21_over
        assert_current_node :bus_yes
      end

      should "allow with special circumstances if 20" do
        add_response :age_20
        assert_current_node :bus_yes_special_20
      end

      should "allow with special circumstances if 18-19" do
        add_response :age_18_to_19
        assert_current_node :bus_yes_special_18_to_19
      end

      should "not be allowed if 17 unless in army" do
        add_response :age_17
        assert_current_node :bus_no_unless_armed_forces
      end

      should "not be allowed if under 17" do
        add_response :age_17_under
        assert_current_node :bus_no_under_17
      end
    end # with a car licence
  end # Bus

  context "Minibus (category D1)" do
    setup do
      add_response :minibus
    end

    should "ask if you have a full car licence" do
      assert_current_node :minibus_do_you_have_a_car_licence?
    end

    should "not be allowed without a full car licence" do
      add_response :no
      assert_current_node :minibus_no_need_car_licence
    end

    context "with a full car licence" do
      setup do
        add_response :yes
      end

      should "ask for your age" do
        assert_current_node :minibus_how_old_are_you?
      end

      should "be allowed if 21 or over" do
        add_response :age_21_over
        assert_current_node :minibus_yes
      end

      should "allow with special circumstances if 20" do
        add_response :age_20
        assert_current_node :minibus_yes_special_20
      end

      should "allow with special circumstances if 18-19" do
        add_response :age_18_to_19
        assert_current_node :minibus_yes_special_18_to_19
      end

      should "not be allowed if 17 unless in army" do
        add_response :age_17
        assert_current_node :minibus_no_unless_armed_forces
      end

      should "not be allowed if under 17" do
        add_response :age_17_under
        assert_current_node :minibus_no_under_17
      end
    end # with a car licence
  end # Minibus

  context "Agricultural tractor (category F)" do
    setup do
      add_response :tractor
    end

    should "ask if you have a full car licence" do
      assert_current_node :tractor_do_you_have_a_licence?
    end

    should "be allowed with a full car licence" do
      add_response :yes
      assert_current_node :tractor_yes_except
    end

    context "without a full car licence" do
      setup do
        add_response :no
      end

      should "ask for your age" do
        assert_current_node :tractor_how_old_are_you?
      end

      should "be allowed if 17 or over" do
        add_response :age_17_over
        assert_current_node :tractor_yes
      end

      should "allow small tractors if 16" do
        add_response :age_16
        assert_current_node :tractor_yes_16
      end

      should "not be allowed if under 16" do
        add_response :age_16_under
        assert_current_node :tractor_no_under_16
      end
    end # with a car licence
  end # Tractor

  context "Other (categories G, H and K)" do
    setup do
      add_response :other
    end

    should "ask for your age" do
      assert_current_node :other_how_old_are_you?
    end

    should "allow G, H and K if 21 or over" do
      add_response :age_21_over
      assert_current_node :other_yes
    end

    should "allow G, H and K (with restricitons in H and K) if 17-20 years old" do
      add_response :age_17_to_20
      assert_current_node :other_yes_k_with_g_h
    end

    should "allow K if 16" do
      add_response :age_16
      assert_current_node :other_yes_k
    end

    should "not be allowed if under 16" do
      add_response :age_16_under
      assert_current_node :other_no
    end
  end # Other

  context "Quad bike or Trike (category B1)" do
    setup do
      add_response :light
    end

    should "ask if you have a car licence" do
      assert_current_node :light_do_you_have_a_car_licence?
    end

    should "be allowed if you have a licence" do
      add_response :yes
      assert_current_node :light_yes
    end

    context "without a licence" do
      setup do
        add_response :no
      end

      should "ask how old you are" do
        assert_current_node :light_how_old_are_you?
      end

      should "not be able to drive if under 16" do
        add_response :age_16_under
        assert_current_node :light_no_under_16
      end

      should "be able to drive if 17 or over" do
        add_response :age_17_over
        assert_current_node :light_yes_17_over
      end

      context "if aged 16" do
        setup do
          add_response :age_16
        end

        should "ask if you're getting DLA" do
          assert_current_node :light_are_you_getting_dla?
        end

        should "be able to drive if getting DLA" do
          add_response :yes
          assert_current_node :light_yes_with_dla
        end

        should "not be able to drive otherwise" do
          add_response :no
          assert_current_node :light_no_under_16
        end
      end # aged 16
    end # without a licence
  end # Quad bike or Trike
end
