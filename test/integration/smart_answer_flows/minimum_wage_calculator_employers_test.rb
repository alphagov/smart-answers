require_relative "../../test_helper"
require_relative "flow_integration_test_helper"

class MinimumWageCalculatorEmployersTest < ActionDispatch::IntegrationTest
  # This tests the parts of the flow defined within MinimumWageCalculatorEmployersFlow
  # Much of the user journey is through a shared flow Shared::MinimumWageFlow
  # Which is tested via AmIGettingMinimumWageTest
  include FlowIntegrationTestHelper

  setup do
    setup_for_testing_flow MinimumWageCalculatorEmployersFlow
  end

  should "complete flow for current payment under school age" do
    assert_current_node :what_would_you_like_to_check?
    assert_page_renders
    add_response "current_payment"
    assert_current_node :are_you_an_apprentice? # in shared flow
    assert_page_renders
    add_response "not_an_apprentice" # Choice that will return flow from shared
    assert_current_node :how_old_are_you?
    assert_page_renders
    add_response "15"
    assert_current_node :under_school_leaving_age # outcome
    assert_page_renders
  end

  should "complete flow for current payment over school age" do
    assert_current_node :what_would_you_like_to_check?
    add_response "current_payment"
    assert_current_node :are_you_an_apprentice? # in shared flow
    assert_page_renders
    add_response "not_an_apprentice" # Choice that will return flow from shared
    assert_current_node :how_old_are_you?
    assert_page_renders
    add_response "22"
    assert_current_node :how_often_do_you_get_paid?
    assert_page_renders
    # current node and rest of flow in shared flow
  end

  should "complete flow for past payment under school age" do
    assert_current_node :what_would_you_like_to_check?
    add_response "past_payment"
    assert_current_node :were_you_an_apprentice?
    assert_page_renders
    # current node and rest of flow in shared flow
    # No options return from shared flow
  end
end
