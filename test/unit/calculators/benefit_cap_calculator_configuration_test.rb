require_relative "../../test_helper"
require 'gds_api/test_helpers/content_api'

module SmartAnswer::Calculators
  class BenefitCapCalculatorConfigurationTest < ActiveSupport::TestCase
    context BenefitCapCalculatorConfiguration do
      setup do
        @config = BenefitCapCalculatorConfiguration.new
      end

      context "national weekly_benefit_caps" do
        should "be £350 for a single person" do
          assert_equal 350, @config.weekly_benefit_cap_amount(:default, :single)
        end
        should "be £500 for a couple with or without children" do
          assert_equal 500, @config.weekly_benefit_cap_amount(:default, :couple)
        end
        should "be £500 for a lone parent" do
          assert_equal 500, @config.weekly_benefit_cap_amount(:default, :parent)
        end
      end

      context "benefits data" do
        should "have a question and description for each benefit" do
          assert_equal :jsa_amount?, @config.benefits(:default).fetch("jsa")[:question]
          assert_equal "Jobseeker’s Allowance", @config.benefits(:default).fetch(:jsa)[:description]
        end
        should "be able get a hash of just benefits and questions" do
          assert_kind_of Hash, @config.questions(:default)
        end
        should "be able get a hash of just benefits and descriptions" do
          assert_kind_of Hash, @config.descriptions(:default)
        end
      end

      context "exempt_benefits" do
        should "contain an entry for Disability Living Allowance" do
          assert_includes @config.exempt_benefits(:default), "Disability Living Allowance"
        end
      end

      context "multiple configuration sets" do
        setup do
          BenefitCapCalculatorConfiguration.any_instance.stubs(:dataset).returns(
            default: {
              weekly_benefit_caps: {
                national: {
                  first: {
                    amount: 100,
                    description: "first cap"
                  },
                  second: {
                    amount: 200,
                    description: "second cap"
                  }
                }
              },
              exempt_benefits: ["first exempt benefit", "second exempt benefit"],
              benefits: {
                first_benefit: {
                  question: "first_question",
                  description: "first description"
                },
                second_benefit: {
                  question: "second_question",
                  description: "second description"
                },
                third_benefit: {
                  question: "third_question",
                  description: "third description"
                }
              }
            },
            other: {
              weekly_benefit_caps: {
                national: {
                  first: {
                    amount: 300,
                    description: "first other cap"
                  },
                  second: {
                    amount: 400,
                    description: "second other cap"
                  }
                }
              },
              exempt_benefits: ["first other exempt benefit", "second other exempt benefit"],
              benefits: {
                first_benefit: {
                  question: "other_first_question",
                  description: "other first description"
                },
                second_benefit: {
                  question: "other_second_question",
                  description: "other second description"
                },
                other_third_benefit: {
                  question: "other_third_question",
                  description: "other third description"
                }
              }
            }
          )
        end
        context "default configuration" do
          should "get weekly_benefit_caps data for the default configuration" do
            assert_equal 100, @config.weekly_benefit_cap_amount(:default, :first)
          end
          should "get exempt benefits for the default configuration" do
            assert_includes @config.exempt_benefits(:default), "first exempt benefit"
          end
          should "get benefits data for the default configuration" do
            assert_equal "first_question", @config.benefits(:default).fetch(:first_benefit)[:question]
          end
        end
        context "other configuration" do
          should "get weekly_benefit_caps data for the other configuration" do
            assert_equal 300, @config.weekly_benefit_cap_amount(:other, :first)
          end
          should "get exempt benefits for the other configuration" do
            assert_includes @config.exempt_benefits(:other), "first other exempt benefit"
          end
          should "get benefits data for the other configuration" do
            assert_equal "other_first_question", @config.benefits(:other).fetch("first_benefit")["question"]
          end
        end
        context "merge questions" do
          should "get all benefit questions from multiple configuration sets" do
            questions = @config.all_questions
            refute_includes questions.values, "first_question"
            refute_includes questions.values, "second_question"
            assert_includes questions.values, "other_first_question"
            assert_includes questions.values, "other_second_question"
            assert_includes questions.values, "third_question"
            assert_includes questions.values, "other_third_question"
          end
        end
      end
    end
  end
end
