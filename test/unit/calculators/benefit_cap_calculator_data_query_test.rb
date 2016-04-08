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
            assert_equal 350, @query.rates["single"]
          end
          should "contain value for a couple with or without children" do
            assert_equal 500, @query.rates["couple"]
          end
          should "contain value for lone parent" do
            assert_equal 500, @query.rates["parent"]
          end
        end
      end

      context "benefit type data" do
        should "have a question and description for each benefit type" do
          assert_equal :jsa_amount?, @query.benefits.fetch("jsa")["question"]
          assert_equal "Jobseeker’s Allowance", @query.benefits.fetch("jsa")["description"]
        end
        should "be able get a hash of just benefits and questions" do
          assert_kind_of Hash, @query.questions
        end
        should "be able get a hash of just benefits and descriptions" do
          assert_kind_of Hash, @query.descriptions
        end
      end
    end
  end
end
