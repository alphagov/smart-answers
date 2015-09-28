require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StatePensionTopupDataQueryTest < ActiveSupport::TestCase
    setup do
      SmartAnswer::Calculators::StatePensionTopupDataQuery
        .stubs(:age_and_rates_data)
        .returns({
          'age_and_rates' => {
            100 => 127,
            99 => 137
          }
        })
      @query = SmartAnswer::Calculators::StatePensionTopupDataQuery.new
    end

    should "use the rate for the maximum provided age for people who are older" do
      assert_equal @query.age_and_rates(100), @query.age_and_rates(150)
    end

    should "return a numeric value for covered age ranges" do
      assert_equal 137, @query.age_and_rates(99)
    end

    should "return nil for uncovered age ranges" do
      assert_equal nil, @query.age_and_rates(61)
    end
  end
end
