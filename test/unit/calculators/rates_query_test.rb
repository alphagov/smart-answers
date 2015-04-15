require_relative "../../test_helper"

module SmartAnswer::Calculators
  class RatesQueryTest < ActiveSupport::TestCase
    context SmartAnswer::Calculators::RatesQuery do
      context "#relevant_fiscal_year" do
        setup do
          @query = SmartAnswer::Calculators::RatesQuery.new('whatever')
        end

        context "on 5th April 2013" do
          setup do
            Timecop.travel("2013-04-05")
          end

          should "be 2012" do
            assert_equal 2012, @query.relevant_fiscal_year
          end
        end

        context "on 6th April 2013" do
          setup do
            Timecop.travel("2013-04-06")
          end

          should "be 2013" do
            assert_equal 2013, @query.relevant_fiscal_year
          end
        end

        context "on 6th April 2014" do
          setup do
            Timecop.travel("2014-04-06")
          end

          should "be 2014" do
            assert_equal 2014, @query.relevant_fiscal_year
          end
        end
      end

      context "Married couples allowance" do
        setup do
          @query = SmartAnswer::Calculators::RatesQuery.new('married_couples_allowance')
        end

        should "have all required rates defined for the current fiscal year" do
          %w(personal_allowance over_65_allowance over_75_allowance income_limit_for_personal_allowances maximum_married_couple_allowance minimum_married_couple_allowance).each do |rate|
            assert @query.rates.send(rate).is_a?(Numeric)
          end
        end

        context "personal_allowance" do
          context "on 15th April 2116 (fallback)" do
            setup do
              Timecop.travel("2116-04-15")
              @query.stubs(:data).returns({ "personal_allowance" => { 2014 => 10000, 2015 => 99999 }})
            end

            should "be the latest known walue" do
              assert_equal 99999, @query.rates.personal_allowance
            end
          end

          context "on 5th April 2016" do
            setup do
              Timecop.travel("2016-04-05")
            end

            should "be 10600" do
              assert_equal 10600, @query.rates.personal_allowance
            end
          end

          context "on 6th April 2013" do
            setup do
              Timecop.travel("2013-04-06")
            end

            should "be 9440" do
              assert_equal 9440, @query.rates.personal_allowance
            end
          end

          context "on 6th April 2014" do
            setup do
              Timecop.travel("2014-04-06")
            end

            should "be 10000" do
              assert_equal 10000, @query.rates.personal_allowance
            end
          end
        end
      end
    end
  end
end
