require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MarriedCouplesAllowanceRatesQueryTest < ActiveSupport::TestCase
    setup do
      @query = RatesQuery.from_file('married_couples_allowance')
    end

    should "have all required rates defined for the current fiscal year" do
      %w(personal_allowance over_65_allowance over_75_allowance income_limit_for_personal_allowances maximum_married_couple_allowance minimum_married_couple_allowance).each do |rate|
        assert @query.rates.send(rate).is_a?(Numeric)
      end
    end

    context "personal_allowance" do
      should "be the latest known walue on 15th April 2116 (fallback)" do
        assert @query.rates(Date.parse("2116-04-15")).personal_allowance.is_a?(Numeric)
      end

      should "be 10600 on 5th April 2016" do
        assert_equal 10600, @query.rates(Date.parse("2016-04-05")).personal_allowance
      end

      should "be 9440 on 6th April 2013" do
        assert_equal 9440, @query.rates(Date.parse("2013-04-06")).personal_allowance
      end

      should "be 10000 on 6th April 2014" do
        assert_equal 10000, @query.rates(Date.parse("2014-04-06")).personal_allowance
      end
    end
  end
end
