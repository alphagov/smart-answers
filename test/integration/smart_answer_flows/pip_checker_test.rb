require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/pip-checker"

class PIPCheckerTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::PipCheckerFlow
  end

  should "ask if you're getting DLA" do
    assert_current_node :are_you_getting_dla?
  end

  context "not getting DLA" do
    setup do
      add_response 'no'
      Timecop.travel('2013-06-07')
    end

    should "ask for your date of birth" do
      assert_current_node :what_is_your_dob?
    end

    context "dates out of range" do
      should "not allow dates far in the past" do
        add_response Date.parse("1850-12-31")
        assert_current_node_is_error
      end

      should "not allow dates next year" do
        add_response(Date.today.end_of_year + 1.day).to_s
        assert_current_node_is_error
      end
    end

    should "be under 16, if born on or after 08-06-2000" do
      add_response '2000-06-08'
      assert_current_node :under_16
    end

    should "be over 65, if born on or before 08-04-1948" do
      add_response "1948-04-08"
      assert_current_node :over_65
    end

    should "not claim for dla, if born between 09-04-1948 and 07-04-1997" do
      add_response "1996-05-24"
      assert_current_node :no_claim_for_dla
    end
  end # not getting DLA

  context "getting DLA" do
    setup do
      add_response 'yes'
      Timecop.travel('2013-02-03')
    end

    should "ask for your date of birth (03/03/13)" do
      assert_current_node :what_is_your_dob?
    end

    should "be over 65 by 2013, if born on or before 08-04-1948 (03/03/13)" do
      add_response "1948-04-08"
      assert_current_node :over_65_in_2013
    end

    should "qualify for pip, if born between 08-06-1997 and 06-10-1997 (03/03/13)" do
      add_response '1997-06-08'
      assert_current_node :qualifies_for_pip
    end

    should "qualify for pip at 16, if born on or after 07-10-1997 (03/03/13)" do
      add_response '1997-10-07'
      assert_current_node :qualifies_for_pip_at_16
    end

    should "qualify for pip, if born between 09-04-1948 and 07-04-1997 (03/03/13)" do
      add_response "1996-05-24"
      assert_current_node :qualifies_for_pip
    end
  end # getting DLA
end
