require_relative "../../test_helper"
require_relative "flow_integration_test_helper"

TEST_CALCULATOR_DATES = {
  online_filing_deadline: {
    "2013-14": Date.new(2015, 1, 31),
    "2014-15": Date.new(2016, 1, 31),
  },
  offline_filing_deadline: {
    "2013-14": Date.new(2014, 10, 31),
    "2014-15": Date.new(2015, 10, 31),
  },
  payment_deadline: {
    "2013-14": Date.new(2015, 1, 31),
    "2014-15": Date.new(2016, 1, 31),
  },
}.freeze
class EstimateSelfAssessmentPenaltiesTest < ActiveSupport::TestCase
  include FlowIntegrationTestHelper

  setup do
    setup_for_testing_flow EstimateSelfAssessmentPenaltiesFlow
  end

  should "ask which year you want to estimate" do
    assert_current_node :which_year?
  end

  context "2013-14 entered" do
    setup do
      add_response :"2013-14"
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
      # testing error message 1
      context "test error if a date before range inserted" do
        setup do
          add_response "2014-01-01"
        end
        should "raise an error message" do
          assert_current_node_is_error
        end
      end

      context "a date before filing deadline" do
        setup do
          add_response "2014-10-10"
        end
        should "ask when bill was paid" do
          assert_current_node :when_paid?
        end
        # testing error message 2

        context "test error message for date input before filing date" do
          setup do
            add_response "2014-10-09"
          end
          should "show filed and paid on time outcome" do
            assert_current_node_is_error
          end
        end

        # testing paid on time
        context "paid on time" do
          setup do
            add_response "2014-10-11"
          end
          should "show filed and paid on time outcome" do
            assert_current_node :filed_and_paid_on_time
          end
        end # end testing paid on time

        context "paid late less than 3 months after" do
          setup do
            add_response "2015-03-03"
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
        end # end testing paid late but less than 3 months after
      end
    end
  end
  context "check for over 365 days delay" do
    setup do
      add_response :"2013-14"
      add_response :online
      add_response "2015-02-01"
      add_response "2015-02-01"
      add_response "1000.00"
    end

    should "show results" do
      assert_current_node :late
    end
  end

  # beginning of quick tests
  context "online return, tax year 2014-15" do
    setup do
      add_response :"2013-14"
      add_response :online
    end
    should "ask when bill was paid" do
      assert_current_node :when_submitted?
    end
    # band 1
    # 100pounds fine (band 1)
    context "check 100 pounds fine (band 1)" do
      setup do
        add_response "2015-02-01"
        add_response "2015-02-01"
        add_response "0.00"
      end
      should "show results" do
        assert_equal 100, current_state.calculator.late_filing_penalty
        assert_equal 100, current_state.calculator.total_owed_plus_filing_penalty
      end
    end
    # band 2
    # 100pounds fine + 10pounds per day (max 90 days, testing 1 day)(band 2)
    context "check 100pounds fine + 10pounds per day (max 90 days, testing 1 day) (band 2)" do
      setup do
        add_response "2015-05-01"
        add_response "2015-05-01"
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
        add_response "2015-07-31"
        add_response "2015-07-31"
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
        add_response "2015-08-01"
        add_response "2015-08-01"
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
        add_response "2015-08-03"
        add_response "2015-08-03"
        add_response "10000.00"
      end
      should "show results" do
        assert_equal 1500, current_state.calculator.late_filing_penalty
        assert_equal 10_000, current_state.calculator.estimated_bill
        assert_equal 162.95, current_state.calculator.interest
        assert_equal 1000, current_state.calculator.late_payment_penalty
        assert_equal 12_662, current_state.calculator.total_owed_plus_filing_penalty
      end
    end
    # #band 4 case 1
    # 300pounds fine + 1300pounds(previous fine)(band 4), taxdue <= 6002pounds
    context "300pounds fine + 1300pounds(previous fine)(band 4), taxdue <= 6002pounds" do
      setup do
        add_response "2016-02-01"
        add_response "2016-02-01"
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
        add_response "2016-02-03"
        add_response "2016-02-03"
        add_response "10000.00"
      end
      should "show results" do
        assert_equal 2000, current_state.calculator.late_filing_penalty
        assert_equal 10_000, current_state.calculator.estimated_bill
        assert_equal 326.78, current_state.calculator.interest
        assert_equal 1500, current_state.calculator.late_payment_penalty
        assert_equal 13_826, current_state.calculator.total_owed_plus_filing_penalty
      end
    end
  end
  context "online return, tax year 2018-19" do
    setup do
      add_response :"2018-19"
      add_response :online
    end
    should "ask when bill was paid" do
      assert_current_node :when_submitted?
    end
    context "10% fine + 1000pounds(previous fine)(band 4), taxdue > 6002pounds" do
      setup do
        add_response "2020-06-01"
        add_response "2020-06-01"
        add_response "10000.00"
      end
      should "show results" do
        assert_equal 430, current_state.calculator.late_filing_penalty
        assert_equal 10_000, current_state.calculator.estimated_bill
        assert_equal 98.12, current_state.calculator.interest
        assert_equal 500, current_state.calculator.late_payment_penalty
        assert_equal 11_028, current_state.calculator.total_owed_plus_filing_penalty
      end
    end
  end

  context "calculating late payment penalties" do
    payment_amount = "100.00"

    expected_penalty = {
      step_1: 5,
      step_2: 10,
      step_3: 15,
    }

    penalty_dates = {
      "2013-14": {
        step_1: "2015-03-03",
        step_2: "2015-08-03",
        step_3: "2016-02-03",
      },
      "2014-15": {
        step_1: "2016-03-02",
        step_2: "2016-08-02",
        step_3: "2017-02-02",
      },
      "2015-16": {
        step_1: "2017-03-03",
        step_2: "2017-08-03",
        step_3: "2018-02-03",
      },
      "2016-17": {
        step_1: "2018-03-03",
        step_2: "2018-08-03",
        step_3: "2019-02-03",
      },
      "2017-18": {
        step_1: "2019-03-03",
        step_2: "2019-08-03",
        step_3: "2020-02-03",
      },
      "2018-19": {
        step_1: "2020-03-02",
        step_2: "2020-08-02",
        step_3: "2021-02-02",
      },
      "2019-20": {
        step_1: "2021-04-02", # Deadline extended due to COVID-19
        step_2: "2021-08-03",
        step_3: "2022-02-03",
      },
    }

    penalty_dates.each do |tax_year, payment_dates|
      context "for a step 1 payment date in #{tax_year} (#{payment_dates[:step_1]})" do
        setup do
          add_response tax_year
          add_response "online"
          add_response payment_dates[:step_1]
          add_response payment_dates[:step_1]
          add_response payment_amount
        end

        should "calculate correct penalty" do
          assert_equal expected_penalty[:step_1], current_state.calculator.late_payment_penalty
        end
      end

      context "for the day before a step 1 payment date in #{tax_year} (#{payment_dates[:step_1]})" do
        setup do
          add_response tax_year
          add_response "online"
          add_response Date.parse(payment_dates[:step_1]).prev_day
          add_response Date.parse(payment_dates[:step_1]).prev_day
          add_response payment_amount
        end

        should "not apply the step 1 penalty" do
          assert_equal 0, current_state.calculator.late_payment_penalty
        end
      end

      context "for a step 2 payment date in #{tax_year} (#{payment_dates[:step_2]})" do
        setup do
          add_response tax_year
          add_response "online"
          add_response payment_dates[:step_2]
          add_response payment_dates[:step_2]
          add_response payment_amount
        end

        should "calculate correct penalty" do
          assert_equal expected_penalty[:step_2], current_state.calculator.late_payment_penalty
        end
      end

      context "for the day before a step 2 payment date in #{tax_year} (#{payment_dates[:step_2]})" do
        setup do
          add_response tax_year
          add_response "online"
          add_response Date.parse(payment_dates[:step_2]).prev_day
          add_response Date.parse(payment_dates[:step_2]).prev_day
          add_response payment_amount
        end

        should "not apply the step 2 penalty" do
          assert_equal expected_penalty[:step_1], current_state.calculator.late_payment_penalty
        end
      end

      context "for a step 3 payment date in #{tax_year} (#{payment_dates[:step_3]})" do
        setup do
          add_response tax_year
          add_response "online"
          add_response payment_dates[:step_3]
          add_response payment_dates[:step_3]
          add_response payment_amount
        end

        should "calculate correct penalty" do
          assert_equal expected_penalty[:step_3], current_state.calculator.late_payment_penalty
        end
      end

      context "for the day before a step 3 payment date in #{tax_year} (#{payment_dates[:step_3]})" do
        setup do
          add_response tax_year
          add_response "online"
          add_response Date.parse(payment_dates[:step_3]).prev_day
          add_response Date.parse(payment_dates[:step_3]).prev_day
          add_response payment_amount
        end

        should "not apply the step 3 penalty" do
          assert_equal expected_penalty[:step_2], current_state.calculator.late_payment_penalty
        end
      end
    end
  end
end
