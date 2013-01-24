# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class PIPDateCheckerTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'pip-date-checker'
  end

  should "ask for post code" do
    assert_current_node :what_is_your_post_code?
  end

  context "with a postcode in the selected area" do
    setup do
      add_response 'CH4'
    end

    should "ask if you're getting DLA" do
      assert_current_node :are_you_getting_dla?
    end

    should "be result 1 if not getting DLA" do
      add_response 'no'
      assert_current_node :result_1
    end

    context "getting DLA" do
      setup do
        add_response 'yes'
      end

      should "ask when DLA ends" do
        assert_current_node :when_does_your_dla_end?
      end

      context "DLA ends on or before 7 Oct 2013" do
        setup do
          add_response '2013-10-07'
        end

        should "ask for date of birth" do
          assert_current_node :what_is_your_dob?
        end

        should "be result 3 if born on or before 8/4/1949" do
          add_response '1949-04-08'
          assert_current_node :result_3
        end

        should "be result 5 if born between 9/4/1949 and 7/4/1998" do
          add_response '1950-05-24'
          assert_current_node :result_5
        end

        should "be result 6 if born on or after 7/4/1998" do
          add_response '1998-04-07'
          assert_current_node :result_6
        end
      end # DLA ends before Oct 2013

      context "DLA ends after 7 Oct 2013" do
        setup do
          add_response '2013-10-08'
        end

        should "ask for date of birth" do
          assert_current_node :what_is_your_dob?
        end

        should "be result 3 if born on or before 8/4/1949" do
          add_response '1949-04-08'
          assert_current_node :result_3
        end

        should "be result 4 if born between 9/4/1949 and 7/4/1998" do
          add_response '1950-05-24'
          assert_current_node :result_4
        end

        should "be result 6 if born on or after 7/4/1998" do
          add_response '1998-04-07'
          assert_current_node :result_6
        end
      end # DLA does not end before Oct 2013
    end # getting DLA
  end # postcode in area

  context "with a postcode outside the selected area" do
    setup do
      add_response 'CH5'
    end

    should "ask if you're getting DLA" do
      assert_current_node :are_you_getting_dla?
    end

    should "be result 2 if not getting DLA" do
      add_response 'no'
      assert_current_node :result_2
    end

    context "getting DLA" do
      setup do
        add_response 'yes'
      end

      should "ask when DLA ends" do
        assert_current_node :when_does_your_dla_end?
      end

      context "DLA ends on or before 7 Oct 2013" do
        setup do
          add_response '2013-10-07'
        end

        should "ask for date of birth" do
          assert_current_node :what_is_your_dob?
        end

        should "be result 3 if born on or before 8/4/1949" do
          add_response '1949-04-08'
          assert_current_node :result_3
        end

        should "be result 5 if born between 9/4/1949 and 7/4/1998" do
          add_response '1950-05-24'
          assert_current_node :result_5
        end

        should "be result 6 if born on or after 7/4/1998" do
          add_response '1998-04-07'
          assert_current_node :result_6
        end
      end # DLA ends before Oct 2013

      context "DLA ends after 7 Oct 2013" do
        setup do
          add_response '2013-10-08'
        end

        should "ask for date of birth" do
          assert_current_node :what_is_your_dob?
        end

        should "be result 3 if born on or before 8/4/1949" do
          add_response '1949-04-08'
          assert_current_node :result_3
        end

        should "be result 4 if born between 9/4/1949 and 7/4/1998" do
          add_response '1950-05-24'
          assert_current_node :result_4
        end

        should "be result 6 if born on or after 7/4/1998" do
          add_response '1998-04-07'
          assert_current_node :result_6
        end
      end # DLA does not end before Oct 2013
    end # getting DLA
  end # postcode outside area
end
