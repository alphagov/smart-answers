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

      context "christmas_pub_payment" do
        setup do
          @calculator.business_based = "england"
          @calculator.sectors = %w[retail_hospitality_or_leisure]
        end

        should "return true when criteria met" do
          assert @calculator.show?(:retail_hospitality_leisure_business_rates)
        end

        should "return false when in a devolved admininstration" do
          @calculator.business_based = "scotland"
          assert_not @calculator.show?(:retail_hospitality_leisure_business_rates)
        end

        should "return false when not supported business sectors" do
          @calculator.sectors = %w[none]
          assert_not @calculator.show?(:retail_hospitality_leisure_business_rates)
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

        should "return true when annual turnover is £500m and over" do
          @calculator.annual_turnover = "500m_and_over"
          assert @calculator.show?(:large_business_loan_scheme)
        end

        should "return false when annual turnover is not £45m and over" do
          @calculator.annual_turnover = "85k_to_45m"
          assert_not @calculator.show?(:large_business_loan_scheme)
        end
      end

      context "bounce_back_loan" do
        should "return true when annual turnover is £85,000 to 45m" do
          @calculator.annual_turnover = "85k_to_45m"
          assert @calculator.show?(:bounce_back_loan)
        end

        should "return true when annual turnover under £85,000" do
          @calculator.annual_turnover = "under_85k"
          assert @calculator.show?(:bounce_back_loan)
        end

        should "return false when annual turnover not under £85,000 or £85,000 to £45m" do
          @calculator.annual_turnover = "45m_to_500m"
          assert_not @calculator.show?(:bounce_back_loan)
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

      context "lrsg_closed_addendum" do
        should "return true when business closed by national restrictions and based in england" do
          @calculator.business_based = "england"
          @calculator.closed_by_restrictions << "national"
          assert @calculator.show?(:lrsg_closed_addendum)
        end

        should "return false when business not based in england" do
          @calculator.business_based = "scotland"
          @calculator.closed_by_restrictions << "national"
          assert_not @calculator.show?(:lrsg_closed_addendum)
        end

        should "return false when business not closed by national restrictions" do
          @calculator.business_based = "england"
          @calculator.closed_by_restrictions = []
          assert_not @calculator.show?(:lrsg_closed_addendum)
        end
      end

      context "lrsg_closed" do
        should "return true when business closed by local restrictions and based in england" do
          @calculator.business_based = "england"
          @calculator.closed_by_restrictions << "local"
          assert @calculator.show?(:lrsg_closed)
        end

        should "return false when business not based in england" do
          @calculator.business_based = "scotland"
          @calculator.closed_by_restrictions << "local"
          assert_not @calculator.show?(:lrsg_closed)
        end

        should "return false when business not closed by local restrictions" do
          @calculator.business_based = "england"
          @calculator.closed_by_restrictions = []
          assert_not @calculator.show?(:lrsg_closed)
        end
      end

      context "lrsg_open" do
        should "return true when business not closed by sector restrictions and based in england" do
          @calculator.business_based = "england"
          @calculator.sectors = []
          assert @calculator.show?(:lrsg_open)
        end

        should "return false when business not based in england" do
          @calculator.business_based = "scotland"
          @calculator.sectors = []
          assert_not @calculator.show?(:lrsg_open)
        end

        should "return false when business is closed by local restrictions" do
          @calculator.business_based = "england"
          @calculator.sectors = %w[nightclubs_or_adult_entertainment]
          assert_not @calculator.show?(:lrsg_open)
        end
      end

      context "lrsg_sector" do
        should "return true when business closed by sector restrictions and based in england" do
          @calculator.business_based = "england"
          @calculator.sectors = %w[nightclubs_or_adult_entertainment]
          assert @calculator.show?(:lrsg_sector)
        end

        should "return false when business not based in england" do
          @calculator.business_based = "scotland"
          @calculator.sectors = %w[nightclubs_or_adult_entertainment]
          assert_not @calculator.show?(:lrsg_sector)
        end

        should "return false when business not closed by local restrictions" do
          @calculator.business_based = "england"
          @calculator.sectors = []
          assert_not @calculator.show?(:lrsg_sector)
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
    end
  end
end
