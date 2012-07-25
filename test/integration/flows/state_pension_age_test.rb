require_relative '../../test_helper'
require_relative 'flow_test_helper'

class StatePensionAgeTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'state-pension-age'
  end

  should "ask your gender" do
    assert_current_node :gender?
  end

  context "male" do
    setup do
      add_response :male
    end

    should "ask for date of birth" do
      assert_current_node :dob?
    end

    context "born on 6th April 1945" do
      setup do
        add_response Date.parse("6th April 1945")
      end

      should "ask for qualifying years" do
        assert_current_node :answer
      end
    end
  end
end