require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MarriedCouplesAllowanceRatesQueryTest < ActiveSupport::TestCase
    setup do
      @query = RatesQuery.from_file("personal_allowance")
    end

    should "have all required rates defined for the current fiscal year" do
      %w[personal_allowance income_limit_for_personal_allowances].each do |rate|
        assert @query.rates.send(rate).is_a?(Numeric)
      end
    end

    should "be the latest known walue on 15th April 2116 (fallback)" do
      assert @query.rates(Date.parse("2116-04-15")).personal_allowance.is_a?(Numeric)
    end
  end
end
