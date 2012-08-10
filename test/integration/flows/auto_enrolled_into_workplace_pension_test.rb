# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class AutoEnrolledIntoWorkplacePensionTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'auto-enrolled-into-workplace-pension'
  end

  should "ask if you work in the UK" do
    assert_current_node :work_in_uk?
  end

  context "does not work in the UK" do
    should "not be enrolled in pension" do
      add_response :no
      assert_current_node :not_enrolled
    end
  end

  context "works in the UK" do
    setup do
      add_response :yes
    end

    should "ask if self employed" do
      assert_current_node :self_employed?
    end

    context "self employed" do
      should "not be enrolled in pension" do
        add_response :yes
        assert_current_node :not_enrolled
      end
    end

    context "not self employed" do
      setup do
        add_response :no
      end

      should "ask if you are already in workplace pension" do
        assert_current_node :workplace_pension?
      end

      context "already in workplace pension" do
        should "say you will continue to pay" do
          add_response :yes
          assert_current_node :continue_to_pay
        end
      end

      context "not already in workplace pension" do
        setup do
          add_response :no
        end

        should "ask how old you will be" do
          assert_current_node :how_old?
        end
      end
    end
  end
end