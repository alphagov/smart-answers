# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateAgriculturalHolidayEntitlementTest < ActionDispatch::IntegrationTest
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-agricultural-holiday-entitlement'
  end

  should "ask what your days worked per week is" do
    assert_current_node :work_the_same_number_of_days_each_week?
  end

  context "Same number of days each week" do
    setup do
      add_response 'same-number-of-days'
    end

    should "ask how many days per week you work" do
      assert_current_node :how_many_days_per_week?
    end

    context "6 or more days" do
      setup do
        add_response '6-or-more-days'
      end

      should "ask if you worked for the same employer all year" do
        assert_current_node :worked_for_same_employer?
      end

      context "only one employer" do
        setup do
          add_response "same-employer"
        end

        should "be finished" do
          assert_current_node :done
        end

        should "have 38 days holiday" do
          assert_state_variable :holiday_entitlement_days, 38
        end

      end

      context "several employers" do
        setup do
          add_response "multiple-employers"
        end

        should "be asked how many weeks I've worked there" do
          assert_current_node :how_many_weeks_at_current_employer?
        end

        context "worked 13 weeks" do
          setup do
            add_response "13"
          end

          should "be finished" do
            assert_current_node :done
          end

          should "show outcome of holidays" do
            # this should be exactly a quarter of the normal outcome
            # which is 38.
            assert_state_variable :holiday_entitlement_days, "9.5"
          end
        end
      end
    end

    context "5 to 6 days" do
      setup do
        add_response "5-to-6-days"
      end

      should "show outcome of holidays" do
        add_response "same-employer"
        assert_state_variable :holiday_entitlement_days, 35
      end
    end

    context "4 to 5 days" do
      setup do
        add_response "4-to-5-days"
      end

      should "show outcome of holidays" do
        add_response "same-employer"
        assert_state_variable :holiday_entitlement_days, 31
      end
    end

    context "3 to 4 days" do
      setup do
        add_response "3-to-4-days"
      end

      should "show outcome of holidays" do
        add_response "same-employer"
        assert_state_variable :holiday_entitlement_days, 25
      end
    end

    context "2 to 3 days" do
      setup do
        add_response "2-to-3-days"
      end

      should "show outcome of holidays" do
        add_response "same-employer"
        assert_state_variable :holiday_entitlement_days, 20
      end
    end

    context "1 to 2 days" do
      setup do
        add_response "1-to-2-days"
      end

      should "show outcome of holidays" do
        add_response "same-employer"
        assert_state_variable :holiday_entitlement_days, 13
      end
    end

    context "1 or less days" do
      setup do
        add_response "up-to-1-day"
      end

      should "show outcome of holidays" do
        add_response "same-employer"
        assert_state_variable :holiday_entitlement_days, 7.5
      end
    end
  end

  context "different number of days each week" do
    setup do
      add_response "different-number-of-days"
    end

    should "be asked when I'm taking holidays" do
      assert_current_node :what_date_does_holiday_start?
    end

    context "My holiday starts on august 1" do
      setup do
        # Fix today's date
        Date.stubs(:today).returns Date.civil(2012, 6, 17)
        add_response "2012-08-01"
      end

      should "be asked how many days I've worked" do
        assert_current_node :how_many_total_days?
      end

      should "have the number of weeks calculated" do
        assert_state_variable :weeks_from_october_1, 43
      end

      context "worked 50 days" do
        setup do
          add_response "50"
        end

        should "be asked if I worked for the same employer" do
          assert_current_node :worked_for_same_employer?
        end

        context "worked for the same employer" do
          setup do
            add_response "same-employer"
          end

          should "be finished" do
            assert_current_node :done
          end

          should "have some holidays" do
            assert_state_variable :holiday_entitlement_days, 13
          end
        end
      end
    end
  end
end
