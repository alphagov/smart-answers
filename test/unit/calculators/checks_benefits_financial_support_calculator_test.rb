require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CheckBenefitsFinancialSupportCalculatorTest < ActiveSupport::TestCase
    context CheckBenefitsFinancialSupportCalculator do
      context "#benefits_for_outcome" do
        should "return array of eligible and non-conditional benefits" do
          stubbed_benefit_data = {
            "benefits" => [{ "title" => "eligible_benefit",
                             "condition" => "eligible_for_employment_and_support_allowance?",
                             "countries" => %w[england wales scotland] },
                           { "title" => "unconditional_benefit",
                             "countries" => %w[england] },
                           { "title" => "unconditional_benefit_wales",
                             "countries" => %w[wales] },
                           { "title" => "ineligile_benefit",
                             "condition" => "eligible_for_jobseekers_allowance?",
                             "countries" => %w[england] }],
          }
          expected_benefits = [
            { "title" => "eligible_benefit",
              "condition" => "eligible_for_employment_and_support_allowance?",
              "countries" => %w[england wales scotland] },
            { "title" => "unconditional_benefit",
              "countries" => %w[england] },
          ]

          YAML.stubs(:load_file).returns(stubbed_benefit_data)
          calculator = CheckBenefitsFinancialSupportCalculator.new
          calculator.where_do_you_live = "england"
          calculator.stubs(:eligible_for_employment_and_support_allowance?).returns(true)
          calculator.stubs(:eligible_for_jobseekers_allowance?).returns(false)

          assert_equal calculator.benefits_for_outcome, expected_benefits
        end
      end

      context "#number_of_benefits" do
        should "return the number of benefits for outcome" do
          number_of_results = rand(1..10)
          CheckBenefitsFinancialSupportCalculator.any_instance
            .stubs(:benefits_for_outcome).returns(Array.new(number_of_results, {}))
          calculator = CheckBenefitsFinancialSupportCalculator.new
          assert_equal calculator.number_of_benefits, number_of_results
        end
      end

      context "#eligible_for_employment_and_support_allowance?" do
        context "when eligible" do
          should "be true if under state pension age, working under 16 hours, with a health issue that affects work" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
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

        context "when ineligible" do
          should "be false if under state pension age, working under 16 hours, with a health condition that DOES NOT affect work" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "no"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.disability_or_health_condition = "yes"
              calculator.disability_affecting_work = "no"
              assert_not calculator.eligible_for_employment_and_support_allowance?
            end
          end

          should "be false if OVER state pension age, working under 16 hours, with a health condition that affects work" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "yes"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.disability_or_health_condition = "yes"
              calculator.disability_affecting_work = "yes_limits_work"
              assert_not calculator.eligible_for_employment_and_support_allowance?
            end
          end

          should "be false if under state pension age, working under 16 hours, WITHOUT a health condition" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "no"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.disability_or_health_condition = "no"
              assert_not calculator.eligible_for_employment_and_support_allowance?
            end
          end

          should "be false if under state pension age, working over 16 hours, with a health issue that affects work" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
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

      context "#eligible_for_jobseekers_allowance?" do
        context "when eligible" do
          should "be true if under pension age, working under 16 hours" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "no"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              assert calculator.eligible_for_jobseekers_allowance?
            end
          end

          should "be true if under pension age, working under 16 hours and a health condition does not prevent work" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
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

        context "when ineligible" do
          should "be false if OVER state pension age" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "yes"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              %w[no yes_limits_work].each do |affecting_work|
                calculator.disability_affecting_work = affecting_work
                assert_not calculator.eligible_for_jobseekers_allowance?
              end
            end
          end

          should "be false if under state pension age and working OVER 16 hours" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "yes"
            calculator.are_you_working = "yes_over_16_hours_per_week"
            %w[no yes_limits_work].each do |affecting_work|
              calculator.disability_affecting_work = affecting_work
              assert_not calculator.eligible_for_jobseekers_allowance?
            end
          end

          should "be false if under state pension age, working under 16 hours, and with a health condition that prevents work" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "yes"
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.disability_affecting_work = "yes_unable_to_work"
              assert_not calculator.eligible_for_jobseekers_allowance?
            end
          end
        end
      end

      context "#eligible_for_pension_credit?" do
        context "when eligible" do
          should "be true if over state pension age" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "yes"
            assert calculator.eligible_for_pension_credit?
          end
        end

        context "when ineligible" do
          should "be false if UNDER state pension age" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "no"
            assert_not calculator.eligible_for_pension_credit?
          end
        end
      end

      context "#eligible_for_access_to_work?" do
        context "when eligible" do
          should "return true with a health condition that does not prevent work" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.disability_or_health_condition = "yes"
            %w[no yes_limits_work].each do |affecting_work|
              calculator.disability_affecting_work = affecting_work
              assert calculator.eligible_for_access_to_work?
            end
          end
        end

        context "when ineligible" do
          should "return false if without a health condition" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.disability_or_health_condition = "no"
            assert_not calculator.eligible_for_access_to_work?
          end

          should "return false with a health condition that DOES prevent work" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.disability_or_health_condition = "yes"
            calculator.disability_affecting_work = "yes_unable_to_work"
            assert_not calculator.eligible_for_access_to_work?
          end
        end
      end

      context "#eligible_for_universal_credit?" do
        context "when eligible" do
          should "be true if under state pension age with under 16000 assets" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "no"
            %w[none_16000 under_16000].each do |assets|
              calculator.assets_and_savings = assets
              assert calculator.eligible_for_universal_credit?
            end
          end
        end

        context "when ineligible" do
          should "be false if under state pension age with over 16000 in assets" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "no"
            calculator.assets_and_savings = "over_16000"
            assert_not calculator.eligible_for_universal_credit?
          end

          should "be false if over state pension age with under 16000 in assets" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "yes"
            calculator.assets_and_savings = "under_16000"
            assert_not calculator.eligible_for_universal_credit?
          end
        end
      end

      context "#eligible_for_housing_benefit?" do
        context "when eligible" do
          should "be true if over state pension age" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "yes"
            assert calculator.eligible_for_housing_benefit?
          end
        end

        context "when ineligible" do
          should "be false if UNDER state pension age" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "no"
            assert_not calculator.eligible_for_housing_benefit?
          end
        end
      end

      context "#eligible_for_tax_free_childcare?" do
        context "when eligible" do
          should "be true if working, with children between 1 and 11" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.children_living_with_you = "yes"
              %w[1_or_under 2 3_to_4 5_to_7 8_to_11].each do |age|
                calculator.age_of_children = age
                assert calculator.eligible_for_tax_free_childcare?
              end
            end
          end

          should "be true if working, with a disabled child and children between 1 and 17" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.children_living_with_you = "yes"
              calculator.children_with_disability = "yes"
              %w[1_or_under 2 3_to_4 5_to_7 8_to_11 12_to_15 16_to_17].each do |age|
                calculator.age_of_children = age
                assert calculator.eligible_for_tax_free_childcare?
              end
            end
          end
        end

        context "when ineligible" do
          should "be false if not working with children between 1 and 11" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.are_you_working = "no"
            %w[1_or_under 2 3_to_4 5_to_7 8_to_11].each do |age|
              calculator.age_of_children = age
              assert_not calculator.eligible_for_tax_free_childcare?
            end
          end

          should "be false if working with children aged between 12 and 19" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
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
            calculator = CheckBenefitsFinancialSupportCalculator.new
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.children_living_with_you = "no"
              assert_not calculator.eligible_for_tax_free_childcare?
            end
          end

          should "be false if working with a disabled child and children aged 18 to 19" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
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
          should "be true if child living with you and aged 2" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "2"
            assert calculator.eligible_for_free_childcare_2yr_olds?
          end
        end

        context "when ineligible" do
          should "be false if child that is not 2" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "1,3_to_4"
            assert_not calculator.eligible_for_free_childcare_2yr_olds?
          end

          should "be false if child is not living with you" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.children_living_with_you = "no"
            calculator.age_of_children = "2"
            assert_not calculator.eligible_for_free_childcare_2yr_olds?
          end
        end
      end

      context "#eligible_for_childcare_3_4yr_olds?" do
        context "when eligible" do
          should "be true if working over 16 hours with child aged 3 to 4" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.are_you_working = "yes_over_16_hours_per_week"
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "3_to_4"
            assert calculator.eligible_for_childcare_3_4yr_olds?
          end
        end

        context "when ineligible" do
          should "be false working under 16 hours with child aged 3 to 4" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            %w[no yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.children_living_with_you = "yes"
              calculator.age_of_children = "3_to_4"
              assert_not calculator.eligible_for_childcare_3_4yr_olds?
            end
          end

          should "be false if working over 16 hours without child aged 3 to 4" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.are_you_working = "yes_over_16_hours_per_week"
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "1,5_to_7"
            assert_not calculator.eligible_for_childcare_3_4yr_olds?
          end
        end
      end

      context "#eligible_for_15hrs_free_childcare_3_4yr_olds?" do
        context "when eligible" do
          should "be true if country is England, with child aged 3 to 4" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "1,3_to_4"
            assert calculator.eligible_for_15hrs_free_childcare_3_4yr_olds?
          end
        end

        context "when ineligible" do
          should "be false if without children" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.children_living_with_you = "no"
            assert_not calculator.eligible_for_15hrs_free_childcare_3_4yr_olds?
          end

          should "be false if child not aged 3 to 4" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "1,5_to_7"
            assert_not calculator.eligible_for_15hrs_free_childcare_3_4yr_olds?
          end
        end
      end

      context "#eligible_for_30hrs_free_childcare_3_4yrs?" do
        context "when eligible" do
          should "be true if working, with child aged 3 to 4" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.children_living_with_you = "yes"
              calculator.age_of_children = "3_to_4"
              assert calculator.eligible_for_30hrs_free_childcare_3_4yrs?
            end
          end
        end

        context "when ineligible" do
          should "be false if working, with child not aged 3 to 4" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              calculator.are_you_working = working_hours
              calculator.children_living_with_you = "yes"
              calculator.age_of_children = "1,5_to_7"
              assert_not calculator.eligible_for_30hrs_free_childcare_3_4yrs?
            end
          end

          should "be false if not working, with child aged 3 to 4" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.are_you_working = "no"
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "3_to_4"
            assert_not calculator.eligible_for_30hrs_free_childcare_3_4yrs?
          end
        end
      end

      context "#eligible_for_funded_early_learning_and_childcare?" do
        context "when eligible" do
          should "be true if child aged 2 or 3 to 4" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.children_living_with_you = "yes"
            %w[2 3_to_4].each do |age|
              calculator.age_of_children = age
              assert calculator.eligible_for_funded_early_learning_and_childcare?
            end
          end
        end

        context "when ineligible" do
          should "be false if child not aged 2 or 3 to 4" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "5_to_7"
            assert_not calculator.eligible_for_funded_early_learning_and_childcare?
          end

          should "be false if not living with child" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.children_living_with_you = "no"
            assert_not calculator.eligible_for_funded_early_learning_and_childcare?
          end
        end
      end

      context "#eligible_for_child_benefit?" do
        context "when eligible" do
          should "be true if living with child" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.children_living_with_you = "yes"
            assert calculator.eligible_for_child_benefit?
          end
        end

        context "when ineligible" do
          should "be false if not living with child" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.children_living_with_you = "no"
            assert_not calculator.eligible_for_child_benefit?
          end
        end
      end

      context "#eligible_for_child_disability_support?" do
        context "when eligible" do
          should "be true if living with child with disability aged under 15" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.children_living_with_you = "yes"
            calculator.children_with_disability = "yes"
            %w[1_or_under 2 3_to_4 5_to_7 8_to_11 12_to_15].each do |age|
              calculator.age_of_children = age
              assert calculator.eligible_for_child_disability_support?
            end
          end
        end

        context "when ineligible" do
          should "be false if living with child with disability aged 18 to 19" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.children_living_with_you = "yes"
            calculator.children_with_disability = "yes"
            calculator.age_of_children = "18_to_19"
            assert_not calculator.eligible_for_child_disability_support?
          end

          should "be false if living with child WITHOUT disability aged under 15" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.children_living_with_you = "yes"
            calculator.children_with_disability = "no"
            %w[1_or_under 2 3_to_4 5_to_7 12_to_15].each do |age|
              calculator.age_of_children = age
              assert_not calculator.eligible_for_child_disability_support?
            end
          end
        end
      end

      context "#eligible_for_personal_independence_payment?" do
        context "when eligible" do
          should "be true if under state pension age, without health condition and with child aged 16 to 19 with a health condition" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "no"
            calculator.children_living_with_you = "yes"
            %w[16_to_17 18_to_19].each do |age|
              calculator.age_of_children = age
              calculator.children_with_disability = "yes"
              assert calculator.eligible_for_personal_independence_payment?
            end
          end

          should "be true if under state pension age and with a health condition" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "yes"
            assert calculator.eligible_for_personal_independence_payment?
          end
        end

        context "when ineligible" do
          should "be false if OVER state pension age, without health condition and with child aged 16 to 19 without a health condition" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "yes"
            calculator.disability_or_health_condition = "no"
            calculator.children_living_with_you = "yes"
            %w[16_to_17 18_to_19].each do |age|
              calculator.age_of_children = age
              calculator.children_with_disability = "no"
              assert_not calculator.eligible_for_personal_independence_payment?
            end
          end

          should "be false if under state pension age, without health condition and with child aged 16 to 19 without a health condition" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "no"
            calculator.children_living_with_you = "yes"
            %w[16_to_17 18_to_19].each do |age|
              calculator.age_of_children = age
              calculator.children_with_disability = "no"
              assert_not calculator.eligible_for_personal_independence_payment?
            end
          end

          should "be false if under state pension age, without health condition and with child not aged 16 to 19" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "no"
            calculator.children_living_with_you = "yes"
            calculator.age_of_children = "5_to_7"
            assert_not calculator.eligible_for_personal_independence_payment?
          end
        end
      end

      context "#eligible_for_attendance_allowance?" do
        context "when eligible" do
          should "be true if over state pension age with a health condition" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "yes"
            calculator.disability_or_health_condition = "yes"
            assert calculator.eligible_for_attendance_allowance?
          end
        end

        context "when ineligible" do
          should "be false if over state pension age WITHOUT a health condition" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "yes"
            calculator.disability_or_health_condition = "no"
            assert_not calculator.eligible_for_attendance_allowance?
          end

          should "be false if UNDER state pension age with a health condition" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "yes"
            assert_not calculator.eligible_for_attendance_allowance?
          end

          should "be false if UNDER state pension age WIHTOUT a health condition" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "no"
            calculator.disability_or_health_condition = "no"
            assert_not calculator.eligible_for_attendance_allowance?
          end
        end
      end

      context "#eligible_for_free_tv_licence?" do
        context "when eligible" do
          should "be true if over state pension age" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "yes"
            assert calculator.eligible_for_free_tv_licence?
          end
        end

        context "when ineligible" do
          should "be false if under state pension age" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.over_state_pension_age = "no"
            assert_not calculator.eligible_for_free_tv_licence?
          end
        end
      end

      context "#eligible_for_nhs_low_income_scheme?" do
        context "when eligible" do
          should "be true if under 16000 assets" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            %w[none_16000 under_16000].each do |assets|
              calculator.assets_and_savings = assets
              assert calculator.eligible_for_nhs_low_income_scheme?
            end
          end
        end

        context "when ineligible" do
          should "be false if OVER 1600 assets" do
            calculator = CheckBenefitsFinancialSupportCalculator.new
            calculator.assets_and_savings = "over_16000"
            assert_not calculator.eligible_for_nhs_low_income_scheme?
          end
        end
      end
    end
  end
end
