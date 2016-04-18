require_relative "../../test_helper"
require 'gds_api/test_helpers/content_api'

module SmartAnswer::Calculators
  class BenefitCapCalculatorConfigurationTest < ActiveSupport::TestCase
    context BenefitCapCalculatorConfiguration do
      setup do
        @config = BenefitCapCalculatorConfiguration.new
      end

      context "weekly_benefit_caps" do
        should "be £350 for a single person" do
          assert_equal 350, @config.weekly_benefit_cap_amount(:single)
        end
        should "be £500 for a couple with or without children" do
          assert_equal 500, @config.weekly_benefit_cap_amount(:couple)
        end
        should "be £500 for a lone parent" do
          assert_equal 500, @config.weekly_benefit_cap_amount(:parent)
        end
      end

      context "benefits data" do
        should "have a question and description for each benefit" do
          assert_equal :jsa_amount?, @config.benefits.fetch("jsa")[:question]
          assert_equal "Jobseeker’s Allowance", @config.benefits.fetch(:jsa)[:description]
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

      context "multiple configuration sets" do
        setup do
          BenefitCapCalculatorConfiguration.any_instance.stubs(:dataset).returns(
            default: {
              weekly_benefit_caps: {
                first: {
                  amount: 100,
                  description: "first cap"
                },
                second: {
                  amount: 200,
                  description: "second cap"
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
                }
              }
            },
            other: {
              weekly_benefit_caps: {
                first: {
                  amount: 300,
                  description: "first other cap"
                },
                second: {
                  amount: 400,
                  description: "second other cap"
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
                }
              }
            }
          )
        end
        context "default configuration" do
          setup do
            @config = BenefitCapCalculatorConfiguration.new
          end
          should "get weekly_benefit_caps data for the default configuration" do
            assert_equal 100, @config.weekly_benefit_cap_amount(:first)
          end
          should "get exempt benefits for the default configuration" do
            assert_includes @config.exempt_benefits, "first exempt benefit"
          end
          should "get benefits data for the default configuration" do
            assert_equal "first_question", @config.benefits.fetch(:first_benefit)[:question]
          end
        end
        context "other configuration" do
          setup do
            @config = BenefitCapCalculatorConfiguration.new(:other)
          end
          should "get weekly_benefit_caps data for the other configuration" do
            assert_equal 300, @config.weekly_benefit_cap_amount(:first)
          end
          should "get exempt benefits for the other configuration" do
            assert_includes @config.exempt_benefits, "first other exempt benefit"
          end
          should "get benefits data for the other configuration" do
            assert_equal "other_first_question", @config.benefits.fetch("first_benefit")["question"]
          end
        end
      end
    end
  end
end
