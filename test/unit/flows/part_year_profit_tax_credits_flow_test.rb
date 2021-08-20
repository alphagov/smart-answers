require_relative "../../test_helper"
require_relative "flow_unit_test_helper"

class PartYearProfitTaxCreditsFlowTest < ActiveSupport::TestCase
  include FlowUnitTestHelper

  setup do
    @calculator = SmartAnswer::Calculators::PartYearProfitTaxCreditsCalculator.new
    @flow = PartYearProfitTaxCreditsFlow.build
  end

  should "start when_did_your_tax_credits_award_end? question" do
    assert_equal :when_did_your_tax_credits_award_end?, @flow.questions.first.name
  end

  context "when answering when_did_your_tax_credits_award_end? question" do
    setup do
      SmartAnswer::Calculators::PartYearProfitTaxCreditsCalculator.stubs(:new).returns(@calculator)
      setup_states_for_question(
        :when_did_your_tax_credits_award_end?,
        responding_with: "2016-02-20",
      )
    end

    should "instantiate and store calculator" do
      assert_same @calculator, @new_state.calculator
    end

    should "store parsed response on calculator as tax_credits_award_ends_on" do
      assert_equal Date.parse("2016-02-20"), @calculator.tax_credits_award_ends_on
    end

    should "go to what_date_do_your_accounts_go_up_to? question" do
      assert_equal :what_date_do_your_accounts_go_up_to?, @new_state.current_node_name
      assert_node_exists :what_date_do_your_accounts_go_up_to?
    end
  end

  context "when answering what_date_do_your_accounts_go_up_to? question" do
    setup do
      setup_states_for_question(
        :what_date_do_your_accounts_go_up_to?,
        responding_with: "0000-04-06",
        initial_state: { calculator: @calculator },
      )
    end

    should "store parsed response on calculator as accounts_end_month_and_day" do
      assert_equal Date.parse("0000-04-06"), @calculator.accounts_end_month_and_day
    end

    should "go to have_you_stopped_trading? question" do
      assert_equal :have_you_stopped_trading?, @new_state.current_node_name
      assert_node_exists :have_you_stopped_trading?
    end
  end

  context "when answering have_you_stopped_trading? question" do
    context "responding with yes" do
      setup do
        setup_states_for_question(
          :have_you_stopped_trading?,
          responding_with: "yes",
          initial_state: { calculator: @calculator },
        )
      end

      should "set stopped_trading to true on the calculator" do
        assert_equal true, @calculator.stopped_trading
      end

      should "go to did_you_start_trading_before_the_relevant_accounting_year? question" do
        assert_equal :did_you_start_trading_before_the_relevant_accounting_year?, @new_state.current_node_name
        assert_node_exists :did_you_start_trading_before_the_relevant_accounting_year?
      end
    end

    context "responding with no" do
      setup do
        setup_states_for_question(
          :have_you_stopped_trading?,
          responding_with: "no",
          initial_state: { calculator: @calculator },
        )
      end

      should "set stopped_trading to false on the calculator" do
        assert_equal false, @calculator.stopped_trading
      end

      should "go to do_your_accounts_cover_a_12_month_period? question" do
        assert_equal :do_your_accounts_cover_a_12_month_period?, @new_state.current_node_name
        assert_node_exists :do_your_accounts_cover_a_12_month_period?
      end
    end
  end

  context "when answering did_you_start_trading_before_the_relevant_accounting_year? question" do
    setup do
      accounting_year = SmartAnswer::YearRange.new(begins_on: Date.parse("2015-04-06"))
      @calculator.stubs(accounting_year: accounting_year)
      question = :did_you_start_trading_before_the_relevant_accounting_year?
      setup_states_for_question(
        question,
        responding_with: "yes",
        initial_state: { calculator: @calculator },
      )
    end

    context "responding with yes" do
      setup do
        question = :did_you_start_trading_before_the_relevant_accounting_year?
        setup_states_for_question(
          question,
          responding_with: "yes",
          initial_state: { calculator: @calculator },
        )
      end

      should "go to when_did_you_stop_trading? question" do
        assert_equal :when_did_you_stop_trading?, @new_state.current_node_name
        assert_node_exists :when_did_you_stop_trading?
      end
    end

    context "responding with no" do
      setup do
        question = :did_you_start_trading_before_the_relevant_accounting_year?
        setup_states_for_question(
          question,
          responding_with: "no",
          initial_state: { calculator: @calculator },
        )
      end

      should "go to when_did_you_start_trading question" do
        assert_equal :when_did_you_start_trading?, @new_state.current_node_name
        assert_node_exists :when_did_you_start_trading?
      end
    end
  end

  context "when answering when_did_you_start_trading? question" do
    setup do
      award_period = SmartAnswer::DateRange.new(
        begins_on: Date.parse("2015-04-06"),
        ends_on: Date.parse("2015-08-01"),
      )
      @calculator.stubs(:award_period).returns(award_period)
      setup_states_for_question(
        :when_did_you_start_trading?,
        responding_with: "2015-02-01",
        initial_state: { calculator: @calculator },
      )
    end

    should "store parsed response on calculator as started_trading_on" do
      assert_equal Date.parse("2015-02-01"), @calculator.started_trading_on
    end

    context "responding with an invalid start trading date" do
      setup do
        @calculator.stubs(:valid_start_trading_date?).returns(false)
      end

      should "raise an exception" do
        exception = assert_raise(SmartAnswer::InvalidResponse) do
          setup_states_for_question(
            :when_did_you_start_trading?,
            responding_with: "0000-01-01",
            initial_state: { calculator: @calculator },
          )
        end
        assert_equal "error_invalid_start_trading_date", exception.message
      end
    end

    context "and the business has stopped trading" do
      setup do
        @calculator.stopped_trading = true
        setup_states_for_question(
          :when_did_you_start_trading?,
          responding_with: "0000-01-01",
          initial_state: { calculator: @calculator },
        )
      end

      should "go to when_did_you_stop_trading? question" do
        assert_equal :when_did_you_stop_trading?, @new_state.current_node_name
        assert_node_exists :when_did_you_stop_trading?
      end
    end

    context "and the business is still trading" do
      setup do
        @calculator.stopped_trading = false
        setup_states_for_question(
          :when_did_you_start_trading?,
          responding_with: "0000-01-01",
          initial_state: { calculator: @calculator },
        )
      end

      should "go to when_did_you_stop_trading? question" do
        assert_equal :what_is_your_taxable_profit?, @new_state.current_node_name
        assert_node_exists :what_is_your_taxable_profit?
      end
    end
  end

  context "when answering when_did_you_stop_trading? question" do
    setup do
      tax_year = SmartAnswer::YearRange.tax_year.starting_in(2015)
      @calculator.stubs(tax_year: tax_year)
      setup_states_for_question(
        :when_did_you_stop_trading?,
        responding_with: "2015-06-01",
        initial_state: { calculator: @calculator },
      )
    end

    should "store parsed response on calculator as stopped_trading_on" do
      assert_equal Date.parse("2015-06-01"), @calculator.stopped_trading_on
    end

    should "go to what_is_your_taxable_profit? question" do
      assert_equal :what_is_your_taxable_profit?, @new_state.current_node_name
      assert_node_exists :what_is_your_taxable_profit?
    end

    context "responding with an invalid stopped trading date" do
      setup do
        @calculator.stubs(:valid_stopped_trading_date?).returns(false)
      end

      should "raise an exception" do
        exception = assert_raise(SmartAnswer::InvalidResponse) do
          setup_states_for_question(
            :when_did_you_stop_trading?,
            responding_with: "0000-01-01",
            initial_state: { calculator: @calculator },
          )
        end
        assert_equal "error_not_in_tax_year", exception.message
      end
    end
  end

  context "when answering do_your_accounts_cover_a_12_month_period? question" do
    context "responding with yes" do
      setup do
        accounting_year = SmartAnswer::YearRange.new(begins_on: Date.parse("2015-01-01"))
        @calculator.stubs(:accounting_year).returns(accounting_year)
        setup_states_for_question(
          :do_your_accounts_cover_a_12_month_period?,
          responding_with: "yes",
          initial_state: { calculator: @calculator },
        )
      end

      should "go to what_is_your_taxable_profit? question" do
        assert_equal :what_is_your_taxable_profit?, @new_state.current_node_name
        assert_node_exists :what_is_your_taxable_profit?
      end
    end

    context "responding with no" do
      setup do
        accounting_year = SmartAnswer::YearRange.new(begins_on: Date.parse("2015-01-01"))
        @calculator.stubs(:accounting_year).returns(accounting_year)
        setup_states_for_question(
          :do_your_accounts_cover_a_12_month_period?,
          responding_with: "no",
          initial_state: { calculator: @calculator },
        )
      end

      should "go to when_did_you_start_trading question" do
        assert_equal :when_did_you_start_trading?, @new_state.current_node_name
        assert_node_exists :when_did_you_start_trading?
      end
    end
  end

  context "when answering what_is_your_taxable_profit? question" do
    setup do
      basis_period = SmartAnswer::YearRange.new(begins_on: Date.parse("2015-04-06"))
      @calculator.stubs(basis_period: basis_period)
      setup_states_for_question(
        :what_is_your_taxable_profit?,
        responding_with: "15000",
        initial_state: { calculator: @calculator },
      )
    end

    should "store parsed response on calculator as taxable_profit" do
      assert_equal SmartAnswer::Money.new(15_000), @calculator.taxable_profit
    end

    should "go to result outcome" do
      assert_equal :result, @new_state.current_node_name
      assert_node_exists :result
    end
  end
end
