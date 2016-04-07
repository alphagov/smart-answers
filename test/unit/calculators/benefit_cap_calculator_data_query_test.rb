require_relative "../../test_helper"

module SmartAnswer::Calculators
  class BenefitCapCalculatorDataQueryTest < ActiveSupport::TestCase
    context BenefitCapCalculatorDataQuery do
      setup do
        @query = BenefitCapCalculatorDataQuery.new
      end

      context "benefit_cap_data" do
        context "family types" do
          should "contain value for single person" do
            assert_equal 350, @query.data["single"]
          end
          should "contain value for a couple with or without children" do
            assert_equal 500, @query.data["couple"]
          end
          should "contain value for lone parent" do
            assert_equal 500, @query.data["parent"]
          end
        end
      end
    end
  end
end
