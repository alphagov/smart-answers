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
          assert_equal 50, @calculator.calculate_weighted_scores(assets: true, property: true, shares: true,
                                                revenue: 10000, funding_min: 999, funding_max: 1000,
                                                employees: 10)[:shares]

          assert_equal 0, @calculator.calculate_weighted_scores(assets: false, property: true, shares: false,
                                                revenue: 10000, funding_min: 999, funding_max: 1000,
                                                employees: 10)[:shares]

          
          assert_equal 25, @calculator.calculate_weighted_scores(assets: false, property: false, shares: false,
                                                revenue: 10000, funding_min: 1000, funding_max: 1000,
                                                employees: 10)[:shares]

          
          assert_equal 75, @calculator.calculate_weighted_scores(assets: false, property: false, shares: true,
                                                revenue: 10000, funding_min: 1000, funding_max: 1000,
                                                employees: 10)[:shares]

          assert_equal 100, @calculator.calculate_weighted_scores(assets: false, property: false, shares: true,
                                                revenue: 10000, funding_min: 1000, funding_max: 10000,
                                                employees: 10)[:shares]
        end

        should "work out the scores for the loans finance type" do
          assert_equal 91, @calculator.calculate_weighted_scores(assets: true, property: true, shares: false,
                                                revenue: 999, funding_min: 999, funding_max: 1000,
                                                employees: 10)[:loans]

          assert_equal 98, @calculator.calculate_weighted_scores(assets: false, property: true, shares: false,
                                                revenue: 10000, funding_min: 999, funding_max: 1000,
                                                employees: 10)[:loans]
          
          assert_equal 100, @calculator.calculate_weighted_scores(assets: true, property: true, shares: false,
                                                revenue: 10001, funding_min: 999, funding_max: 1000,
                                                employees: 10)[:loans]

          assert_equal 87, @calculator.calculate_weighted_scores(assets: false, property: false, shares: false,
                                                revenue: 0, funding_min: 999, funding_max: 1000,
                                                employees: 10)[:loans]
        end

        should "work out the scores for the grants finance type" do
          assert_equal 78, @calculator.calculate_weighted_scores(assets: true, property: true, shares: false,
                                                revenue: 10001, funding_min: 1001, funding_max: 10001,
                                                employees: 10)[:grants]

          assert_equal 58, @calculator.calculate_weighted_scores(assets: true, property: false, shares: false,
                                                revenue: 10001, funding_min: 1001, funding_max: 10001,
                                                employees: 10)[:grants]

          assert_equal 48, @calculator.calculate_weighted_scores(assets: true, property: false, shares: false,
                                                revenue: 10001, funding_min: 1001, funding_max: 10001,
                                                employees: 250)[:grants]

          assert_equal 60, @calculator.calculate_weighted_scores(assets: true, property: false, shares: false,
                                                revenue: 10001, funding_min: 999, funding_max: 1000,
                                                employees: 250)[:grants]

        end

        should "work out the scores for the overdrafts finance type" do
          assert_equal 98, @calculator.calculate_weighted_scores(assets: false, property: true, shares: false,
                                                revenue: 10000, funding_min: 1001, funding_max: 10001,
                                                employees: 10)[:overdrafts]

          assert_equal 83, @calculator.calculate_weighted_scores(assets: false, property: false, shares: false,
                                                revenue: 9999, funding_min: 1001, funding_max: 10001,
                                                employees: 10)[:overdrafts]

          assert_equal 100, @calculator.calculate_weighted_scores(assets: true, property: true, shares: false,
                                                revenue: 10001, funding_min: 9999, funding_max: 100000,
                                                employees: 250)[:overdrafts]
        end
      end

      should "work out the scores for the invoices finance type" do
        assert_equal 74, @calculator.calculate_weighted_scores(assets: true, property: false, shares: false,
                                                revenue: 10001, funding_min: 1001, funding_max: 10001,
                                                employees: 10)[:invoices]

        assert_equal 65, @calculator.calculate_weighted_scores(assets: false, property: false, shares: false,
                                                revenue: 9999, funding_min: 999, funding_max: 10000,
                                                employees: 10)[:invoices]

        assert_equal 94, @calculator.calculate_weighted_scores(assets: true, property: true, shares: false,
                                                revenue: 10001, funding_min: 999, funding_max: 1000,
                                                employees: 250)[:invoices]        
        
        assert_equal 100, @calculator.calculate_weighted_scores(assets: true, property: true, shares: false,
                                                revenue: 999, funding_min: 1, funding_max: 999,
                                                employees: 50)[:invoices]
      
      end      
      
      should "work out the scores for the leasing finance type" do
        assert_equal 94, @calculator.calculate_weighted_scores(assets: true, property: true, shares: false,
                                                revenue: 10001, funding_min: 1001, funding_max: 10001,
                                                employees: 10)[:leasing]

        assert_equal 65, @calculator.calculate_weighted_scores(assets: false, property: false, shares: false,
                                                revenue: 9999, funding_min: 999, funding_max: 10000,
                                                employees: 10)[:leasing]

        assert_equal 84, @calculator.calculate_weighted_scores(assets: true, property: false, shares: false,
                                                revenue: 10001, funding_min: 99, funding_max: 1000,
                                                employees: 250)[:leasing]        
        
        assert_equal 100, @calculator.calculate_weighted_scores(assets: true, property: true, shares: false,
                                                revenue: 999, funding_min: 1, funding_max: 999,
                                                employees: 50)[:leasing]
      end
    end
  end
end


