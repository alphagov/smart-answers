# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class PIPCheckerTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'pip-checker'
  end

  should "ask if you're getting DLA" do
    assert_current_node :are_you_getting_dla?
  end

  context "not getting DLA" do
    setup do
      add_response 'no'
    end

    should "ask for your postcode" do
      assert_current_node :what_is_your_post_code?
    end

    should "error with an invalid postcode" do
      add_response 'ABCDEF'
      assert_current_node :what_is_your_post_code?
      assert_current_node_is_error
    end

    should "error with a partial postcode" do
      add_response 'WC1'
      assert_current_node :what_is_your_post_code?
      assert_current_node_is_error
    end

    context "with a postcode in the selected area" do
      setup do
        add_response 'CH4 0TH'
      end

      should "ask for your date of birth" do
        assert_current_node :what_is_your_dob?
      end

      should "be result 1 if born on or after 08-04-1997" do
        add_response '1997-04-08'
        assert_current_node :result_1
      end

      should "be result 2 if born on or before 08-04-1949" do
        add_response "1949-04-08"
        assert_current_node :result_2
      end

      should "be result 3 if born between 09-04-1949 and 07-04-1997" do
        add_response "1996-05-24"
        assert_current_node :result_3
      end
    end # postcode in selected area

    context "with a postcode outside the selected area" do
      setup do
        add_response 'CH5 0TH'
      end

      should "ask for your date of birth" do
        assert_current_node :what_is_your_dob?
      end

      should "be result 1 if born on or after 08-04-1997" do
        add_response '1997-04-08'
        assert_current_node :result_1
      end

      should "be result 2 if born on or before 08-04-1949" do
        add_response "1949-04-08"
        assert_current_node :result_2
      end

      should "be result 4 if born between 09-04-1949 and 07-04-1997" do
        add_response "1996-05-24"
        assert_current_node :result_4
      end
    end # postcode outside selected area
  end # not getting DLA

  context "getting DLA" do
    setup do
      add_response 'yes'
    end

    should "ask for your date of birth" do
      assert_current_node :what_is_your_dob?
    end

    should "be result 7 if born on or before 08-04-1949" do
      add_response "1949-04-08"
      assert_current_node :result_7
    end

    should "be result 5 if born between 08-04-1997 and 06-10-1997" do
      add_response '1997-04-08'
      assert_current_node :result_5
    end

    should "be result 6 if born on or after 07-10-1997" do
      add_response '1997-10-07'
      assert_current_node :result_6
    end

    should "be result 8 if born between 09-04-1949 and 07-04-1997" do
      add_response "1996-05-24"
      assert_current_node :result_8
    end
  end # getting DLA
end
