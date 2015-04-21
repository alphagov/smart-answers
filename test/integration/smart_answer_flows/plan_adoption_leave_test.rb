# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class PlanAdoptionLeaveTest < ActiveSupport::TestCase
  include FlowTestHelper

  context "test basic flow" do
    setup do
      setup_for_testing_flow 'plan-adoption-leave'
    end

    should "start on the baby_due_date? question" do
      assert_current_node :child_match_date?
    end

    context "set 3 months from child_match_date" do
      setup do
        @match_date = 3.months.ago
        add_response @match_date
      end

      should "error on child_arrival_date 3 months before child_match_date" do
        add_response 3.months.ago
        assert_current_node_is_error
      end

      should "error on child_arrival_date 4 months before child_match_date" do
        add_response 4.months.ago
        assert_current_node_is_error
      end

      should "be on child_arrival_date?" do
        assert_current_node :child_arrival_date?
      end

      context "set 3 months to arrival_date" do
        setup do
          @arrival_date = 3.months.since
          add_response @arrival_date
        end

       should "be on leave_start?" do
         assert_current_node :leave_start?
       end

        should "error on leave_start over 14 days before" do
          add_response 15.days.ago(@arrival_date)
          assert_current_node_is_error
        end

        context "set 2 weeks to leave_start?" do
          setup do
            add_response 14.days.ago(@arrival_date)
          end
          should "go to outcome" do
            assert_current_node :adoption_leave_details
          end
        end

      end
    end

  end
end
