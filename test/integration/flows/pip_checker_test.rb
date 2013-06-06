# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class PIPCheckerV2Test < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'pip-checker-v2'
  end

  should "ask if you're getting DLA" do
    assert_current_node :are_you_getting_dla?
  end

  context "not getting DLA" do
    setup do
      add_response 'no'
    end

    should "ask for your date of birth" do
      assert_current_node :what_is_your_dob?
    end

    should "be result 1 if born on or after 08-04-1997" do
      add_response '1997-04-08'
      assert_current_node :result_1
    end

    should "be result 2 if born on or before 08-04-1948" do
      add_response "1948-04-08"
      assert_current_node :result_2
    end

    should "be result 3 if born between 09-04-1948 and 07-04-1997" do
      add_response "1996-05-24"
      assert_current_node :result_3
    end
  end # not getting DLA

  context "getting DLA" do
    setup do
      add_response 'yes'
    end

    should "ask for your date of birth" do
      assert_current_node :what_is_your_dob?
    end

    should "be result 6 if born on or before 08-04-1948" do
      add_response "1948-04-08"
      assert_current_node :result_6
    end

    should "be result 4 if born between 08-04-1997 and 06-10-1997" do
      add_response '1997-04-08'
      assert_current_node :result_4
    end

    should "be result 5 if born on or after 07-10-1997" do
      add_response '1997-10-07'
      assert_current_node :result_5
    end

    should "be result 7 if born between 09-04-1948 and 07-04-1997" do
      add_response "1996-05-24"
      assert_current_node :result_7
    end
  end # getting DLA

end
