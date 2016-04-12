require_relative "../../test_helper"

module SmartAnswer::Calculators
  class BenefitCapCalculatorDataQueryTest < ActiveSupport::TestCase
    context BenefitCapCalculatorDataQuery do
      setup do
        @query = BenefitCapCalculatorDataQuery.new
      end

      context "weekly_benefit_cap" do
        should "be £350 for a single person" do
          assert_equal 350, @query.weekly_benefit_cap["single"]
        end
        should "be £500 for a couple with or without children" do
          assert_equal 500, @query.weekly_benefit_cap["couple"]
        end
        should "be £500 for a lone parent" do
          assert_equal 500, @query.weekly_benefit_cap["parent"]
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
