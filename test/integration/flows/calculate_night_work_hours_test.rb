# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateNightWorkHoursTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-night-work-hours'
  end

  should "ask your age" do
    assert_current_node :how_old?
  end

  should "not be old enough if under 18" do
    add_response 'under-18'
    assert_current_node :not_old_enough
  end

  context "when 18 or over" do
    setup do
      add_response '18-or-over'
    end

    should "ask if you have worked more than 13 hours in any night" do
      assert_current_node :have_you_worked_more_than_13_hours_in_a_night?
    end

    should "have exceeded working time limit if you have worked more than 13 hours in a night" do
      add_response :yes
      assert_current_node :exceeded_working_time_limit
    end

    context "not worked more than 13 hours in a night" do
      setup do
        add_response :no
      end

      should "ask if you've worked more yhan 6 nights in a row" do
        assert_current_node :have_you_worked_more_than_6_nights_in_a_row?
      end

      should "have exceeded working time limit if you have worked more than 6 nights in a row" do
        add_response :yes
        assert_current_node :exceeded_working_time_limit
      end

      context "not worked more than 6 nights in a row" do
        setup do
          add_response :no
        end

        should "ask how many weeks you've worked nights" do
          assert_current_node :how_many_weeks_have_you_worked_nights?
        end

        context "worked 4 weeks of nights" do
          setup do
            add_response '4'
          end

          should "ask how many weeks leave you've taken" do
            assert_current_node :how_many_weeks_leave_have_you_taken?
          end

          should "be invalid if you enter more weeks leave than you've worked" do
            add_response '4'
            assert_current_node_is_error
            assert_current_node :how_many_weeks_leave_have_you_taken?
          end

          should "ask what your work cycle is" do
            add_response '1'
            assert_current_node :what_is_your_work_cycle?
          end

          context "with an 8 day work cycle" do
            setup do
              add_response '1'
              add_response '8'
            end

            should "ask how many nights you work in your cycle" do
              assert_current_node :how_many_nights_do_you_work_in_your_cycle?
            end

            should "be invalid if work more nights than in your cycle" do
              add_response '8'
              assert_current_node_is_error
              assert_current_node :how_many_nights_do_you_work_in_your_cycle?
            end

            should "ask how many hours you work per shift" do
              add_response '4'
              assert_current_node :how_many_hours_do_you_work_per_shift?
            end

            should "ask how many overtime hours you've worked" do
              add_response '4'
              add_response '8'
              assert_current_node :how_many_overtime_hours_have_you_worked?
            end

            should "calculate results and be done" do
              calc = mock()
              SmartAnswer::Calculators::NightWorkHours.
                expects(:new).
                with(:weeks_worked => 4, :weeks_leave => 1,
                     :work_cycle => 8, :nights_in_cycle => 5,
                     :hours_per_shift => 9, :overtime_hours => 6).
                returns(calc)
              calc.expects(:total_hours).returns("stub total hours")
              calc.expects(:average_hours).returns("stub average hours")
              calc.expects(:potential_days).returns("stub potential days")

              add_response '5'
              add_response '9'
              add_response '6'
              assert_current_node :done

              assert_state_variable :total_hours, "stub total hours"
              assert_state_variable :average_hours, "stub average hours"
              assert_state_variable :potential_days, "stub potential days"
            end
          end # with an 8 week cycle
        end # worked 4 weeks of nights
      end # not worked more than 6 nights in a row
    end # not 13 hours in a night
  end # 18 or over
end
