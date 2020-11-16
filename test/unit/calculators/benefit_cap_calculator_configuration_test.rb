require_relative "../../test_helper"

module SmartAnswer::Calculators
  class BenefitCapCalculatorConfigurationTest < ActiveSupport::TestCase
    context BenefitCapCalculatorConfiguration do
      setup do
        @config = BenefitCapCalculatorConfiguration
      end

      context "national weekly_benefit_caps" do
        should "be £257.69 for a single person" do
          assert_equal 257.69, @config.weekly_benefit_cap_amount(:single)
        end
        should "be £384.62 for a couple with or without children" do
          assert_equal 384.62, @config.weekly_benefit_cap_amount(:couple)
        end
        should "be £384.62 for a lone parent" do
          assert_equal 384.62, @config.weekly_benefit_cap_amount(:parent)
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
        should "return a Hash with indifferent access" do
          assert_kind_of HashWithIndifferentAccess, @config.exempt_benefits
        end

        should "return matching description of exempt benefits" do
          descriptions = ["Attendance Allowance", "Carer's Allowance", "Disability Living Allowance", "Guardian's Allowance", "Industrial Injuries Benefit", "Personal Independence Payment", "Employment and Support Allowance (support component)", "War Widow’s or War Widower’s Pension", "Armed Forces Compensation Scheme", "Armed Forces Independence Payment", "War pensions"]
          assert_equal @config.exempt_benefits.values, descriptions
        end

        should "return keys matching exempt benefits" do
          benefits = %w[attendance_allowance carers_allowance disability_living_allowance guardians_allowance industrial_injuries_benefit personal_independence_payment employment_support_allowance war_partner_pension armed_forces_compensation_scheme armed_forces_independence_payment war_pensions]
          assert_equal benefits, @config.exempt_benefits.keys
        end
      end

      context "Flow configuration" do
        setup do
          BenefitCapCalculatorConfiguration.stubs(:data).returns(
            weekly_benefit_caps: {
              national: {
                first: {
                  amount: 100,
                  description: "first cap",
                },
                second: {
                  amount: 200,
                  description: "second cap",
                },
              },
            },
            exempt_benefits: {
              first_exempt_benefit: "first exempt benefit",
              second_exempt_benefit: "second exempt benefit",
            },
            benefits: {
              first_benefit: {
                question: "first_question",
                description: "first description",
              },
              second_benefit: {
                question: "second_question",
                description: "second description",
              },
              third_benefit: {
                question: "third_question",
                description: "third description",
              },
            },
          )
        end
        should "get weekly_benefit_caps data" do
          assert_equal 100, @config.weekly_benefit_cap_amount(:first)
        end
        should "get exempt benefits" do
          assert_includes @config.exempt_benefits.values, "first exempt benefit"
        end
        should "get benefits data" do
          assert_equal "first_question", @config.benefits.fetch(:first_benefit)[:question]
        end
      end

      context "location of user" do
        context "lives outside of Greater London" do
          setup do
            stub_imminence_has_areas_for_postcode("B1%201PW", [{ type: "EUR", name: "West Midlands", country_name: "England" }])
          end
          should "return false" do
            assert_equal false, @config.london?("B1%201PW")
          end
        end
        context "lives in Greater London" do
          setup do
            stub_imminence_has_areas_for_postcode("IG6%202BA", [{ type: "EUR", name: "London", country_name: "England" }])
          end
          should "return true" do
            assert_equal true, @config.london?("IG6%202BA")
          end
        end
      end
    end
  end
end
