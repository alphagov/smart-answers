require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MarriedCouplesAllowanceRateQueryTest < ActiveSupport::TestCase
    context SmartAnswer::Calculators::MarriedCouplesAllowanceRateQuery do
      setup do
        @query = SmartAnswer::Calculators::MarriedCouplesAllowanceRateQuery.new
      end

      should "have all required rates defined for current_fiscal year" do
        %w(personal_allowance over_65_allowance over_75_allowance income_limit_for_personal_allowances maximum_married_couple_allowance minimum_married_couple_allowance).each do |rate|
          assert @query.send(rate).is_a?(Numeric)
        end
      end

      context "personal_allowance" do
        context "on 15th April 2116 (fallback)" do
          setup do
            Timecop.travel("2116-04-05")
          end

          should "be the latest known walue" do
            assert_equal 10000, @query.personal_allowance
          end
        end

        context "on 6th April 2013" do
          setup do
            Timecop.travel("2013-04-06")
          end

          should "be 9440" do
            assert_equal 9440, @query.personal_allowance
          end
        end

        context "on 6th April 2014" do
          setup do
            Timecop.travel("2014-04-06")
          end

          should "be 10000" do
            assert_equal 10000, @query.personal_allowance
          end
        end
      end

      context "current_fiscal_year" do
        context "on 5th April 2013" do
          setup do
            Timecop.travel("2013-04-05")
          end

          should "be 2012" do
            assert_equal 2012, @query.current_fiscal_year
          end
        end

        context "on 6th April 2013" do
          setup do
            Timecop.travel("2013-04-06")
          end

          should "be 2013" do
            assert_equal 2013, @query.current_fiscal_year
          end
        end

        context "on 6th April 2014" do
          setup do
            Timecop.travel("2014-04-06")
          end

          should "be 2014" do
            assert_equal 2014, @query.current_fiscal_year
          end
        end
      end
    end
  end
end
