require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MarriedCouplesAllowanceRatesQueryTest < ActiveSupport::TestCase
    setup do
      @query = RatesQuery.from_file("married_couples_allowance")
    end

    should "have all required rates defined for the current fiscal year" do
      %w(maximum_married_couple_allowance minimum_married_couple_allowance).each do |rate|
        assert @query.rates.send(rate).is_a?(Numeric)
      end
    end
  end
end
