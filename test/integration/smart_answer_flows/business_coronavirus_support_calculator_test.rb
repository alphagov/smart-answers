require_relative "../../test_helper"

module SmartAnswer
  class BusinessCoronavirusSupportFinderCalculatorTest < ActiveSupport::TestCase
    context "england based" do
      setup do
        @calculator = Calculators::BusinessCoronavirusSupportFinderCalculator.new
        @calculator.business_based = "england"
      end

      context "not self-employed" do
        setup do
          @calculator.self_employed = "no"
        end

        should "be eligible for corporate_financing" do
          assert_equal true, @calculator.show?(:corporate_financing)
        end

        should "should be eligible for job retention scheme" do
          assert_equal true, @calculator.show?(:job_retention_scheme)
        end

        context "annual_turnover greater than £45k" do
          setup do
            @calculator.annual_turnover = "over_85k"
          end

          should "be eligible for business_loan_scheme" do
            assert_equal true, @calculator.show?(:business_loan_scheme)
          end

          should "be eligible for business_tax_support" do
            assert_equal true, @calculator.show?(:business_tax_support)
          end
        end

        context "small_medium_enterprise" do
          setup do
            @calculator.business_size = "small_medium_enterprise"
          end

          context "non-domestic property under £15k" do
            setup do
              @calculator.non_domestic_property = "under_15k"
            end

            should "be eligible for small_business_grant_funding" do
              assert_equal true, @calculator.show?(:small_business_grant_funding)
            end
          end

          context "filling a self assessment for July 2020" do
            setup do
              @calculator.self_assessment_july_2020 = "yes"
            end

            should "be eligible for statutory_sick_rebate" do
              assert_equal true, @calculator.show?(:statutory_sick_rebate)
            end
          end
        end
      end

      context "self-employed" do
        setup do
          @calculator.self_employed = "yes"
        end

        should "should not be eligible for job retention scheme" do
          assert_equal false, @calculator.show?(:job_retention_scheme)
        end

        context "and small_medium_enterprise" do
          setup do
            @calculator.business_size = "small_medium_enterprise"
          end

          should "be eligible for self_employed_income_scheme" do
            assert_equal true, @calculator.show?(:self_employed_income_scheme)
          end
        end
      end

      context "annual turnover over £85k" do
        setup do
          @calculator.annual_turnover = "over_85k"
        end

        should "be eiligible for VAT scheme" do
          assert_equal true, @calculator.show?(:vat_scheme)
        end
      end

      context "annual turnover under £85k" do
        setup do
          @calculator.annual_turnover = "under_85k"
        end

        should "not be eligible for VAT scheme" do
          assert_equal false, @calculator.show?(:vat_scheme)
        end
      end

      context "self assessments for July 2020" do
        setup do
          @calculator.self_assessment_july_2020 = "yes"
        end

        should "eligible for self assessment payment deferment" do
          assert_equal true, @calculator.show?(:self_assessment_payments)
        end
      end

      context "no self assessments for July 2020" do
        setup do
          @calculator.self_assessment_july_2020 = "no"
        end

        should "not eligible for self assessment payment deferment" do
          assert_equal false, @calculator.show?(:self_assessment_payments)
        end
      end

      context "in retail, hospitality or leisure sectors" do
        setup do
          @calculator.sectors = %w[retail hospitality leisure]
        end

        context "pays business rates and " do
          setup do
            @calculator.business_rates = "yes"
          end

          context "has non domestic property" do
            setup do
              @calculator.non_domestic_property = "over_51k"
            end

            should "be eligible for business rates scheme" do
              assert_equal true, @calculator.show?(:business_rates)
            end

            context "domestic property value over £15k" do
              setup do
                @calculator.non_domestic_property = "over_15k"
              end
              should "be eligible for grant funding" do
                assert_equal true, @calculator.show?(:grant_funding)
              end
            end
          end
        end
      end

      context "nursery sector, paying business rates, has a non-domestic property" do
        setup do
          @calculator.sectors = %w[nurseries]
          @calculator.non_domestic_property = "over_51k"
          @calculator.business_rates = "yes"
        end

        should "be eligible for nursery support" do
          assert_equal true, @calculator.show?(:nursery_support)
        end
      end
    end
  end
end
