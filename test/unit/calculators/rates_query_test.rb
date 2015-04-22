require_relative "../../test_helper"

module SmartAnswer::Calculators
  class RatesQueryTest < ActiveSupport::TestCase
    context SmartAnswer::Calculators::RatesQuery do
      context "#rates" do
        should "be 1 for 2013-01-31" do
          test_rate = SmartAnswer::Calculators::RatesQuery.new('exact_date_rates', relevant_date: Date.parse('2013-01-31'))
          test_rate.stubs(:load_path).returns(File.join("test", "fixtures", "rates"))
          assert_equal 1, test_rate.rates.rate
        end

        should "be 2 for 2013-02-01" do
          test_rate = SmartAnswer::Calculators::RatesQuery.new('exact_date_rates', relevant_date: Date.parse('2013-02-01'))
          test_rate.stubs(:load_path).returns(File.join("test", "fixtures", "rates"))
          assert_equal 2, test_rate.rates.rate
        end

        should "be the latest known rate (2) for uncovered future dates" do
          test_rate = SmartAnswer::Calculators::RatesQuery.new('exact_date_rates', relevant_date: Date.parse('2113-03-12'))
          test_rate.stubs(:load_path).returns(File.join("test", "fixtures", "rates"))
          assert_equal 2, test_rate.rates.rate
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
            end

            should "be the latest known walue" do
              assert @query.rates.personal_allowance.is_a?(Numeric)
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
