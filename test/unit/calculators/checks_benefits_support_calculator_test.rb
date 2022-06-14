require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CheckBenefitsSupportCalculatorTest < ActiveSupport::TestCase
    context CheckBenefitsSupportCalculator do
      context "#benefits_for_outcome" do
        should "return array of eligible and non-conditional benefits" do
          stubbed_benefit_data = {
            "benefits" => [{ "title" => "eligible_benefit",
                             "condition" => "eligible_for_employment_and_support_allowance?" },
                           { "title" => "unconditional_benefit" },
                           { "title" => "ineligile_benefit",
                             "condition" => "eligible_for_jobseekers_allowance?" }],
          }
          expected_benefits = [
            { "title" => "eligible_benefit",
              "condition" => "eligible_for_employment_and_support_allowance?" },
            { "title" => "unconditional_benefit" },
          ]

          YAML.stubs(:load_file).returns(stubbed_benefit_data)
          calculator = CheckBenefitsSupportCalculator.new
          calculator.stubs(:eligible_for_employment_and_support_allowance?).returns(true)
          calculator.stubs(:eligible_for_jobseekers_allowance?).returns(false)

          assert_equal calculator.benefits_for_outcome, expected_benefits
        end
      end

      context "#number_of_benefits" do
        should "return the number of benefits for outcome" do
          number_of_results = rand(1..10)
          CheckBenefitsSupportCalculator.any_instance
            .stubs(:benefits_for_outcome).returns(Array.new(number_of_results, {}))
          calculator = CheckBenefitsSupportCalculator.new
          assert_equal calculator.number_of_benefits, number_of_results
        end
      end

      context "#eligible_for_employment_and_support_allowance?" do
        context "when eligible" do
          should "be true if country is not NI, under state pension age, working under 16 hours, with a health issue that affects work" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              %w[no yes_under_16_hours_per_week].each do |working_hours|
                calculator.are_you_working = working_hours
                calculator.disability_or_health_condition = "yes"
                %w[yes_unable_to_work yes_limits_work].each do |affecting_work|
                  calculator.disability_affecting_work = affecting_work
                  assert calculator.eligible_for_employment_and_support_allowance?
                end
              end
            end
          end
        end

        context "when ineligible" do
          should "be false if country is NI" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "yes"
            %w[yes_unable_to_work yes_limits_work].each do |affecting_work|
              calculator.disability_affecting_work = affecting_work
              assert_not calculator.eligible_for_employment_and_support_allowance?
            end
          end

          should "be false if country is not NI, under state pension age, working under 16 hours, with a health condition that DOES NOT affect work" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              %w[no yes_under_16_hours_per_week].each do |working_hours|
                calculator.are_you_working = working_hours
                calculator.disability_or_health_condition = "yes"
                calculator.disability_affecting_work = "no"
                assert_not calculator.eligible_for_employment_and_support_allowance?
              end
            end
          end

          should "be false if country is not NI, OVER state pension age, working under 16 hours, with a health condition that affects work" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "yes"
              %w[no yes_under_16_hours_per_week].each do |working_hours|
                calculator.are_you_working = working_hours
                calculator.disability_or_health_condition = "yes"
                calculator.disability_affecting_work = "yes_limits_work"
                assert_not calculator.eligible_for_employment_and_support_allowance?
              end
            end
          end

          should "be false if country is not NI, under state pension age, working under 16 hours, WITHOUT a health condition" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              %w[no yes_under_16_hours_per_week].each do |working_hours|
                calculator.are_you_working = working_hours
                calculator.disability_or_health_condition = "no"
                assert_not calculator.eligible_for_employment_and_support_allowance?
              end
            end
          end

          should "be false if country is not NI, under state pension age, working over 16 hours, with a health issue that affects work" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              calculator.are_you_working = "yes_over_16_hours_per_week"
              calculator.disability_or_health_condition = "yes"
              %w[yes_unable_to_work yes_limits_work].each do |affecting_work|
                calculator.disability_affecting_work = affecting_work
                assert_not calculator.eligible_for_employment_and_support_allowance?
              end
            end
          end
        end
      end

      context "#eligible_for_employment_and_support_allowance_northern_ireland?" do
        context "when eligible" do
          should "be true if country is NI, under state pension age, working under 16 hours, with a health issue that affects work" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.disability_or_health_condition = "yes"
              %w[yes_unable_to_work yes_limits_work].each do |affecting_work|
                calculator.disability_affecting_work = affecting_work
                assert calculator.eligible_for_employment_and_support_allowance_northern_ireland?
              end
            end
          end
        end

        context "when ineligible" do
          should "be false if country is not NI" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              %w[no yes_under_16_hours_per_week].each do |working_hours|
                calculator.are_you_working = working_hours
                calculator.disability_or_health_condition = "yes"
                %w[yes_unable_to_work yes_limits_work].each do |affecting_work|
                  calculator.disability_affecting_work = affecting_work
                  assert_not calculator.eligible_for_employment_and_support_allowance_northern_ireland?
                end
              end
            end
          end

          should "be false if country is NI, under state pension age, working under 16 hours per week, with a health condition that DOES NOT affect work" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.disability_or_health_condition = "yes"
              calculator.disability_affecting_work = "no"
              assert_not calculator.eligible_for_employment_and_support_allowance_northern_ireland?
            end
          end

          should "be false if country is NI, under state pension age, working OVER 16 hours per week, with a health condition that affects work" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            calculator.are_you_working = "yes_over_16_hours_per_week"
            calculator.disability_or_health_condition = "yes"
            %w[yes_unable_to_work yes_limits_work].each do |affecting_work|
              calculator.disability_affecting_work = affecting_work
              assert_not calculator.eligible_for_employment_and_support_allowance_northern_ireland?
            end
          end

          should "be false if country is NI, OVER state pension age, working under 16 hours, with a health condition that affects work" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "yes"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.disability_or_health_condition = "yes"
              calculator.disability_affecting_work = "no"
              assert_not calculator.eligible_for_employment_and_support_allowance_northern_ireland?
            end
          end

          should "be false if country is NI, under state pension age, WITHOUT a health condition" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.disability_or_health_condition = "no"
              assert_not calculator.eligible_for_employment_and_support_allowance_northern_ireland?
            end
          end
        end
      end

      context "#eligible_for_jobseekers_allowance?" do
        context "when eligible" do
          should "be true if country is not NI, under pension age, working under 16 hours" do
            calculator = CheckBenefitsSupportCalculator.new
            %w[england wales scotland].each do |country|
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              %w[no yes_under_16_hours_per_week].each do |working_hours|
                calculator.are_you_working = working_hours
                assert calculator.eligible_for_jobseekers_allowance?
              end
            end
          end

          should "be true if country is not NI, under pension age, working under 16 hours and a health condition does not prevent work" do
            calculator = CheckBenefitsSupportCalculator.new
            %w[england wales scotland].each do |country|
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              %w[no yes_under_16_hours_per_week].each do |working_hours|
                calculator.are_you_working = working_hours
                %w[no yes_limits_work].each do |affecting_work|
                  calculator.disability_affecting_work = affecting_work
                  assert calculator.eligible_for_jobseekers_allowance?
                end
              end
            end
          end
        end

        context "when ineligible" do
          should "be false if country is NI, under pension age, working under 16 hours" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              assert_not calculator.eligible_for_jobseekers_allowance?
            end
          end

          should "be false if country is NI, under pension age, working under 16 hours and a health condition does not prevent work" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              assert_not calculator.eligible_for_jobseekers_allowance?
              %w[no yes_limits_work].each do |affecting_work|
                calculator.disability_affecting_work = affecting_work
                assert_not calculator.eligible_for_jobseekers_allowance?
              end
            end
          end

          should "be false if country is not NI, OVER state pension age" do
            calculator = CheckBenefitsSupportCalculator.new
            %w[england wales scotland].each do |country|
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "yes"
              %w[no yes_under_16_hours_per_week].each do |working_hours|
                calculator.are_you_working = working_hours
                %w[no yes_limits_work].each do |affecting_work|
                  calculator.disability_affecting_work = affecting_work
                  assert_not calculator.eligible_for_jobseekers_allowance?
                end
              end
            end
          end

          should "be false if country is not NI, under state pension age and working OVER 16 hours" do
            calculator = CheckBenefitsSupportCalculator.new
            %w[england wales scotland].each do |country|
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "yes"
              calculator.are_you_working = "yes_over_16_hours_per_week"
              %w[no yes_limits_work].each do |affecting_work|
                calculator.disability_affecting_work = affecting_work
                assert_not calculator.eligible_for_jobseekers_allowance?
              end
            end
          end

          should "be false if country is not NI, under state pension age, working under 16 hours, and with a health condition that prevents work" do
            calculator = CheckBenefitsSupportCalculator.new
            %w[england wales scotland].each do |country|
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "yes"
              %w[no yes_under_16_hours_per_week].each do |working_hours|
                calculator.are_you_working = working_hours
                calculator.disability_affecting_work = "yes_unable_to_work"
                assert_not calculator.eligible_for_jobseekers_allowance?
              end
            end
          end
        end
      end

      context "#eligible_for_jobseekers_allowance_northern_ireland?" do
        context "when eligible" do
          should "be true if country is NI, under state pension age, working under 16 hours, and a health condition that does not prevent work" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              %w[no yes_limits_work].each do |affecting_work|
                calculator.disability_affecting_work = affecting_work
                assert calculator.eligible_for_jobseekers_allowance_northern_ireland?
              end
            end
          end
        end

        context "when ineligible" do
          should "be false if country is NI, OVER state pension age, working under 16 hours, and a health condition that does not prevent work" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "yes"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              %w[no yes_limits_work].each do |affecting_work|
                calculator.disability_affecting_work = affecting_work
                assert_not calculator.eligible_for_jobseekers_allowance_northern_ireland?
              end
            end
          end

          should "be false if country is NI, under state pension age, working OVER 16 hours, and a health condition that does not prevent work" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            calculator.are_you_working = "yes_over_16_hours_per_week"
            %w[no yes_limits_work].each do |affecting_work|
              calculator.disability_affecting_work = affecting_work
              assert_not calculator.eligible_for_jobseekers_allowance_northern_ireland?
            end
          end

          should "be false if country is NI, under state pension age, working under 16 hours, and a health condition that prevents work" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.disability_affecting_work = "yes_unable_to_work"
              assert_not calculator.eligible_for_jobseekers_allowance_northern_ireland?
            end
          end

          should "be false if the country is not NI" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              %w[no yes_under_16_hours_per_week].each do |working_hours|
                calculator.are_you_working = working_hours
                %w[no yes_limits_work].each do |affecting_work|
                  calculator.disability_affecting_work = affecting_work
                  assert_not calculator.eligible_for_jobseekers_allowance_northern_ireland?
                end
              end
            end
          end
        end
      end

      context "#eligible_for_pension_credit?" do
        context "when eligible" do
          should "be true if country is not NI and over state pension age" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "yes"
              assert calculator.eligible_for_pension_credit?
            end
          end
        end

        context "when ineligible" do
          should "be false if country is not NI and UNDER state pension age" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              assert_not calculator.eligible_for_pension_credit?
            end
          end

          should "be false if country is NI " do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "yes"
            assert_not calculator.eligible_for_pension_credit?
          end
        end
      end

      context "#eligible_for_pension_credit_northern_ireland?" do
        context "when eligible" do
          should "be true if country is NI and over state pension age" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "yes"
            assert calculator.eligible_for_pension_credit_northern_ireland?
          end
        end

        context "when ineligible" do
          should "be false if country is NI and UNDER state pension age" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            assert_not calculator.eligible_for_pension_credit_northern_ireland?
          end

          should "be false if country is not NI" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "yes"
              assert_not calculator.eligible_for_pension_credit_northern_ireland?
            end
          end
        end
      end

      context "#eligible_for_access_to_work?" do
        context "when eligible" do
          should "return true if country is not NI, with a health condition that does not prevent work" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.disability_or_health_condition = "yes"
              %w[no yes_limits_work].each do |affecting_work|
                calculator.disability_affecting_work = affecting_work
                assert calculator.eligible_for_access_to_work?
              end
            end
          end
        end

        context "when ineligible" do
          should "return false if country is NI" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.disability_or_health_condition = "yes"
            %w[no yes_limits_work].each do |affecting_work|
              calculator.disability_affecting_work = affecting_work
              assert_not calculator.eligible_for_access_to_work?
            end
          end

          should "return false if country is not NI, without a health condition" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.disability_or_health_condition = "no"
              assert_not calculator.eligible_for_access_to_work?
            end
          end

          should "return false if country is not NI, with a health condition that DOES prevent work" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.disability_or_health_condition = "yes"
              calculator.disability_affecting_work = "yes_unable_to_work"
              assert_not calculator.eligible_for_access_to_work?
            end
          end
        end
      end

      context "#eligible_for_access_to_work_northern_ireland?" do
        context "when eligible" do
          should "be true if country is NI, with healh condition that does not prevent work" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.disability_or_health_condition = "yes"
            %w[no yes_limits_work].each do |affecting_work|
              calculator.disability_affecting_work = affecting_work
              assert calculator.eligible_for_access_to_work_northern_ireland?
            end
          end
        end

        context "when ineligible" do
          should "be false if the country is not NI, with health condition that does not prevent work" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.disability_or_health_condition = "yes"
              %w[no yes_limits_work].each do |affecting_work|
                calculator.disability_affecting_work = affecting_work
                assert_not calculator.eligible_for_access_to_work_northern_ireland?
              end
            end
          end

          should "return false if country is NI, without a health condition" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.disability_or_health_condition = "no"
            assert_not calculator.eligible_for_access_to_work_northern_ireland?
          end

          should "return false if country is NI, with a health condition that DOES prevent work" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.disability_or_health_condition = "yes"
            calculator.disability_affecting_work = "yes_unable_to_work"
            assert_not calculator.eligible_for_access_to_work_northern_ireland?
          end
        end
      end

      context "#eligible_for_universal_credit?" do
        context "when eligible" do
          should "be true if country is not NI, under state pension age with under 16000 assets" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              calculator.assets_and_savings = "under_16000"

              assert calculator.eligible_for_universal_credit?
            end
          end
        end

        context "when ineligible" do
          should "be false if country is NI, under state pension age with under 16000 in assets" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            calculator.assets_and_savings = "over_16000"
            assert_not calculator.eligible_for_universal_credit?
          end
        end

        should "be false if country is not NI, OVER state pension age with under 16000 in assets" do
          %w[england wales scotland].each do |country|
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = country
            calculator.over_state_pension_age = "yes"
            calculator.assets_and_savings = "under_16000"
            assert_not calculator.eligible_for_universal_credit?
          end
        end

        should "be false if country is not NI, under state pension age with OVER 16000 in assets" do
          %w[england wales scotland].each do |country|
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = country
            calculator.over_state_pension_age = "no"
            calculator.assets_and_savings = "over_16000"
            assert_not calculator.eligible_for_universal_credit?
          end
        end
      end

      context "#eligible_for_universal_credit_ni?" do
        context "when eligible" do
          should "be true if country is NI, under state pension and under 16000 assets" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            calculator.assets_and_savings = "under_16000"
            assert calculator.eligible_for_universal_credit_ni?
          end
        end

        context "when ineligible" do
          should "be false if country in not NI, under state pension age and under 16000 assets" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              calculator.assets_and_savings = "over_16000"
              assert_not calculator.eligible_for_universal_credit_ni?
            end
          end

          should "be false if country is NI, over state pension age and under 16000 assets" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "yes"
            calculator.assets_and_savings = "under_16000"
            assert_not calculator.eligible_for_universal_credit_ni?
          end

          should "be false if country is NI, under state pension age and over 16000 assets" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            calculator.assets_and_savings = "over_16000"
            assert_not calculator.eligible_for_universal_credit_ni?
          end
        end
      end

      context "#eligible_for_housing_benefit?" do
        context "when eligible" do
          should "be true if country is England or Wales and over state pension age" do
            %w[england wales].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "yes"
              assert calculator.eligible_for_housing_benefit?
            end
          end
        end

        context "when ineligible" do
          should "be false if country is England or Wales and UNDER state pension age" do
            calculator = CheckBenefitsSupportCalculator.new
            %w[england wales].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              assert_not calculator.eligible_for_housing_benefit?
            end
          end

          should "be false if country is not England or Wales" do
            calculator = CheckBenefitsSupportCalculator.new
            %w[scotland northern-ireland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              %w[yes no].each do |pension_age|
                calculator.over_state_pension_age = pension_age
                assert_not calculator.eligible_for_housing_benefit?
              end
            end
          end
        end
      end

      context "#eligible_for_housing_benefit_scotland?" do
        context "when eligible" do
          should "be true if country is Scotland and over state pension age" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "scotland"
            calculator.over_state_pension_age = "yes"
            assert calculator.eligible_for_housing_benefit_scotland?
          end
        end

        context "when false" do
          should "be false if country is not Scotland" do
            %w[england wales northern-ireland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "yes"
              assert_not calculator.eligible_for_housing_benefit_scotland?
            end
          end

          should "be false if country is Scotland and under state pension age" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "scotland"
            calculator.over_state_pension_age = "no"
            assert_not calculator.eligible_for_housing_benefit_scotland?
          end
        end
      end

      context "#eligible_for_housing_benefit_northern_ireland?" do
        context "when eligible" do
          should "be true if country is Northern Ireland and over state pension age" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "yes"
            assert calculator.eligible_for_housing_benefit_northern_ireland?
          end
        end

        context "when ineligible" do
          should "be false if country is not Northern Ireland" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "yes"
              assert_not calculator.eligible_for_housing_benefit_northern_ireland?
            end
          end

          should "be false if country is Northern Ireland and under state pension age" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            assert_not calculator.eligible_for_housing_benefit_northern_ireland?
          end
        end
      end

      context "#eligible_for_tax_free_childcare?" do
        context "when eligible" do
          should "be true if working, with children between 1 and 11" do
            calculator = CheckBenefitsSupportCalculator.new
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.children_living_with_you = "yes"
              %w[1_or_under 2 3_to_4 5_to_11].each do |age|
                calculator.age_of_children = age
                assert calculator.eligible_for_tax_free_childcare?
              end
            end
          end

          should "be true if working, with a disabled child and children between 1 and 17" do
            calculator = CheckBenefitsSupportCalculator.new
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.children_living_with_you = "yes"
              calculator.children_with_disability = "yes"
              %w[1_or_under 2 3_to_4 5_to_11 12_to_15 16_to_17].each do |age|
                calculator.age_of_children = age
                assert calculator.eligible_for_tax_free_childcare?
              end
            end
          end
        end

        context "when ineligible" do
          should "be false if not working with children between 1 and 11" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.are_you_working = "no"
            %w[1_or_under 2 3_to_4 5_to_11].each do |age|
              calculator.age_of_children = age
              assert_not calculator.eligible_for_tax_free_childcare?
            end
          end

          should "be false if working with children aged between 12 and 19" do
            calculator = CheckBenefitsSupportCalculator.new
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.children_living_with_you = "yes"
              %w[12_to_15 16_to_17 18_to_19].each do |age|
                calculator.age_of_children = age
                assert_not calculator.eligible_for_tax_free_childcare?
              end
            end
          end

          should "be false if working without children" do
            calculator = CheckBenefitsSupportCalculator.new
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.children_living_with_you = "no"
              assert_not calculator.eligible_for_tax_free_childcare?
            end
          end

          should "be false if working with a disabled child and children aged 18 to 19" do
            calculator = CheckBenefitsSupportCalculator.new
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.children_living_with_you = "yes"
              calculator.children_with_disability = "yes"
              calculator.age_of_children = "18_to_19"
              assert_not calculator.eligible_for_tax_free_childcare?
            end
          end
        end
      end

      context "#eligible_for_free_childcare_2yr_olds?" do
        context "when eligible" do
          should "be true if country is England or Wales, with a child aged 2" do
            %w[england wales].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.children_living_with_you = "yes"
              calculator.age_of_children = "2"
              assert calculator.eligible_for_free_childcare_2yr_olds?
            end
          end
        end

        context "when ineligible" do
          should "be false if country is England or Wales with a child that is not 2" do
            %w[england wales].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.children_living_with_you = "yes"
              calculator.age_of_children = "1,3_to_4"
              assert_not calculator.eligible_for_free_childcare_2yr_olds?
            end
          end

          should "be false if country is Scotland or Northern Ireland with a child aged 2" do
            %w[scotland northern-ireland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.age_of_children = "2"
              assert_not calculator.eligible_for_free_childcare_2yr_olds?
            end
          end
        end
      end

      context "#eligible_for_childcare_3_4yr_olds_wales??" do
        context "when eligible" do
          should "be true if country is Wales, working over 16 hours with child aged 3 to 4" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "wales"
            calculator.are_you_working = "yes_over_16_hours_per_week"
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "3_to_4"
            assert calculator.eligible_for_childcare_3_4yr_olds_wales?
          end
        end

        context "when ineligible" do
          should "be false if country is not Wales, working over 16 hours with child aged 3 to 4" do
            %w[england scotland northern-ireland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.are_you_working = "yes_over_16_hours_per_week"
              calculator.children_living_with_you = "yes"
              calculator.age_of_children = "3_to_4"
              assert_not calculator.eligible_for_childcare_3_4yr_olds_wales?
            end
          end

          should "be false if country is Wales working under 16 hours with child aged 3 to 4" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "wales"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.children_living_with_you = "yes"
              calculator.age_of_children = "3_to_4"
              assert_not calculator.eligible_for_childcare_3_4yr_olds_wales?
            end
          end

          should "be false if country is Wales working over 16 hours without child aged 3 to 4" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "wales"
            calculator.are_you_working = "yes_over_16_hours_per_week"
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "1,5_to_11"
            assert_not calculator.eligible_for_childcare_3_4yr_olds_wales?
          end
        end
      end

      context "#eligible_for_15hrs_free_childcare_3_4yr_olds?" do
        context "when eligible" do
          should "be true if country is England, with child aged 3 to 4" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "england"
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "1,3_to_4"
            assert calculator.eligible_for_15hrs_free_childcare_3_4yr_olds?
          end
        end

        context "when ineligible" do
          should "be false if country is not England with child aged 3 to 4" do
            %w[scotland wales northern-ireland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.children_living_with_you = "yes"
              calculator.age_of_children = "1,3_to_4"
              assert_not calculator.eligible_for_15hrs_free_childcare_3_4yr_olds?
            end
          end

          should "be false if country is England without children" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "england"
            calculator.children_living_with_you = "no"
            assert_not calculator.eligible_for_15hrs_free_childcare_3_4yr_olds?
          end

          should "be false if country is England with child not aged 3 to 4" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "england"
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "1,5_to_11"
            assert_not calculator.eligible_for_15hrs_free_childcare_3_4yr_olds?
          end
        end
      end

      context "#eligible_for_30hrs_free_childcare_3_4yrs?" do
        context "when eligible" do
          should "be true if country is England, working, with child aged 3 to 4" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "england"
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.children_living_with_you = "yes"
              calculator.age_of_children = "3_to_4"
              assert calculator.eligible_for_30hrs_free_childcare_3_4yrs?
            end
          end
        end

        context "when ineligible" do
          should "be false if country is England, working, with child not aged 3 to 4" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "england"
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.children_living_with_you = "yes"
              calculator.age_of_children = "1,5_to_11"
              assert_not calculator.eligible_for_30hrs_free_childcare_3_4yrs?
            end
          end

          should "be false if country is England, not working, with child aged 3 to 4" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "england"
            calculator.are_you_working = "no"
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "3_to_4"
            assert_not calculator.eligible_for_30hrs_free_childcare_3_4yrs?
          end

          should "be false if country is not England, working, with child aged 3 to 4" do
            %w[wales northern-ireland scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
                calculator.are_you_working = working_hours
                calculator.children_living_with_you = "yes"
                calculator.age_of_children = "3_to_4"
                assert_not calculator.eligible_for_30hrs_free_childcare_3_4yrs?
              end
            end
          end
        end
      end

      context "#eligible_for_funded_early_learning_and_childcare?" do
        context "when eligible" do
          should "be true if country is Scotland, with child aged 2 or 3 to 4" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "scotland"
            calculator.children_living_with_you = "yes"
            %w[2 3_to_4].each do |age|
              calculator.age_of_children = age
              assert calculator.eligible_for_funded_early_learning_and_childcare?
            end
          end
        end

        context "when ineligible" do
          should "be false if country is Scotland, with child not aged 2 or 3 to 4" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "scotland"
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "5_to_11"
            assert_not calculator.eligible_for_funded_early_learning_and_childcare?
          end

          should "be false is country is not Scotland with child aged 2 or 3 to 4" do
            %w[england wales northern-ireland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.children_living_with_you = "yes"
              %w[2 3_to_4].each do |age|
                calculator.age_of_children = age
                assert_not calculator.eligible_for_funded_early_learning_and_childcare?
              end
            end
          end
        end
      end

      context "#eligible_for_child_benefit?" do
        context "when eligible" do
          should "be true if living with child" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.children_living_with_you = "yes"
            assert calculator.eligible_for_child_benefit?
          end
        end

        context "when ineligible" do
          should "be false if not living with child" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.children_living_with_you = "no"
            assert_not calculator.eligible_for_child_benefit?
          end
        end
      end

      context "#eligible_for_disability_living_allowance_for_children?" do
        context "when eligible" do
          should "be true if country is not Scotland, living with child with disability aged under 15" do
            %w[england wales northern-ireland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.children_living_with_you = "yes"
              calculator.children_with_disability = "yes"
              %w[1_or_under 2 3_to_4 5_to_11 12_to_15].each do |age|
                calculator.age_of_children = age
                assert calculator.eligible_for_disability_living_allowance_for_children?
              end
            end
          end
        end

        context "when ineligible" do
          should "be false if country is Scotland, living with child with disability aged under 15" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "scotland"
            calculator.children_living_with_you = "yes"
            calculator.children_with_disability = "yes"
            %w[1_or_under 2 3_to_4 5_to_11 12_to_15].each do |age|
              calculator.age_of_children = age
              assert_not calculator.eligible_for_disability_living_allowance_for_children?
            end
          end

          should "be false if country is not Scotland, living with child with disability aged 18 to 19" do
            %w[england wales northern-ireland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.children_living_with_you = "yes"
              calculator.children_with_disability = "yes"
              calculator.age_of_children = "18_to_19"
              assert_not calculator.eligible_for_disability_living_allowance_for_children?
            end
          end

          should "be false if country is not Scotland, living with child WITHOUT disability aged under 15" do
            %w[england wales northern-ireland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.children_living_with_you = "yes"
              calculator.children_with_disability = "no"
              %w[1_or_under 2 3_to_4 5_to_11 12_to_15].each do |age|
                calculator.age_of_children = age
                assert_not calculator.eligible_for_disability_living_allowance_for_children?
              end
            end
          end
        end
      end

      context "#eligible_for_child_disability_payment_scotland?" do
        should "return true if eligible for Child Disability Payment Scotland" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "scotland"
          calculator.children_living_with_you = "yes"
          calculator.children_with_disability = "yes"
          %w[1_or_under 2 3_to_4 5_to_11 12_to_15].each do |age|
            calculator.age_of_children = age
            assert calculator.eligible_for_child_disability_payment_scotland?
          end
        end

        should "return false if not eligible for Child Disability Payment Scotland" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "wales"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "1_or_under"
          calculator.children_with_disability = "yes"
          assert_not calculator.eligible_for_child_disability_payment_scotland?

          calculator.where_do_you_live = "scotland"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "1_or_under"
          calculator.children_with_disability = "no"
          assert_not calculator.eligible_for_child_disability_payment_scotland?
        end
      end

      context "#eligible_for_carers_allowance?" do
        should "return true if eligible for Carer's Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.carer_disability_or_health_condition = "yes"
          assert calculator.eligible_for_carers_allowance?
        end

        should "return false if not eligible for Carer's Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.carer_disability_or_health_condition = "no"
          assert_not calculator.eligible_for_carers_allowance?
        end
      end

      context "#eligible_for_personal_independence_payment?" do
        context "when eligible" do
          should "be true if country is not NI, under state pension age, without health condition and with child aged 16 to 19 with a health condition" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              calculator.disability_or_health_condition = "no"
              calculator.children_living_with_you = "yes"
              %w[16_to_17 18_to_19].each do |age|
                calculator.age_of_children = age
                calculator.children_with_disability = "yes"
                assert calculator.eligible_for_personal_independence_payment?
              end
            end
          end

          should "be true if country is not NI, under state pension age and with a health condition" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              calculator.disability_or_health_condition = "yes"
              assert calculator.eligible_for_personal_independence_payment?
            end
          end
        end

        context "when ineligible" do
          should "be false if county is NI, under state pension age, without health condition and with child aged 16 to 19" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "no"
            calculator.children_living_with_you = "yes"
            %w[16_to_17 18_to_19].each do |age|
              calculator.age_of_children = age
              assert_not calculator.eligible_for_personal_independence_payment?
            end
          end

          should "be false if country is NI, under state pension age and with a health condition" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "yes"
            assert_not calculator.eligible_for_personal_independence_payment?
          end
        end

        should "be false if country is not NI, OVER state pension age, without health condition and with child aged 16 to 19" do
          %w[england wales scotland].each do |country|
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = country
            calculator.over_state_pension_age = "yes"
            calculator.disability_or_health_condition = "no"
            calculator.children_living_with_you = "yes"
            %w[16_to_17 18_to_19].each do |age|
              calculator.age_of_children = age
              assert_not calculator.eligible_for_personal_independence_payment?
            end
          end
        end

        should "be false if country is not NI, under state pension age, without health condition and with child aged 16 to 19 without a health condition" do
          %w[england wales scotland].each do |country|
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = country
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "no"
            calculator.children_living_with_you = "yes"
            %w[16_to_17 18_to_19].each do |age|
              calculator.age_of_children = age
              calculator.children_with_disability = "no"
              assert_not calculator.eligible_for_personal_independence_payment?
            end
          end
        end

        should "be false if country is not NI, under state pension age, without health condition and with child not aged 16 to 19" do
          %w[england wales scotland].each do |country|
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = country
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "no"
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "5_to_11"
            assert_not calculator.eligible_for_personal_independence_payment?
          end
        end
      end

      context "#eligible_for_personal_independence_payment_northern_ireland?" do
        context "when eligible" do
          should "be true if country is Northern Ireland, under state pension age, no health condition and a child aged 16 to 19 with a health condition" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "no"
            calculator.children_living_with_you = "yes"
            %w[16_to_17 18_to_19].each do |age|
              calculator.age_of_children = age
              calculator.children_with_disability = "yes"
              assert calculator.eligible_for_personal_independence_payment_northern_ireland?
            end
          end

          should "be true if country is Northern Ireland, under state pension age, with a health condition" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "yes"
            assert calculator.eligible_for_personal_independence_payment_northern_ireland?
          end
        end

        context "when ineligible" do
          should "be false if country is Northern Ireland, under state pension age, no health condition and a child not aged 16 to 19" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "no"
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "5_to_11"
            assert_not calculator.eligible_for_personal_independence_payment_northern_ireland?
          end

          should "be false if country is Northern Ireland, OVER state pension age, no health condition and a child aged 16 to 19 wth a health condition" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "yes"
            calculator.disability_or_health_condition = "no"
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "5_to_11"
            %w[16_to_17 18_to_19].each do |age|
              calculator.age_of_children = age
              calculator.children_with_disability = "yes"
              assert_not calculator.eligible_for_personal_independence_payment_northern_ireland?
            end
          end

          should "be false if country is Northern Ireland, under state pension age, without a health condition" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "no"
            assert_not calculator.eligible_for_personal_independence_payment_northern_ireland?
          end

          should "be false if country is Northern Ireland, over state pension age, with a health condition" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            calculator.over_state_pension_age = "yes"
            calculator.disability_or_health_condition = "yes"
            assert_not calculator.eligible_for_personal_independence_payment_northern_ireland?
          end

          should "be false if country is not NI, under state pension age, no health condition and a child aged 16 to 19 with a health condition" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              calculator.disability_or_health_condition = "no"
              calculator.children_living_with_you = "yes"
              %w[16_to_17 18_to_19].each do |age|
                calculator.age_of_children = age
                calculator.children_with_disability = "yes"
                assert_not calculator.eligible_for_personal_independence_payment_northern_ireland?
              end
            end
          end

          should "be false if country is not NI, under state pension age and with a health condition" do
            %w[england wales scotland].each do |country|
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = country
              calculator.over_state_pension_age = "no"
              calculator.disability_or_health_condition = "yes"
              assert_not calculator.eligible_for_personal_independence_payment_northern_ireland?
            end
          end
        end
      end

      context "#eligible_for_attendance_allowance?" do
        context "when eligible" do
          should "be true if over state pension age with a health condition" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.over_state_pension_age = "yes"
            calculator.disability_or_health_condition = "yes"
            assert calculator.eligible_for_attendance_allowance?
          end
        end

        context "when ineligible" do
          should "be false if over state pension age WITHOUT a health condition" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.over_state_pension_age = "yes"
            calculator.disability_or_health_condition = "no"
            assert_not calculator.eligible_for_attendance_allowance?
          end

          should "be false if UNDER state pension age with a health condition" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "yes"
            assert_not calculator.eligible_for_attendance_allowance?
          end

          should "be false if UNDER state pension age WIHTOUT a health condition" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "no"
            assert_not calculator.eligible_for_attendance_allowance?
          end
        end
      end

      context "#eligible_for_council_tax_reduction?" do
        context "when eligible" do
          should "be true if country is not Northern Ireland" do
            calculator = CheckBenefitsSupportCalculator.new
            %w[england wales scotland].each do |country|
              calculator.where_do_you_live = country
              assert calculator.eligible_for_council_tax_reduction?
            end
          end

          context "ineligible" do
            should "be false if country is Northern Ireland" do
              calculator = CheckBenefitsSupportCalculator.new
              calculator.where_do_you_live = "northern-ireland"
              assert_not calculator.eligible_for_council_tax_reduction?
            end
          end
        end
      end

      context "#eligible_for_rate_relief?" do
        context "when eligible" do
          should "be true if country is Northern Ireland" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            assert calculator.eligible_for_rate_relief?
          end
        end

        context "when ineligible" do
          should "be false if country is not Northern Ireland" do
            calculator = CheckBenefitsSupportCalculator.new
            %w[england wales scotland].each do |country|
              calculator.where_do_you_live = country
              assert_not calculator.eligible_for_rate_relief?
            end
          end
        end
      end

      context "#eligible_for_free_tv_licence?" do
        context "when eligible" do
          should "be true if over state pension age" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.over_state_pension_age = "yes"
            assert calculator.eligible_for_free_tv_licence?
          end
        end

        context "when ineligible" do
          should "be false if under state pension age" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.over_state_pension_age = "no"
            assert_not calculator.eligible_for_free_tv_licence?
          end
        end
      end

      context "#eligible_for_budgeting_loan?" do
        context "when eligible" do
          should "be true if country is not Northern Ireland" do
            calculator = CheckBenefitsSupportCalculator.new
            %w[england wales scotland].each do |country|
              calculator.where_do_you_live = country
              assert calculator.eligible_for_budgeting_loan?
            end
          end
        end

        context "when ineligible" do
          should "be false if country is Northern Ireland" do
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = "northern-ireland"
            assert_not calculator.eligible_for_budgeting_loan?
          end
        end
      end

      context "#social_fund_budgeting_loan?" do
        should "return true if eligible for Social Fund Budgeting Loan" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "northern-ireland"
          assert calculator.eligible_for_social_fund_budgeting_loan?
        end

        should "return false if not eligible for Social Fund Budgeting Loan" do
          calculator = CheckBenefitsSupportCalculator.new
          %w[england wales scotland].each do |country|
            calculator.where_do_you_live = country
            assert_not calculator.eligible_for_social_fund_budgeting_loan?
          end
        end
      end

      context "#eligible_for_nhs_low_income_scheme?" do
        should "return true if eligible for NHS Low Income Scheme" do
          %w[england wales].each do |country|
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = country
            calculator.assets_and_savings = "under_16000"
            assert calculator.eligible_for_nhs_low_income_scheme?
          end
        end

        should "return false if not eligible for NHS Low Income Scheme" do
          calculator = CheckBenefitsSupportCalculator.new
          %w[england wales].each do |country|
            calculator.where_do_you_live = country
            calculator.assets_and_savings = "over_16000"
            assert_not calculator.eligible_for_nhs_low_income_scheme?
          end

          %w[scotland northern-ireland].each do |country|
            calculator.where_do_you_live = country
            %w[under_16000 over_16000].each do |assets|
              calculator.assets_and_savings = assets
              assert_not calculator.eligible_for_nhs_low_income_scheme?
            end
          end
        end
      end

      context "#eligible_for_help_with_help_costs?" do
        should "return true if eligible for Help With Health Costs" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "scotland"
          assert calculator.eligible_for_help_with_health_costs?
        end

        should "return false if not eligible for Help With Health Costs" do
          %w[england wales northern-ireland].each do |country|
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = country
            assert_not calculator.eligible_for_help_with_health_costs?
          end
        end
      end

      context "#eligible_for_nhs_low_income_scheme_northern_ireland?" do
        should "return true if eligible for NHS Low Income Scheme Northern Ireland" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "northern-ireland"
          assert calculator.eligible_for_nhs_low_income_scheme_northern_ireland?
        end

        should "return false if not eligible for NHS Low Income Scheme Northern Ireland" do
          %w[england wales scotland].each do |country|
            calculator = CheckBenefitsSupportCalculator.new
            calculator.where_do_you_live = country
            assert_not calculator.eligible_for_nhs_low_income_scheme_northern_ireland?
          end
        end
      end
    end
  end
end
