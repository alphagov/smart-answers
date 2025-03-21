require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StatePensionThroughPartnerCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = StatePensionThroughPartnerCalculator.new
    end

    context "#lower_basic_state_pension_rate" do
      should "return the correct amount for 2024/2025" do
        travel_to("2024-06-01") do
          assert_equal @calculator.lower_basic_state_pension_rate, 101.55
        end
      end

      should "return the correct amount for 2025/2026" do
        travel_to("2025-06-01") do
          assert_equal @calculator.lower_basic_state_pension_rate, 105.70
        end
      end
    end

    context "#higher_basic_state_pension_rate" do
      should "return the correct amount for 2024/2025" do
        travel_to("2024-06-01") do
          assert_equal @calculator.higher_basic_state_pension_rate, 169.50
        end
      end

      should "return the correct amount for 2025/2026" do
        travel_to("2025-06-01") do
          assert_equal @calculator.higher_basic_state_pension_rate, 176.45
        end
      end
    end

    context "widow_and_new_pension?" do
      context "you reached pension age before specific date" do
        setup do
          @calculator.when_will_you_reach_pension_age = "your_pension_age_before_specific_date"
        end

        should "be false when widowed" do
          @calculator.marital_status = "widowed"
          assert_not @calculator.widow_and_new_pension?
        end

        should "be false when married" do
          @calculator.marital_status = "married"
          assert_not @calculator.widow_and_new_pension?
        end

        should "be false when divorced" do
          @calculator.marital_status = "divorced"
          assert_not @calculator.widow_and_new_pension?
        end
      end

      context "you reached pension age after specific date" do
        setup do
          @calculator.when_will_you_reach_pension_age = "your_pension_age_after_specific_date"
        end

        should "be true when widowed" do
          @calculator.marital_status = "widowed"
          assert @calculator.widow_and_new_pension?
        end

        should "be false when married" do
          @calculator.marital_status = "married"
          assert_not @calculator.widow_and_new_pension?
        end

        should "be false when divorced" do
          @calculator.marital_status = "divorced"
          assert_not @calculator.widow_and_new_pension?
        end
      end
    end

    context "widow_and_old_pension?" do
      context "you reached pension age before specific date" do
        setup do
          @calculator.when_will_you_reach_pension_age = "your_pension_age_before_specific_date"
        end

        should "be true when widowed" do
          @calculator.marital_status = "widowed"
          assert @calculator.widow_and_old_pension?
        end

        should "be false when married" do
          @calculator.marital_status = "married"
          assert_not @calculator.widow_and_old_pension?
        end

        should "be false when divorced" do
          @calculator.marital_status = "divorced"
          assert_not @calculator.widow_and_old_pension?
        end
      end

      context "you reached pension age after specific date" do
        setup do
          @calculator.when_will_you_reach_pension_age = "your_pension_age_after_specific_date"
        end

        should "be false when widowed" do
          @calculator.marital_status = "widowed"
          assert_not @calculator.widow_and_old_pension?
        end

        should "be false when married" do
          @calculator.marital_status = "married"
          assert_not @calculator.widow_and_old_pension?
        end

        should "be false when divorced" do
          @calculator.marital_status = "divorced"
          assert_not @calculator.widow_and_old_pension?
        end
      end
    end

    context "current_rules_no_additional_pension?" do
      context "when married" do
        setup do
          @calculator.marital_status = "married"
        end

        context "and reached pension age before specific date" do
          setup do
            @calculator.when_will_you_reach_pension_age = "your_pension_age_before_specific_date"
          end

          should "be true when partner reached pension age before specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_before_specific_date"
            assert @calculator.current_rules_no_additional_pension?
          end

          should "be false when partner reached pension age after specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_after_specific_date"
            assert_not @calculator.current_rules_no_additional_pension?
          end
        end

        context "and reached pension age after specific date" do
          setup do
            @calculator.when_will_you_reach_pension_age = "your_pension_age_after_specific_date"
          end

          should "be false when partner reached pension age before specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_before_specific_date"
            assert_not @calculator.current_rules_no_additional_pension?
          end

          should "be false when partner reached pension age after specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_after_specific_date"
            assert_not @calculator.current_rules_no_additional_pension?
          end
        end
      end

      context "when widowed" do
        setup do
          @calculator.marital_status = "widowed"
        end

        context "and reached pension age before specific date" do
          setup do
            @calculator.when_will_you_reach_pension_age = "your_pension_age_before_specific_date"
          end

          should "be false when partner reached pension age before specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_before_specific_date"
            assert_not @calculator.current_rules_no_additional_pension?
          end

          should "be false when partner reached pension age after specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_after_specific_date"
            assert_not @calculator.current_rules_no_additional_pension?
          end
        end

        context "and reached pension age after specific date" do
          setup do
            @calculator.when_will_you_reach_pension_age = "your_pension_age_after_specific_date"
          end

          should "be false when partner reached pension age before specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_before_specific_date"
            assert_not @calculator.current_rules_no_additional_pension?
          end

          should "be false when partner reached pension age after specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_after_specific_date"
            assert_not @calculator.current_rules_no_additional_pension?
          end
        end
      end

      context "when divorced" do
        setup do
          @calculator.marital_status = "divorced"
        end

        context "and reached pension age before specific date" do
          setup do
            @calculator.when_will_you_reach_pension_age = "your_pension_age_before_specific_date"
          end

          should "be false when partner reached pension age before specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_before_specific_date"
            assert_not @calculator.current_rules_no_additional_pension?
          end

          should "be false when partner reached pension age after specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_after_specific_date"
            assert_not @calculator.current_rules_no_additional_pension?
          end
        end

        context "and reached pension age after specific date" do
          setup do
            @calculator.when_will_you_reach_pension_age = "your_pension_age_after_specific_date"
          end

          should "be false when partner reached pension age before specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_before_specific_date"
            assert_not @calculator.current_rules_no_additional_pension?
          end

          should "be false when partner reached pension age after specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_after_specific_date"
            assert_not @calculator.current_rules_no_additional_pension?
          end
        end
      end
    end

    context "current_rules_national_insurance_no_state_pension?" do
      context "when married" do
        setup do
          @calculator.marital_status = "married"
        end

        context "and reached pension age before specific date" do
          setup do
            @calculator.when_will_you_reach_pension_age = "your_pension_age_before_specific_date"
          end

          should "be false when partner reached pension age before specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_before_specific_date"
            assert_not @calculator.current_rules_national_insurance_no_state_pension?
          end

          should "be true when partner reached pension age after specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_after_specific_date"
            assert @calculator.current_rules_national_insurance_no_state_pension?
          end
        end

        context "and reached pension age after specific date" do
          setup do
            @calculator.when_will_you_reach_pension_age = "your_pension_age_after_specific_date"
          end

          should "be false when partner reached pension age before specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_before_specific_date"
            assert_not @calculator.current_rules_national_insurance_no_state_pension?
          end

          should "be false when partner reached pension age after specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_after_specific_date"
            assert_not @calculator.current_rules_national_insurance_no_state_pension?
          end
        end
      end

      context "when widowed" do
        setup do
          @calculator.marital_status = "widowed"
        end

        context "and reached pension age before specific date" do
          setup do
            @calculator.when_will_you_reach_pension_age = "your_pension_age_before_specific_date"
          end

          should "be false when partner reached pension age before specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_before_specific_date"
            assert_not @calculator.current_rules_national_insurance_no_state_pension?
          end

          should "be false when partner reached pension age after specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_after_specific_date"
            assert_not @calculator.current_rules_national_insurance_no_state_pension?
          end
        end

        context "and reached pension age after specific date" do
          setup do
            @calculator.when_will_you_reach_pension_age = "your_pension_age_after_specific_date"
          end

          should "be false when partner reached pension age before specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_before_specific_date"
            assert_not @calculator.current_rules_national_insurance_no_state_pension?
          end

          should "be false when partner reached pension age after specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_after_specific_date"
            assert_not @calculator.current_rules_national_insurance_no_state_pension?
          end
        end
      end

      context "when divorced" do
        setup do
          @calculator.marital_status = "divorced"
        end

        context "and reached pension age before specific date" do
          setup do
            @calculator.when_will_you_reach_pension_age = "your_pension_age_before_specific_date"
          end

          should "be false when partner reached pension age before specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_before_specific_date"
            assert_not @calculator.current_rules_national_insurance_no_state_pension?
          end

          should "be false when partner reached pension age after specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_after_specific_date"
            assert_not @calculator.current_rules_national_insurance_no_state_pension?
          end
        end

        context "and reached pension age after specific date" do
          setup do
            @calculator.when_will_you_reach_pension_age = "your_pension_age_after_specific_date"
          end

          should "be false when partner reached pension age before specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_before_specific_date"
            assert_not @calculator.current_rules_national_insurance_no_state_pension?
          end

          should "be false when partner reached pension age after specific date" do
            @calculator.when_will_your_partner_reach_pension_age = "partner_pension_age_after_specific_date"
            assert_not @calculator.current_rules_national_insurance_no_state_pension?
          end
        end
      end
    end
  end
end
