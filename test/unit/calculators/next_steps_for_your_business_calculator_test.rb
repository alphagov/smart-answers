require_relative "../../test_helper"

module SmartAnswer::Calculators
  class NextStepsForYourBusinessCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = NextStepsForYourBusinessCalculator.new
      @rules = NextStepsForYourBusinessCalculator::RULES
    end

    context "RULES" do
      context "r1" do
        should "return true when registered_for_corp_tax is false" do
          @calculator.registered_for_corp_tax = false
          assert @rules[:r1].call(@calculator)
        end

        should "return false when registered_for_corp_tax is true" do
          @calculator.registered_for_corp_tax = true
          assert_not @rules[:r1].call(@calculator)
        end
      end

      (2..15).each do |index|
        context "r#{index}" do
          should "always return true" do
            assert @rules[:"r#{index}"].call(nil)
          end
        end
      end

      context "r16" do
        should "return true when annual turnover is over 85k" do
          @calculator.annual_turnover_over_85k = "yes"
          assert @rules[:r16].call(@calculator)
        end

        should "return false when annual turnover is not over 85k" do
          @calculator.annual_turnover_over_85k = "no"
          assert_not @rules[:r16].call(@calculator)
        end

        should "return false when unsure if annual turnover is over 85k" do
          @calculator.annual_turnover_over_85k = "not_sure"
          assert_not @rules[:r16].call(@calculator)
        end
      end

      context "r17" do
        should "return false when annual turnover is over 85k" do
          @calculator.annual_turnover_over_85k = "yes"
          assert_not @rules[:r17].call(@calculator)
        end

        should "return false when annual turnover is not over 85k" do
          @calculator.annual_turnover_over_85k = "no"
          assert_not @rules[:r17].call(@calculator)
        end

        should "return true when unsure if annual turnover is over 85k" do
          @calculator.annual_turnover_over_85k = "not_sure"
          assert @rules[:r17].call(@calculator)
        end
      end

      context "r18" do
        should "return false when business is not an employer" do
          @calculator.employer = "no"
          assert_not @rules[:r18].call(@calculator)
        end

        should "return true when business is an employer" do
          @calculator.employer = "yes"
          assert @rules[:r18].call(@calculator)
        end

        should "return true when unsure if business is an employer" do
          @calculator.employer = "not_sure"
          assert @rules[:r18].call(@calculator)
        end

        should "return true when business will be an employer" do
          @calculator.employer = "in_future"
          assert @rules[:r18].call(@calculator)
        end
      end

      context "r19" do
        should "return false when business doesn't need financial support" do
          @calculator.needs_financial_support = "no"
          assert_not @rules[:r19].call(@calculator)
        end

        should "return true when business needs financial support" do
          @calculator.needs_financial_support = "yes"
          assert @rules[:r19].call(@calculator)
        end
      end

      context "r20" do
        should "return false when business doesn't need financial support" do
          @calculator.needs_financial_support = "no"
          assert_not @rules[:r20].call(@calculator)
        end

        should "return true when business needs financial support" do
          @calculator.needs_financial_support = "yes"
          assert @rules[:r20].call(@calculator)
        end
      end

      context "r21" do
        should "return false when business is not an employer" do
          @calculator.employer = "no"
          assert_not @rules[:r21].call(@calculator)
        end

        should "return true when business is an employer" do
          @calculator.employer = "yes"
          assert @rules[:r21].call(@calculator)
        end

        should "return true when unsure if business is an employer" do
          @calculator.employer = "not_sure"
          assert @rules[:r21].call(@calculator)
        end

        should "return true when business will be an employer" do
          @calculator.employer = "in_future"
          assert @rules[:r21].call(@calculator)
        end
      end

      context "r22" do
        should "return true when business has premise at home" do
          @calculator.business_premises = %w[home]
          assert @rules[:r22].call(@calculator)
        end

        should "return false when business doesn't have premise at home" do
          @calculator.business_premises = %w[rented owned]
          assert_not @rules[:r22].call(@calculator)
        end
      end

      context "r23" do
        should "return true when business has rented premise" do
          @calculator.business_premises = %w[rented]
          assert @rules[:r23].call(@calculator)
        end

        should "return false when business doesn't have rented premise" do
          @calculator.business_premises = %w[home owned]
          assert_not @rules[:r23].call(@calculator)
        end
      end

      context "r24" do
        should "return false when business only has premise at home" do
          @calculator.business_premises = %w[home]
          assert_not @rules[:r24].call(@calculator)
        end

        should "return true when business has an owned premise" do
          @calculator.business_premises = %w[home owned]
          assert @rules[:r24].call(@calculator)
        end

        should "return true when business has a rented premise" do
          @calculator.business_premises = %w[home rented]
          assert @rules[:r24].call(@calculator)
        end

        should "return true when business has no premise" do
          @calculator.business_premises = %w[none]
          assert @rules[:r24].call(@calculator)
        end
      end

      context "r25" do
        should "return false when business only has premise at home" do
          @calculator.business_premises = %w[home]
          assert_not @rules[:r25].call(@calculator)
        end

        should "return true when business has an owned premise" do
          @calculator.business_premises = %w[home owned]
          assert @rules[:r25].call(@calculator)
        end

        should "return true when business has a rented premise" do
          @calculator.business_premises = %w[home rented]
          assert @rules[:r25].call(@calculator)
        end

        should "return true when business has no premise" do
          @calculator.business_premises = %w[none]
          assert @rules[:r25].call(@calculator)
        end
      end

      context "r26" do
        should "return true when business is importing goods" do
          @calculator.activities = %w[import_goods]
          assert @rules[:r26].call(@calculator)
        end

        should "return false when business is not importing goods" do
          @calculator.activities = %w[export_goods_or_services]
          assert_not @rules[:r26].call(@calculator)
        end
      end

      context "r27" do
        should "return true when business is exporting goods or services" do
          @calculator.activities = %w[export_goods_or_services]
          assert @rules[:r27].call(@calculator)
        end

        should "return false when business is not exporting goods or services" do
          @calculator.activities = %w[import_goods]
          assert_not @rules[:r27].call(@calculator)
        end
      end

      context "r28" do
        should "return true when annual turnover is over 85k" do
          @calculator.annual_turnover_over_85k = "yes"
          assert @rules[:r28].call(@calculator)
        end

        should "return false when annual turnover is not over 85k" do
          @calculator.annual_turnover_over_85k = "no"
          assert_not @rules[:r28].call(@calculator)
        end

        should "return false when unsure if annual turnover is over 85k" do
          @calculator.annual_turnover_over_85k = "not_sure"
          assert_not @rules[:r28].call(@calculator)
        end
      end

      context "r29" do
        should "return false when annual turnover is over 85k" do
          @calculator.annual_turnover_over_85k = "yes"
          assert_not @rules[:r29].call(@calculator)
        end

        should "return true when annual turnover is not over 85k" do
          @calculator.annual_turnover_over_85k = "no"
          assert @rules[:r29].call(@calculator)
        end

        should "return false when unsure if annual turnover is over 85k" do
          @calculator.annual_turnover_over_85k = "not_sure"
          assert_not @rules[:r29].call(@calculator)
        end
      end

      context "r30" do
        should "return true when business is exporting goods or services" do
          @calculator.activities = %w[export_goods_or_services]
          assert @rules[:r30].call(@calculator)
        end

        should "return false when business is not exporting goods or services" do
          @calculator.activities = %w[import_goods]
          assert_not @rules[:r30].call(@calculator)
        end
      end
    end
  end
end
