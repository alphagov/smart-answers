# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class EnergyGrantsCalculatorTest < ActiveSupport::TestCase
  include FlowTestHelper
  
  setup do
    setup_for_testing_flow 'energy-grants-calculator'
  end

  context "Energy grants calculator" do
   
    should "ask what your circumstances are" do
      assert_current_node :what_are_your_circumstances?
    end
    
    context "answer on benefits" do
      setup do
        add_response :benefits
      end
      should "ask your D.O.B." do
        assert_current_node :dob?
      end

      context "answer pre 05-07-1951" do
        setup do
          add_response "1951-07-04"
        end
        should "calculate the age variant as winter_fuel_payment" do
          assert_state_variable "age_variant", :winter_fuel_payment
        end
        should "ask which benefits you receive" do
          assert_current_node :which_benefits?
        end
        context "answer pension credit" do
          should "give the benefits result (no disability)" do
            add_response 'pension_credit'
            assert_current_node :on_benefits_no_disability_or_children
            assert_phrase_list :eligibilities, [:winter_fuel_payments, :warm_home_discount, :cold_weather_payment, :energy_company_obligation]
          end
        end
        context "answer esa and income support with child under 20 in education" do
          should "give the benefits result" do
            add_response 'income_support,esa'
            add_response 'child_under_16'
            assert_current_node :on_benefits
            assert_phrase_list :eligibilities, [:winter_fuel_payments, :cold_weather_payment, :energy_company_obligation]
          end
        end
        context "answer esa" do
          should "give the benefits result (no disability)" do
            add_response 'esa'
            assert_current_node :on_benefits_no_disability_or_children
            assert_phrase_list :eligibilities, [:winter_fuel_payments, :cold_weather_payment, :energy_company_obligation]
          end
        end
      end # pre 05-07-1951
      
      context "answer over 60" do
        setup do
          add_response 60.years.ago(Date.today).strftime("%Y-%m-%d")
        end
        should "calculate the age variant as over_60" do
          assert_state_variable "age_variant", :over_60
        end
        should "ask which benefits you receive" do
          assert_current_node :which_benefits?
        end
        context "answer working tax credit with child under 16" do
          should "give benefits result with specific eligibilities" do
            add_response 'working_tax_credit'
            add_response 'child_under_16'
            assert_current_node :on_benefits
            assert_phrase_list :eligibilities, [:energy_company_obligation]
          end
        end
        context "answer working tax credit with no disabilities or children" do
          should "give benefits result with specific eligibilities" do
            add_response 'working_tax_credit'
            add_response 'none_of_these'
            assert_current_node :on_benefits_no_disability_or_children
            assert_phrase_list :eligibilities, [:energy_company_obligation]
          end
        end
      end # over 60

      context "answer under 60 and post 5th July 1951" do
        setup do
          add_response "1980-01-01"
        end
        should "ask which benefits you receive" do
          assert_current_node :which_benefits?
        end
        
        context "answer pension credit" do
          should "give the result with specific eligibilities" do
            add_response 'pension_credit'
            assert_current_node :on_benefits_no_disability_or_children
            assert_state_variable :benefits, ['pension_credit']
            assert_phrase_list :eligibilities, [:warm_home_discount, :cold_weather_payment, :energy_company_obligation]
          end
        end # pension credits

        context "answer income support" do
          setup do
            add_response 'income_support'
          end
          should "ask if you are disabled or have children" do
            assert_current_node :disabled_or_have_children?
          end
          context "answer disabled" do
            should "give benefits result with specific eligibilities" do
              add_response 'disabled'
              assert_current_node :on_benefits
              assert_phrase_list :eligibilities, [:warm_home_discount, :cold_weather_payment, :energy_company_obligation]
            end
          end
        end # income support
        
        context "answer jsa" do
          setup do
            add_response 'jsa'
          end
          should "ask if you are disabled or have children" do
            assert_current_node :disabled_or_have_children?
          end
          context "answer child under 16" do
            should "give benefits result with specific eligibilities" do
              add_response :child_under_16
              assert_current_node :on_benefits
              assert_phrase_list :eligibilities, [:energy_company_obligation]
            end
          end
        end # jsa
        
        context "answer esa" do
          should "give the result with specific eligibilities" do
            add_response 'esa'
            assert_current_node :on_benefits_no_disability_or_children
            assert_state_variable :benefits, ['esa']
            assert_phrase_list :eligibilities, [:cold_weather_payment, :energy_company_obligation]
          end
        end # esa
        
        context "child tax credit" do
          should "give the result with specific eligibilities" do
            add_response 'child_tax_credit'
            assert_current_node :on_benefits_no_disability_or_children
            assert_state_variable :benefits, ['child_tax_credit']
          end
        end # child tax credit
        
        context "answer income support and child tax credit and a disabled child" do
          should "give the benefits result with specific eligibilities" do
            add_response 'income_support,child_tax_credit'
            add_response 'disabled_child'
            assert_current_node :on_benefits
            assert_phrase_list :eligibilities, [:warm_home_discount, :cold_weather_payment, :energy_company_obligation]
          end
        end # income support, child tax credit

        context "working tax credit" do
          setup do
            add_response 'working_tax_credit'
          end
          should "ask if you are disabled or have children" do
            assert_current_node :disabled_or_have_children?
          end

          context "answer child under 5" do
            should "give the result with specific eligibilities" do
              add_response 'child_under_5'
              assert_current_node :on_benefits
              assert_state_variable :benefits, ['working_tax_credit']
              assert_phrase_list :eligibilities, [:warm_home_discount, :cold_weather_payment, :energy_company_obligation]
            end
          end # child under 5

          context "answer child under 16" do
            should "give the result with specific eligibilities" do
              add_response 'child_under_16'
              assert_current_node :on_benefits
              assert_phrase_list :eligibilities, [:energy_company_obligation]
            end
          end # child under 16
        end # working tax credit

        context "none of these" do
          should "give the no benefits result" do
            add_response 'none_of_these'
            assert_current_node :no_benefits
            assert_phrase_list :eligibilities, [:green_deal]
          end
        end # none of the benefits listed
      end # under 60 after 5th July 1951

    end # on benefits

    context "answer you own your own property" do 
      setup do
        add_response :property
      end
      
      should "ask your D.O.B." do
        assert_current_node :dob?
      end
      
      context "answer pre 05-07-1951" do
        setup do
          add_response "1951-07-04"
        end
        should "calculate the age variant as winter_fuel_payment" do
          assert_state_variable "age_variant", :winter_fuel_payment
        end
        should "give the no benefits result" do
          assert_current_node :no_benefits
        end
        should "calculate eligibilities" do
          assert_phrase_list :eligibilities, [:winter_fuel_payments, :green_deal, :renewable_heat_premium]
        end
      end # D.O.B. pre 05-07-1951

      context "answer post 05-07-1951" do
        should "calculate eligibilities" do
          add_response "1971-09-07"
          assert_current_node :no_benefits
          assert_phrase_list :eligibilities, [:green_deal, :renewable_heat_premium]
        end
      end # D.O.B. post 05-07-1951

    end # property owner

    context "answer renting with permission" do
      setup do
        add_response :permission
      end
      should "ask your D.O.B." do
        assert_current_node :dob?
      end

      context "answer pre 05-07-1951" do
        setup do
          add_response "1951-07-04"
        end
        should "calculate the age variant as winter_fuel_payment" do
          assert_state_variable "age_variant", :winter_fuel_payment
        end
        should "give the no benefits result" do
          assert_current_node :no_benefits
        end
        should "calculate eligibilities" do
          assert_phrase_list :eligibilities, [:winter_fuel_payments, :green_deal, :renewable_heat_premium]
        end
      end # D.O.B. pre 05-07-1951

      context "answer post 05-07-1951" do
        should "calculate eligibilities" do
          add_response "1971-09-07"
          assert_current_node :no_benefits
          assert_phrase_list :eligibilities, [:green_deal, :renewable_heat_premium]
        end
      end # D.O.B. post 05-07-1951

    end # renting with permission
    
    context "answer you generate your own energy" do
      setup do
        add_response :own_energy
      end
      should "ask your D.O.B." do
        assert_current_node :dob?
      end
      context "answer pre 05-07-1951" do
        setup do
          add_response "1951-07-04"
        end
        should "calculate the age variant as winter_fuel_payment" do
          assert_state_variable "age_variant", :winter_fuel_payment
        end
        should "give the no benefits result" do
          assert_current_node :no_benefits
        end
        should "calculate eligibilities" do
          assert_phrase_list :eligibilities, [:winter_fuel_payments, :green_deal, :feed_in_tariffs]
        end
      end # D.O.B. pre 05-07-1951

      context "answer post 05-07-1951" do
        should "calculate eligibilities" do
          add_response "1971-09-07"
          assert_current_node :no_benefits
          assert_phrase_list :eligibilities, [:green_deal, :feed_in_tariffs]
        end
      end # D.O.B. post 05-07-1951
    end # generate own energy

    context "answer homeowner, D.O.B. pre 05-07-1951, generate own energy" do
      should "calculate eligibilities" do
        add_response "property,own_energy"
        add_response "1951-07-02"
        assert_current_node :no_benefits
        assert_phrase_list :eligibilities, [:winter_fuel_payments, :green_deal, :renewable_heat_premium, :feed_in_tariffs]
      end
    end # homeowner, born 05-07-1951, generate own energy

    context "answer homeowner, generate own energy" do
      should "calculate eligibilities" do
        add_response "property,own_energy"
        add_response "1960-01-02"
        assert_current_node :no_benefits
        assert_phrase_list :eligibilities, [:green_deal, :renewable_heat_premium, :feed_in_tariffs]
      end
    end # homeowner, generate own energy

    context "answer renting, generate own energy" do
      should "calculate eligibilities" do
        add_response "permission,own_energy"
        add_response "1960-01-05"
        assert_current_node :no_benefits
        assert_phrase_list :eligibilities, [:green_deal, :renewable_heat_premium, :feed_in_tariffs]
      end
    end # renting, generate own energy

  end
end
