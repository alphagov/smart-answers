require_relative "../../test_helper"

module SmartAnswer::Calculators
  class BusinessCoronavirusSupportFinderCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = BusinessCoronavirusSupportFinderCalculator.new
    end

    context "#show?" do
      context "statutory_sick_rebate" do
        setup do
          @calculator.business_size = "0_to_249"
          @calculator.paye_scheme = "yes"
        end

        should "return true when criteria met" do
          assert @calculator.show?(:statutory_sick_rebate)
        end

        should "return false when business has over 249 employees" do
          @calculator.business_size = "over_249"
          assert_not @calculator.show?(:statutory_sick_rebate)
        end

        should "return false when business does not have PAYE scheme" do
          @calculator.paye_scheme = "no"
          assert_not @calculator.show?(:statutory_sick_rebate)
        end
      end

      context "self_employed_income_scheme" do
        should "return true when self_employed is yes" do
          @calculator.self_employed = "yes"
          assert @calculator.show?(:self_employed_income_scheme)
        end

        should "return false when self_employed is no" do
          @calculator.self_employed = "no"
          assert_not @calculator.show?(:self_employed_income_scheme)
        end
      end

      context "retail_hospitality_leisure_business_rates" do
        setup do
          @calculator.business_based = "england"
          @calculator.non_domestic_property = "yes"
          @calculator.sectors = %w[retail_hospitality_or_leisure]
        end

        should "return true when criteria met" do
          assert @calculator.show?(:retail_hospitality_leisure_business_rates)
        end

        should "return false when in a devolved admininstration" do
          @calculator.business_based = "scotland"
          assert_not @calculator.show?(:retail_hospitality_leisure_business_rates)
        end

        should "return false when no non-domestic property" do
          @calculator.non_domestic_property = "no"
          assert_not @calculator.show?(:retail_hospitality_leisure_business_rates)
        end

        should "return false when not supported business sectors" do
          @calculator.sectors = %w[none]
          assert_not @calculator.show?(:retail_hospitality_leisure_business_rates)
        end
      end

      context "nursery_support" do
        setup do
          @calculator.business_based = "england"
          @calculator.non_domestic_property = "yes"
          @calculator.sectors = %w[nurseries]
        end

        should "return true when criteria met" do
          assert @calculator.show?(:nursery_support)
        end

        should "return false when based in devolved administration" do
          @calculator.business_based = "scotland"
          assert_not @calculator.show?(:nursery_support)
        end

        should "return false when not a non-domestic property" do
          @calculator.non_domestic_property = "no"
          assert_not @calculator.show?(:nursery_support)
        end

        should "return false when not supported business sector" do
          @calculator.sectors = %w[retail_hospitality_or_leisure]
          assert_not @calculator.show?(:nursery_support)
        end
      end

      context "kickstart_scheme" do
        should "return true when business based not in Northern Ireland" do
          @calculator.business_based = "scotland"
          assert @calculator.show?(:kickstart_scheme)
        end

        should "return false when business based in Northern Ireland" do
          @calculator.business_based = "northern_ireland"
          assert_not @calculator.show?(:kickstart_scheme)
        end
      end

      context "vat_reduction" do
        should "return true when business is in the retail sector" do
          @calculator.sectors = %w[retail_hospitality_or_leisure]
          assert @calculator.show?(:vat_reduction)
        end

        should "return false when business is not in the retail sector" do
          assert_not @calculator.show?(:vat_reduction)
        end
      end

      context "traineeships" do
        should "return true when business is based in england" do
          @calculator.business_based = "england"
          assert @calculator.show?(:traineeships)
        end

        should "return false when business is not based in england" do
          @calculator.business_based = "scotland"
          assert_not @calculator.show?(:traineeships)
        end
      end

      context "apprenticeships" do
        should "return true when business is based in england" do
          @calculator.business_based = "england"
          assert @calculator.show?(:apprenticeships)
        end

        should "return false when business is not based in england" do
          @calculator.business_based = "scotland"
          assert_not @calculator.show?(:apprenticeships)
        end
      end

      context "tlevels" do
        should "return true when business is based in england" do
          @calculator.business_based = "england"
          assert @calculator.show?(:tlevels)
        end

        should "return false when business is not based in england" do
          @calculator.business_based = "scotland"
          assert_not @calculator.show?(:tlevels)
        end
      end

      context "additional_restrictions_grant" do
        should "return true when business based in england" do
          @calculator.business_based = "england"
          assert @calculator.show?(:additional_restrictions_grant)
        end

        should "return false when business not based in england" do
          @calculator.business_based = "scotland"
          assert_not @calculator.show?(:additional_restrictions_grant)
        end
      end

      context "council_grants" do
        should "return true for one of the council grant rules" do
          # meeting criteria for additional_restrictions_grant
          @calculator.business_based = "england"
          assert @calculator.show?(:council_grants)
        end

        should "return false for other rules" do
          assert_not @calculator.show?(:council_grants)
        end
      end
    end
  end
end
