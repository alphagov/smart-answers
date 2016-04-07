require_relative "../../test_helper"

module SmartAnswer::Calculators
  class BenefitCapCalculatorDataQueryTest < ActiveSupport::TestCase
    context BenefitCapCalculatorDataQuery do
      setup do
        @query = BenefitCapCalculatorDataQuery.new
        @rates = @query.data.fetch("rates")
      end

      context "benefit_cap_data" do
        context "family types" do
          should "contain value for single person" do
            assert_equal 350, @rates["single"]
          end
          should "contain value for a couple with or without children" do
            assert_equal 500, @rates["couple"]
          end
          should "contain value for lone parent" do
            assert_equal 500, @rates["parent"]
          end
        end
      end
    end
  end
end
