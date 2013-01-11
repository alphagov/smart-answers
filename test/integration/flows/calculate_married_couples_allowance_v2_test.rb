# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateMarriedCouplesAllowanceTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-married-couples-allowance-v2'
  end

  should "ask if you or partner were born before April 1935" do
    assert_current_node :were_you_or_your_partner_born_on_or_before_6_april_1935?
  end

  should "be sorry if neither born before 1935" do
    add_response :no
    assert_current_node :sorry
  end

  context "When eligible" do
    setup do
      add_response :yes
    end

    should "ask if married before 2005" do
      assert_current_node :did_you_marry_or_civil_partner_before_5_december_2005?
    end

    context "married before 2005" do
      setup do
        add_response :yes
      end

      should "ask for the husband's DOB" do
        assert_current_node :whats_the_husbands_date_of_birth?
      end

      should "ask for the husband's income" do
        add_response '1930-05-25'
        assert_current_node :whats_the_husbands_income?
      end

      should "end at husband_done" do
        add_response '1930-05-25'
        add_response '2000.0'
        assert_current_node :husband_done
      end

      should "calculate allowance using calculators" do
        SmartAnswer::AgeRelatedAllowanceChooser.any_instance.
          expects(:get_age_related_allowance).
          with(Date.parse '1930-05-25').
          returns("Age related allowance")
        SmartAnswer::MarriedCouplesAllowanceCalculator.any_instance.
          expects(:calculate_allowance).
          with("Age related allowance", 14500.0).
          returns("Calculated allowance")

        add_response '1930-05-25'
        add_response '14500.0'
        assert_state_variable :allowance, "Calculated allowance"
      end
    end # before 2005

    context "married after 2005" do
      setup do
        add_response :no
      end

      should "ask for the highest earner's DOB" do
        assert_current_node :whats_the_highest_earners_date_of_birth?
      end

      should "ask for the highest earner's income" do
        add_response '1930-05-14'
        assert_current_node :whats_the_highest_earners_income?
      end

      should "end at highest_earner_done" do
        add_response '1930-05-14'
        add_response '13850.50'
        assert_current_node :highest_earner_done
      end

      should "calculate allowance using calculators" do
        SmartAnswer::AgeRelatedAllowanceChooser.any_instance.
          expects(:get_age_related_allowance).
          with(Date.parse '1930-05-14').
          returns("Age related allowance")
        SmartAnswer::MarriedCouplesAllowanceCalculator.any_instance.
          expects(:calculate_allowance).
          with("Age related allowance", 13850.5).
          returns("Calculated allowance")

        add_response '1930-05-14'
        add_response '13850.50'
        assert_state_variable :allowance, "Calculated allowance"
      end
    end # after 2005
  end
end
