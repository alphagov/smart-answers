# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class DrivingInGreatBritainOnNonGBLicenceTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'driving-in-great-britain-on-non-gb-licence'
  end

  should "ask what your status is in the UK" do
    assert_current_node :are_you?
  end

  context "A resident of GB" do
    setup do
      add_response 'resident_of_gb'
    end

    should "ask what kind of licence you have" do
      assert_current_node :what_vehicle_licence_do_you_have?
    end

    context "Car / Bike" do
      setup do
        add_response 'car_motorcycle'
      end

      should "ask where your licence was issued" do
        assert_current_node :which_country_issued_car_licence?
      end

      should "be allowed for a Northern Ireland Licence" do
        add_response 'ni'
        assert_current_node :a1
      end

      should "Allow driving with an EU licence with limitations" do
        add_response 'eea_ec'
        assert_current_node :a2
      end

      should "Allow driving with a designated country license with limitations" do
        add_response 'gib_j_g_iom_desig'
        assert_current_node :a3
      end

      should "be a4 for other issuers" do
        add_response 'other'
        assert_current_node :a4
      end
    end # Car / Bike

    context "Lorry, Bus or Minibus" do
      setup do
        add_response :lorry_bus_minibus
      end

      should "ask where your licence was issued" do
        assert_current_node :which_country_issued_bus_licence?
      end

      should "be a5 with a  Northern Ireland licence" do
        add_response :ni
        assert_current_node :a5
      end

      should "be a6 with an EU/EEA licence" do
        add_response :eea_ec
        assert_current_node :a6
      end

      should "be a6 with licence from Gibraltar, Channel Islands etc." do
        add_response :gib_j_g_iom
        assert_current_node :a7
      end

      should "be a7 with a licence from a designated country" do
        add_response :designated
        assert_current_node :a8
      end

      should "be a8 with a licence from anywhere else" do
        add_response :other
        assert_current_node :a9
      end
    end # Lorry / Bus / Minibus
  end # GB Resident

  context "for a visitor to GB" do
    setup do
      add_response :visitor_to_gb
    end

    should "ask where licence was issued" do
      assert_current_node :where_was_licence_issued?
    end

    should "be a10 for NI or EU licence" do
      add_response :ni_eea_ec
      assert_current_node :a10
    end

    should "be a11 for Jersey, Gurnsey or Isle of Man" do
      add_response :j_g_iom
      assert_current_node :a11
    end

    should "be a12 for anywhere else" do
      add_response :other
      assert_current_node :a12
    end
  end # Visitor to GB

  context "for a student in GB" do
    setup do
      add_response :student_in_gb
    end

    should "ask where you are from" do
      assert_current_node :where_are_you_from?
    end

    should "be a13 when from EU" do
      add_response :eea_ec
      assert_current_node :a13
    end

    should "be a14 otherwise" do
      add_response :non_eea_ec
      assert_current_node :a14
    end
  end # Student in GB
end
