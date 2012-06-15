require_relative "../../test_helper"
require_relative "flow_test_helper"

class AmIGettingMinimumWageTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "am-i-getting-minimum-wage"
  end

  should "ask how you get paid" do
    assert_current_node :how_do_you_get_paid?
  end

  context "paid per hour" do
    setup do
      add_response :per_hour
    end

    should "ask how old you are" do
      assert_current_node :how_old_are_you?
    end

    context "age provided" do
      setup do
        add_response "21_or_over"
      end

      should "ask how many hours you work per week" do
        assert_current_node :how_many_hours_per_week_worked?
      end

      should "show minimum wage if hours per week are provided" do
        add_response "40"
        assert_current_node :per_hour_minimum_wage
        assert_state_variable :per_hour_minimum_wage, "6.08"
        assert_state_variable :hours_per_week, "40"
        assert_state_variable :per_week_minimum_wage, "243.20"
      end
    end
  end

  context "paid per piece" do
    setup do
      add_response :per_piece
    end

    should "ask how old you are" do
      assert_current_node :how_old_are_you?
    end

    context "age provided" do
      setup do
        add_response "21_or_over"
      end

      should "ask how many pieces you produce per week" do
        assert_current_node :how_many_pieces_do_you_produce_per_week?
      end

      context "number of pieces provided" do
        setup do
          add_response "10"
        end

        should "ask how much you get paid per piece" do
          assert_current_node :how_much_do_you_get_paid_per_piece?
        end

        context "pay per piece provided" do
          setup do
            add_response "30"
          end

          should "ask how many hours you work per week" do
            assert_current_node :how_many_hours_do_you_work_per_week?
          end

          should "show minimum wage if pay per piece is provided" do
            add_response "40"
            assert_current_node :per_piece_minimum_wage
            assert_state_variable :hourly_wage, "7.50"
            assert_state_variable :per_hour_minimum_wage, "6.08"
            assert_state_variable :above_below, "above"
          end
        end
      end
    end
  end
end