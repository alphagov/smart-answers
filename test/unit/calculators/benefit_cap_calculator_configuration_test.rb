require_relative "../../test_helper"

module SmartAnswer::Calculators
  class BenefitCapCalculatorConfigurationTest < ActiveSupport::TestCase
    context BenefitCapCalculatorConfiguration do
      setup do
        @config = BenefitCapCalculatorConfiguration.new
      end

      context "weekly_benefit_caps" do
        should "be £350 for a single person" do
          assert_equal 350, @config.weekly_benefit_cap_amount("single")
        end
        should "be £500 for a couple with or without children" do
          assert_equal 500, @config.weekly_benefit_cap_amount("couple")
        end
        should "be £500 for a lone parent" do
          assert_equal 500, @config.weekly_benefit_cap_amount("parent")
        end
      end

      context "benefits data" do
        should "have a question and description for each benefit" do
          assert_equal :jsa_amount?, @config.benefits.fetch("jsa")["question"]
          assert_equal "Jobseeker’s Allowance", @config.benefits.fetch("jsa")["description"]
        end
        should "be able get a hash of just benefits and questions" do
          assert_kind_of Hash, @config.questions
        end
        should "be able get a hash of just benefits and descriptions" do
          assert_kind_of Hash, @config.descriptions
        end
      end

      context "exempt_benefits" do
        should "contain an entry for Disability Living Allowance" do
          assert_includes @config.exempt_benefits, "Disability Living Allowance"
        end
      end
    end
  end
end
