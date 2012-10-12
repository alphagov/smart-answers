require_relative "../../test_helper"

module SmartAnswer::Calculators
  class WhichFinanceCalculatorTest < ActiveSupport::TestCase
  	context "WhichFinanceCalculator" do
      setup do
        @calculator = WhichFinanceCalculator.new
      end
  		should "load finance data" do
        assert_equal Array, @calculator.finance_data.class
        assert_equal FinanceWeighting, @calculator.finance_data.first.class
        assert_equal BooleanWeightingScore, @calculator.finance_data.first.shares.class
        assert_equal ThresholdWeightingScore, @calculator.finance_data.first.funding_min.class
      end
      context "calculate_weighted_scores method" do
        should "work out the scores for the shares finance type" do
          assert_equal 75, @calculator.calculate_weighted_scores(assets: true, property: true, shares: true,
                                                revenue: 10000, funding_min: 100, funding_max: 1000,
                                                employees: 10)[:shares]

          assert_equal 25, @calculator.calculate_weighted_scores(assets: false, property: true, shares: false,
                                                revenue: 10000, funding_min: 100, funding_max: 1000,
                                                employees: 10)[:shares]

          
          assert_equal 50, @calculator.calculate_weighted_scores(assets: false, property: false, shares: false,
                                                revenue: 10000, funding_min: 1000, funding_max: 1000,
                                                employees: 10)[:shares]

          
          assert_equal 100, @calculator.calculate_weighted_scores(assets: false, property: false, shares: true,
                                                revenue: 10000, funding_min: 1000, funding_max: 1000,
                                                employees: 10)[:shares]
        end

        should "work out the scores for the loans finance type" do
          assert_equal 80, @calculator.calculate_weighted_scores(assets: true, property: true, shares: false,
                                                revenue: 10000, funding_min: 100, funding_max: 1000,
                                                employees: 10)[:loans]
        end
      end
    end
  end
end


