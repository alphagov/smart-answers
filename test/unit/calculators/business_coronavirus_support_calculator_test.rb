require_relative "../../test_helper"

module SmartAnswer::Calculators
  class BusinessCoronavirusSupportFinderCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = BusinessCoronavirusSupportFinderCalculator.new
    end

    context "#show?" do
      context "job_retention_scheme" do
        should "return true when criteria met" do
          @calculator.paye_scheme = "yes"
          assert @calculator.show?(:job_retention_scheme)
        end

        should "return false when criteria not met" do
          @calculator.paye_scheme = "no"
          assert_not @calculator.show?(:job_retention_scheme)
        end
      end

      context "vat_scheme" do
        should "return true when criteria met" do
          @calculator.annual_turnover = "500m_and_over"
          assert @calculator.show?(:vat_scheme)
        end

        should "return false when criteria not met" do
          @calculator.annual_turnover = "under_85k"
          assert_not @calculator.show?(:vat_scheme)
        end
      end

      context "self_assessment_payments" do
        should "return true when criteria met" do
          @calculator.self_assessment_july_2020 = "yes"
          assert @calculator.show?(:self_assessment_payments)
        end

        should "return false when criteria not met" do
          @calculator.self_assessment_july_2020 = "no"
          assert_not @calculator.show?(:self_assessment_payments)
        end
      end

      context "statutory_sick_rebate" do
        setup do
          @calculator.business_size = "0_to_249"
          @calculator.self_assessment_july_2020 = "yes"
        end

        should "return true when criteria met" do
          assert @calculator.show?(:statutory_sick_rebate)
        end

        should "return false when business has over 249 employees" do
          @calculator.business_size = "over_249"
          assert_not @calculator.show?(:statutory_sick_rebate)
        end

        should "return false when not submitting self assessment for July 2020" do
          @calculator.self_assessment_july_2020 = "no"
          assert_not @calculator.show?(:statutory_sick_rebate)
        end
      end

      context "self_employed_income_scheme" do
        should "return true when business size is 0 to 249 employees" do
          @calculator.business_size = "0_to_249"
          assert @calculator.show?(:self_employed_income_scheme)
        end

        should "return false when business size is over 249 employees" do
          @calculator.business_size = "over_249"
          assert_not @calculator.show?(:self_employed_income_scheme)
        end
      end

      context "business_rates" do
        setup do
          @calculator.business_based = "england"
          @calculator.business_rates = "yes"
          @calculator.non_domestic_property = "over_15k"
          @calculator.sectors = %w[retail hospitality leisure]
        end

        should "return true when criteria met" do
          assert @calculator.show?(:business_rates)
        end

        should "return false when in a devolved admininstration" do
          @calculator.business_based = "scotland"
          assert_not @calculator.show?(:business_rates)
        end

        should "return false when no non domestic property" do
          @calculator.non_domestic_property = "none"
          assert_not @calculator.show?(:business_rates)
        end

        should "return false when not supported business sectors" do
          @calculator.sectors = ["None of the above"]
          assert_not @calculator.show?(:business_rates)
        end
      end

      context "grant_funding" do
        setup do
          @calculator.business_based = "england"
          @calculator.business_rates = "yes"
          @calculator.non_domestic_property = "over_15k"
          @calculator.sectors = %w[retail hospitality leisure]
        end

        should "return true when criteria met" do
          assert @calculator.show?(:grant_funding)
        end

        should "return false when in a devolved administration" do
          @calculator.business_based = "scotland"
          assert_not @calculator.show?(:grant_funding)
        end

        should "return false when not paying business rates" do
          @calculator.business_rates = "no"
          assert_not @calculator.show?(:grant_funding)
        end

        should "return false when non domestic property not over £15k" do
          @calculator.non_domestic_property = "over_51k"
          assert_not @calculator.show?(:grant_funding)
        end

        should "return false when not in supported business sector" do
          @calculator.sectors = %w[nurseries]
          assert_not @calculator.show?(:grant_funding)
        end
      end

      context "nursery_support" do
        setup do
          @calculator.business_based = "england"
          @calculator.business_rates = "yes"
          @calculator.non_domestic_property = "over_51k"
          @calculator.sectors = %w[nurseries]
        end

        should "return true when criteria met" do
          assert @calculator.show?(:nursery_support)
        end

        should "return false when based in devolved administration" do
          @calculator.business_based = "scotland"
          assert_not @calculator.show?(:nursery_support)
        end

        should "return false when not paying business rates" do
          @calculator.business_rates = "no"
          assert_not @calculator.show?(:nursery_support)
        end

        should "return false when no non domestic property" do
          @calculator.non_domestic_property = "none"
          assert_not @calculator.show?(:nursery_support)
        end

        should "return false when not supported business sector" do
          @calculator.sectors = %w[retail hospitality leisure]
          assert_not @calculator.show?(:nursery_support)
        end
      end

      context "small_business_grant_funding" do
        setup do
          @calculator.business_based = "england"
          @calculator.business_size = "0_to_249"
          @calculator.non_domestic_property = "up_to_15k"
        end

        should "return true when criteria met" do
          assert @calculator.show?(:small_business_grant_funding)
        end

        should "return false when based in devolved administration" do
          @calculator.business_based = "scotland"
          assert_not @calculator.show?(:small_business_grant_funding)
        end

        should "return false when business has over 249 employees" do
          @calculator.business_size = "over_249"
          assert_not @calculator.show?(:small_business_grant_funding)
        end

        should "return false when non domestic property not over £15k" do
          @calculator.non_domestic_property = "over_51k"
          assert_not @calculator.show?(:small_business_grant_funding)
        end
      end

      context "business_loan_scheme" do
        should "return true when annual turnover is £85,000 to 45m" do
          @calculator.annual_turnover = "85k_to_45m"
          assert @calculator.show?(:business_loan_scheme)
        end

        should "return true when annual turnover under £85,000" do
          @calculator.annual_turnover = "under_85k"
          assert @calculator.show?(:business_loan_scheme)
        end

        should "return false when annual turnover not under £85,000 or £85,000 to £45m" do
          @calculator.annual_turnover = "45m_to_500m"
          assert_not @calculator.show?(:business_loan_scheme)
        end
      end

      context "large_business_loan_scheme" do
        should "return true when annual turnover is £45m to 500m" do
          @calculator.annual_turnover = "45m_to_500m"
          assert @calculator.show?(:large_business_loan_scheme)
        end

        should "return false when annual turnover is not £45m to £500m" do
          @calculator.annual_turnover = "500m_and_over"
          assert_not @calculator.show?(:large_business_loan_scheme)
        end
      end
    end
  end
end
