# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class ExchangeAForeignLicenceTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'exchange-a-foreign-driving-licence'
  end

  should "are you resident in gb" do
    assert_current_node :are_you_resident_in_gb?
  end

  context "A resident of GB" do
    setup do
      add_response 'yes'
    end

    should "ask what kind of licence you have" do
      assert_current_node :what_vehicle_licence_do_you_have?
    end

    context "Car / Bike" do
      setup do
        add_response :car_motorcycle
      end

      should "ask where your licence was issued" do
        assert_current_node :which_country_issued_car_licence?
      end

      should "show response for eea ec" do
        add_response 'eea_ec'
        assert_current_node :a7
      end

      should "show response for ni" do
        add_response 'ni'
        assert_current_node :a8
      end

      should "show response for jersey guernsey" do
        add_response 'jg'
        assert_current_node :a9
      end

      should "show response for other" do
        add_response 'other'
        assert_current_node :a11
      end

      context "designated countries" do
        setup do
          add_response 'des'
        end
        
        should "ask which designated country" do
          assert_current_node :which_designated_country_are_you_from?
        end

        should "show response for aus" do
          add_response 'aus'
          assert_current_node :a10
        end

        should "show response for bar" do
          add_response 'bar'
          assert_current_node :a10
        end

        should "show response for bvi" do
          add_response 'bvi'
          assert_current_node :a10
        end        

        should "show response for can" do
          add_response 'can'
          assert_current_node :a10a
        end

        should "show response for falk" do
          add_response 'falk'
          assert_current_node :a10
        end        

        should "show response for far" do
          add_response 'far'
          assert_current_node :a10b
        end

        should "show response for gib" do
          add_response 'gib'
          assert_current_node :a10
        end

        should "show response for hk" do
          add_response 'hk'
          assert_current_node :a10
        end

        should "show response for jap" do
          add_response 'jap'
          assert_current_node :a10c
        end

        should "show response for mon" do
          add_response 'mon'
          assert_current_node :a10
        end

        should "show response for nz" do
          add_response 'nz'
          assert_current_node :a10
        end

        should "show response for rok" do
          add_response 'rok'
          assert_current_node :a10d
        end

        should "show response for sing" do
          add_response 'sing'
          assert_current_node :a10
        end

        should "show response for sa" do
          add_response 'sa'
          assert_current_node :a10e
        end

        should "show response for sw" do
          add_response 'sw'
          assert_current_node :a10
        end

        should "show response for zim" do
          add_response 'zim'
          assert_current_node :a10
        end
      end # designated countries
    end # Car / Bike

    context "Lorry, Bus or Minibus" do
      setup do
        add_response :lorry_bus_minibus
      end

      should "ask where your licence was issued" do
        assert_current_node :which_country_issued_bus_licence?
      end

      should "show result for Northern Ireland" do
        add_response :ni
        assert_current_node :a3
      end

      should "show result for Jersey/Guernsey" do
        add_response :jg
        assert_current_node :a4
      end

      should "show answer for Gibraltar" do
        add_response :gib
        assert_current_node :a5
      end

      should "show answer for other" do
        add_response :other
        assert_current_node :a6
      end

      context "age for eu eec lorry bus minibus" do
        setup do
          add_response :eea_ec
        end

        should "ask how old" do
          assert_current_node :how_old
        end

        should "show answer for under 45" do
          add_response :under_45
          assert_current_node :a2a
        end

        should "show answer for between 45 and 65" do
          add_response :between_45_and_65
          assert_current_node :a2b
        end

        should "show answer for older than 66" do
          add_response :older_than_66
          assert_current_node :a2c
        end

      end # age for eu lorry bus minibus
    end # Lorry / Bus / Minibus
  end # GB Resident
end
