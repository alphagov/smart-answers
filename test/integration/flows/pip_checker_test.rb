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
      assert_current_node :what_is_your_post_code?, :error => true
    end

    should "error with a partial postcode" do
      add_response 'WC1'
      assert_current_node :what_is_your_post_code?, :error => true
    end

    context "with a postcode in the selected area" do
      setup do
        add_response 'CH3 0TH'
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

      should "be result 2 if born on or before 08-04-1948" do
        add_response "1948-04-08"
        assert_current_node :result_2
      end

      should "be result 4 if born between 09-04-1948 and 07-04-1997" do
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

    should "be result 7 if born on or before 08-04-1948" do
      add_response "1948-04-08"
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

    should "be result 8 if born between 09-04-1948 and 07-04-1997" do
      add_response "1996-05-24"
      assert_current_node :result_8
    end
  end # getting DLA

#timecop test
  context "testing outcome 3 with pre-8th april date" do
    setup do
      Timecop.travel('2012-10-08')
      add_response 'no'
      add_response 'BL1 3EE'
    end
    should "be result 3 if born between 09-04-1948 and 07-04-1997" do
      add_response "1996-05-24"
      assert_current_node :result_3
      assert_phrase_list :april_eight_change, [:before_april_eight_thirteen_text]
    end
  end
  context "testing outcome 3 with post-8th april date" do
    setup do
      Timecop.travel('2013-10-08')
      add_response 'no'
      add_response 'BL1 3EE'
    end
    should "be result 3 if born between 09-04-1948 and 07-04-1997" do
      add_response "1996-05-24"
      assert_current_node :result_3
      assert_phrase_list :april_eight_change, [:after_april_eight_thirteen_text]
    end
  end


end
