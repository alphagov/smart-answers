require_relative "../../test_helper"
require_relative "flow_test_helper"

class HelpIfYouAreArrestedAbroad < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "hmrc-simplified-expenses-tracker"
  end

  should "ask new or existing business question" do
    assert_current_node :new_or_existing_business?
  end

  context "answering 'new' to Q1" do
    setup do
      add_response :new
    end

    should "store Q1 answer in variable" do
      assert_state_variable :new_or_existing_business, "new"
      assert_state_variable :is_new_business, true
      assert_state_variable :is_existing_business, false
    end

    context "selecting just car_van as expense type" do
      setup do
        add_response :car_or_van
      end

      should "calculate list of expenses array" do
        assert_state_variable :list_of_expenses, ["car_or_van"]
      end

      should "take user to Q4" do
        assert_current_node :is_vehicle_green?
      end

    end # car_van only on Q2

    context "selecting car_or_van and motorcycle as expense type" do
      setup do
        add_response "car_or_van,motorcycle"
      end

      should "take the user to Q4" do
        assert_current_node :is_vehicle_green?
      end
    end # car_van or motorcycle on Q2

    context "selecting just motorcycle as expense type" do
      setup do
        add_response "motorcycle"
      end

      should "take the user to Q4" do
        assert_current_node :is_vehicle_green?
      end
    end # just motorcycle on Q2

  end # answering 'new' on Q1

  context "answering 'existing' to Q1" do
    setup do
      add_response :existing
    end

    should "store Q1 answer in variable" do
      assert_state_variable :new_or_existing_business, "existing"
      assert_state_variable :is_existing_business, true
      assert_state_variable :is_new_business, false
    end

    context "selecting just car_van as expense type" do
      setup do
        add_response :car_or_van
      end

      should "calculate list of expenses array" do
        assert_state_variable :list_of_expenses, ["car_or_van"]
      end

      should "take user to Q3" do
        assert_current_node :how_much_write_off_tax?
      end

    end # car_van only on Q2

    context "selecting car_or_van and motorcycle as expense type" do
      setup do
        add_response "car_or_van,motorcycle"
      end

      should "take the user to Q3" do
        assert_current_node :how_much_write_off_tax?
      end
    end # car_van or motorcycle on Q2

    context "selecting just motorcycle as expense type" do
      setup do
        add_response "motorcycle"
      end

      should "take the user to Q3" do
        assert_current_node :how_much_write_off_tax?
      end
    end # just motorcycle on Q2

    context "selecting other options for Q2 should calculate list_of_expenses correctly" do
      context "selecting all options other than the last" do
        setup do
          add_response "car_or_van,motorcycle,using_home_for_business,live_on_business_premises"
        end
        should "store responses in an array" do
          assert_state_variable :list_of_expenses, ["car_or_van", "live_on_business_premises", "motorcycle", "using_home_for_business"]
        end
      end
    end

  end # answering 'existing' to Q1


end
