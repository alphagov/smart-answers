require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/estimate-self-assessment-penalties"

TEST_CALCULATOR_DATES = {
  online_filing_deadline: {
    "2012-13": Date.new(2014, 1, 31),
    "2013-14": Date.new(2015, 1, 31),
    "2014-15": Date.new(2016, 1, 31),
  },
  offline_filing_deadline: {
    "2012-13": Date.new(2013, 10, 31),
    "2013-14": Date.new(2014, 10, 31),
    "2014-15": Date.new(2015, 10, 31),
  },
  payment_deadline: {
    "2012-13": Date.new(2014, 1, 31),
    "2013-14": Date.new(2015, 1, 31),
    "2014-15": Date.new(2016, 1, 31),
  },
}.freeze
class EstimateSelfAssessmentPenaltiesTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::EstimateSelfAssessmentPenaltiesFlow
  end

  should "ask which year you want to estimate" do
    assert_current_node :which_year?
  end

  context "2012-13 entered" do
    setup do
      add_response :"2012-13"
    end

    should "ask whether self assessment tax return was submitted online or on paper" do
      assert_current_node :how_submitted?
    end

    context "online" do
      setup do
        add_response :online
      end
      should "ask when self assessment tax return was submitted" do
        assert_current_node :when_submitted?
      end
      #testing error message 1
      context "test error if a date before range inserted" do
        setup do
          add_response "2013-01-01"
        end
        should "raise an error message" do
          assert_current_node_is_error
        end
      end

      context "a date before filing deadline" do
        setup do
          add_response "2013-10-10"
        end
        should "ask when bill was paid" do
          assert_current_node :when_paid?
        end
 #testing error message 2

        context "test error message for date input before filing date" do
          setup do
            add_response "2013-10-09"
          end
          should "show filed and paid on time outcome" do
            assert_current_node_is_error
          end
        end

 #testing paid on time
        context "paid on time" do
          setup do
            add_response "2013-10-11"
          end
          should "show filed and paid on time outcome" do
            assert_current_node :filed_and_paid_on_time
          end
        end #end testing paid on time

        context "paid late less than 3 months after" do
          setup do
            add_response "2014-03-03"
          end
          should "ask how much your tax bill is" do
            assert_current_node :how_much_tax?
          end

          context "bill entered" do
            setup do
              add_response "0.00"
            end
            should "show results" do
              assert_current_node :late
              assert_equal 0, current_state.calculator.late_filing_penalty
              assert_equal 0, current_state.calculator.total_owed_plus_filing_penalty
              assert_equal 0, current_state.calculator.interest
              assert_equal 0, current_state.calculator.late_payment_penalty
            end
          end
        end #end testing paid late but less than 3 months after
      end
    end
  end
  context "check for over 365 days delay" do
    setup do
      add_response :"2012-13"
      add_response :online
      add_response "2014-02-01"
      add_response "2014-02-01"
      add_response "1000.00"
    end

    should "show results" do
      assert_current_node :late
    end
  end

  #beginning of quick tests
  context "online return, tax year 2013-14" do
    setup do
      add_response :"2012-13"
      add_response :online
    end
    should "ask when bill was paid" do
      assert_current_node :when_submitted?
    end
    #band 1
    #100pounds fine (band 1)
    context "check 100 pounds fine (band 1)" do
      setup do
        add_response "2014-02-01"
        add_response "2014-02-01"
        add_response "0.00"
      end
      should "show results" do
        assert_equal 100, current_state.calculator.late_filing_penalty
        assert_equal 100, current_state.calculator.total_owed_plus_filing_penalty
      end
    end
    #band 2
    #100pounds fine + 10pounds per day (max 90 days, testing 1 day)(band 2)
    context "check 100pounds fine + 10pounds per day (max 90 days, testing 1 day) (band 2)" do
      setup do
        add_response "2014-05-01"
        add_response "2014-05-01"
        add_response "0.00"
      end
      should "show results" do
        assert_equal 110, current_state.calculator.late_filing_penalty
        assert_equal 110, current_state.calculator.total_owed_plus_filing_penalty
      end
    end
    # #band 2
    # #100pounds fine + 10pounds per day(max 90 days, testing 91 days)(band 2)
    context "check 100pounds fine + 10pounds per day (max 90 days, testing 92 days)(band 2)" do
      setup do
        add_response "2014-07-31"
        add_response "2014-07-31"
        add_response "0.00"
      end
      should "show results" do
        assert_equal 1000, current_state.calculator.late_filing_penalty
        assert_equal 1000, current_state.calculator.total_owed_plus_filing_penalty
      end
    end
    # #band 3 case 1
    # #300pounds fine + 1000pounds(previous fine)(band 3), taxdue <= 6002pounds
    context "300pounds fine + 1000pounds(previous fine)(band 3), taxdue < 6002pounds" do
      setup do
        add_response "2014-08-01"
        add_response "2014-08-01"
        add_response "0.00"
      end
      should "show results" do
        assert_equal 1300, current_state.calculator.late_filing_penalty
        assert_equal 1300, current_state.calculator.total_owed_plus_filing_penalty
      end
    end
    # #band 3 case 2
    # #5% fine + 1000pounds(previous fine)(band 3), taxdue > 6002pounds
    context "5% fine + 1000pounds(previous fine)(band 3), taxdue > 6002pounds" do
      setup do
        add_response "2014-08-01"
        add_response "2014-08-01"
        add_response "10000.00"
      end
      should "show results" do
        assert_equal 1500, current_state.calculator.late_filing_penalty
        assert_equal 10000, current_state.calculator.estimated_bill
        assert_equal 148.77, current_state.calculator.interest
        assert_equal 1000, current_state.calculator.late_payment_penalty
        assert_equal 12648, current_state.calculator.total_owed_plus_filing_penalty
      end
    end
    # #band 4 case 1
    #300pounds fine + 1300pounds(previous fine)(band 4), taxdue <= 6002pounds
    context "300pounds fine + 1300pounds(previous fine)(band 4), taxdue <= 6002pounds" do
      setup do
        add_response "2015-02-01"
        add_response "2015-02-01"
        add_response "0.00"
      end
      should "show results" do
        assert_equal 1600, current_state.calculator.late_filing_penalty
        assert_equal 1600, current_state.calculator.total_owed_plus_filing_penalty
      end
    end
    # #band 4 case 2
    # #10% fine + 1000pounds(previous fine)(band 4), taxdue > 6002pounds
    context "10% fine + 1000pounds(previous fine)(band 4), taxdue > 6002pounds" do
      setup do
        add_response "2015-02-01"
        add_response "2015-02-01"
        add_response "10000.00"
      end
      should "show results" do
        assert_equal 2000, current_state.calculator.late_filing_penalty
        assert_equal 10000, current_state.calculator.estimated_bill
        assert_equal 300, current_state.calculator.interest
        assert_equal 1500, current_state.calculator.late_payment_penalty
        assert_equal 13800, current_state.calculator.total_owed_plus_filing_penalty
      end
    end
  end
end
