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
        should "return true if eligible for Employment and Support Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          calculator.disability_or_health_condition = "yes"
          calculator.disability_affecting_work = "yes_unable_to_work"

          assert calculator.eligible_for_employment_and_support_allowance?

          calculator.disability_affecting_work = "yes_limits_work"
          assert calculator.eligible_for_employment_and_support_allowance?
        end

        should "return false if not eligible for Employment and Support Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          calculator.disability_or_health_condition = "no"
          assert_not calculator.eligible_for_employment_and_support_allowance?
        end
      end

      context "#eligible_for_jobseekers_allowance?" do
        should "return true if eligible for Jobseeker's Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "scotland"
          calculator.over_state_pension_age = "no"
          calculator.are_you_working = "no"
          calculator.disability_affecting_work = "yes_limits_work"
          assert calculator.eligible_for_jobseekers_allowance?

          calculator.where_do_you_live = "england"
          assert calculator.eligible_for_jobseekers_allowance?

          calculator.disability_affecting_work = nil
          assert calculator.eligible_for_jobseekers_allowance?
        end

        should "return false if not eligible for Jobseeker's Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "northern-ireland"
          calculator.over_state_pension_age = "yes"
          calculator.are_you_working = "yes_over_16_hours_per_week"
          calculator.disability_affecting_work = "yes_unable_to_work"
          assert_not calculator.eligible_for_jobseekers_allowance?
        end
      end

      context "#eligible_for_pension_credit?" do
        should "return true if eligible for Pension Credit" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          assert calculator.eligible_for_pension_credit?
        end

        should "return false if not eligible for Pension Credit" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "yes"
          assert_not calculator.eligible_for_pension_credit?
        end
      end

      context "#eligible_for_access_to_work?" do
        should "return true if eligible for Access to Work" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "wales"
          calculator.disability_or_health_condition = "yes"
          calculator.disability_affecting_work = "no"
          assert calculator.eligible_for_access_to_work?

          calculator.disability_affecting_work = "yes_limits_work"
          assert calculator.eligible_for_access_to_work?
        end

        should "return false if not eligible for Access to Work" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "northern-ireland"
          assert_not calculator.eligible_for_access_to_work?

          calculator.where_do_you_live = "wales"
          calculator.disability_or_health_condition = "no"
          assert_not calculator.eligible_for_access_to_work?

          calculator.disability_or_health_condition = "yes"
          calculator.disability_affecting_work = "yes_unable_to_work"
          assert_not calculator.eligible_for_access_to_work?
        end
      end

      context "#eligible_for_universal_credit?" do
        should "return true if eligible for Universal Credit" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          calculator.assets_and_savings = "under_16000"

          assert calculator.eligible_for_universal_credit?
        end

        should "return false if not eligible for Universal Credit" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "yes"
          assert_not calculator.eligible_for_universal_credit?

          calculator.over_state_pension_age = "no"
          calculator.assets_and_savings = "over_16000"
          assert_not calculator.eligible_for_universal_credit?
        end
      end

      context "#eligible_for_housing_benefit?" do
        should "return true if eligible for Housing Benefit" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "yes"
          assert calculator.eligible_for_housing_benefit?
        end

        should "return false if not eligible for Housing Benefit" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          assert_not calculator.eligible_for_housing_benefit?
        end
      end

      context "#eligible_for_tax_free_childcare?" do
        should "return true if eligible for Tax Free Childcare" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.are_you_working = "yes"
          calculator.children_living_with_you = "yes"
          %w[1_or_under 2 3_to_4 5_to_11].each do |age|
            calculator.age_of_children = age
            assert calculator.eligible_for_tax_free_childcare?
          end
        end

        should "return false if not eligible for Tax Free Childcare" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.are_you_working = "no"
          assert_not calculator.eligible_for_tax_free_childcare?

          calculator.are_you_working = "yes"
          calculator.children_living_with_you = "yes"
          %w[12_to_15 16_to_17 18_to_19].each do |age|
            calculator.age_of_children = age
            assert_not calculator.eligible_for_tax_free_childcare?
          end
        end
      end

      context "# eligible_for_free_childcare_2yr_olds?" do
        should "return true if eligible for Free Childcare 2 Year Olds" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "england"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "2"
          assert calculator.eligible_for_free_childcare_2yr_olds?
        end

        should "return false if not eligible for Free Childcare 2 Year Olds" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "scotland"
          assert_not calculator.eligible_for_free_childcare_2yr_olds?

          calculator.where_do_you_live = "england"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "1_or_under"
          assert_not calculator.eligible_for_free_childcare_2yr_olds?
        end
      end

      context "#eligible_for_childcare_3_4yr_olds_wales??" do
        should "return true if eligible for Childcare 3 and 4 Year Olds Wales" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "wales"
          calculator.are_you_working = "yes_under_16_hours_per_week"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "3_to_4"
          assert calculator.eligible_for_childcare_3_4yr_olds_wales?
        end

        should "return false if not eligible for Childcare 3 and 4 Year Olds Wales" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "scotland"
          assert_not calculator.eligible_for_childcare_3_4yr_olds_wales?

          calculator.where_do_you_live = "wales"
          calculator.are_you_working = "no"
          assert_not calculator.eligible_for_childcare_3_4yr_olds_wales?

          calculator.where_do_you_live = "wales"
          calculator.are_you_working = "yes_over_16_hours_per_week"
          assert_not calculator.eligible_for_childcare_3_4yr_olds_wales?

          calculator.where_do_you_live = "wales"
          calculator.are_you_working = "yes_under_16_hours_per_week"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "1_or_under, 3_to_4"
          assert_not calculator.eligible_for_childcare_3_4yr_olds_wales?
        end
      end

      context "#eligible_for_15hrs_free_childcare_3_4yr_olds?" do
        should "return true if eligible for 15 Hours Free Childcare for 3 and 4 Year Olds" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "england"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "3_to_4"
          assert calculator.eligible_for_15hrs_free_childcare_3_4yr_olds?
        end

        should "return false if not eligible for Childcare 3 and 4 Year Olds Wales" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "scotland"
          assert_not calculator.eligible_for_15hrs_free_childcare_3_4yr_olds?

          calculator.where_do_you_live = "england"
          calculator.children_living_with_you = "no"
          assert_not calculator.eligible_for_15hrs_free_childcare_3_4yr_olds?

          calculator.where_do_you_live = "england"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "2, 18_to_19"
          assert_not calculator.eligible_for_15hrs_free_childcare_3_4yr_olds?
        end
      end

      context "#eligible_for_30hrs_free_childcare_3_4yrs?" do
        should "return true if eligible for 30 Hours Free Childcare for 3 and 4 Year Olds" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.are_you_working = "yes_over_16_hours_per_week"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "3_to_4"
          assert calculator.eligible_for_30hrs_free_childcare_3_4yrs?
        end

        should "return false if not eligible for 30 Hours Free Childcare for 3 and 4 Year Olds" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.are_you_working = "no"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "3_to_4"
          assert_not calculator.eligible_for_30hrs_free_childcare_3_4yrs?

          calculator.are_you_working = "yes"
          calculator.children_living_with_you = "no"
          assert_not calculator.eligible_for_30hrs_free_childcare_3_4yrs?

          calculator.are_you_working = "yes"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "1_or_under,2,18_to_19"
          assert_not calculator.eligible_for_30hrs_free_childcare_3_4yrs?
        end
      end

      context "#eligible_for_30hrs_free_childcare_3_4yrs_scotland?" do
        should "return true if eligible for 30 Hours Free Childcare for 3 and 4 Year Olds Scotland" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "scotland"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "3_to_4"
          assert calculator.eligible_for_30hrs_free_childcare_3_4yrs_scotland?
        end

        should "return false if not eligible for 30 Hours Free Childcare for 3 and 4 Year Olds Scotland" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "england"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "3_to_4"
          assert_not calculator.eligible_for_30hrs_free_childcare_3_4yrs_scotland?

          calculator.where_do_you_live = "scotland"
          calculator.children_living_with_you = "no"
          assert_not calculator.eligible_for_30hrs_free_childcare_3_4yrs_scotland?

          calculator.where_do_you_live = "scotland"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "1_or_under,2,18_to_19"
          assert_not calculator.eligible_for_30hrs_free_childcare_3_4yrs_scotland?
        end
      end

      context "#eligible_for_2yr_old_childcare_scotland?" do
        should "return true if eligible for 2 Year Old Childcare Scotland" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "scotland"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "2"
          assert calculator.eligible_for_2yr_old_childcare_scotland?
        end

        should "return false if not eligible for 2 Year Old Childcare Scotland" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "england"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "2"
          assert_not calculator.eligible_for_2yr_old_childcare_scotland?

          calculator.where_do_you_live = "scotland"
          calculator.children_living_with_you = "no"
          assert_not calculator.eligible_for_2yr_old_childcare_scotland?

          calculator.where_do_you_live = "scotland"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "1_or_under,3_to_4,18_to_19"
          assert_not calculator.eligible_for_2yr_old_childcare_scotland?
        end
      end

      context "#eligible_for_child_benefit?" do
        should "return true if eligible for Child Benefit" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.children_living_with_you = "yes"
          assert calculator.eligible_for_child_benefit?
        end

        should "return false if not eligible for Child Benefit" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.children_living_with_you = "no"
          assert_not calculator.eligible_for_child_benefit?
        end
      end

      context "#eligible_for_disability_living_allowance_for_children?" do
        should "return true if eligible for Disability Living Allowance for Children" do
          calculator = CheckBenefitsSupportCalculator.new
          %w[england wales].each do |country|
            calculator.where_do_you_live = country
            calculator.carer_disability_or_health_condition = "yes"
            calculator.children_living_with_you = "yes"
            calculator.children_with_disability = "yes"
            %w[1_or_under 2 3_to_4 5_to_11 12_to_15].each do |age|
              calculator.age_of_children = age
              assert calculator.eligible_for_disability_living_allowance_for_children?
            end
          end
        end

        should "return false if not eligible for Disability Living Allowance for Children" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "scotland"
          assert_not calculator.eligible_for_disability_living_allowance_for_children?

          calculator.where_do_you_live = "england"
          calculator.carer_disability_or_health_condition = "yes"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "1_or_under"
          calculator.children_with_disability = "no"
          assert_not calculator.eligible_for_disability_living_allowance_for_children?

          calculator.where_do_you_live = "england"
          calculator.carer_disability_or_health_condition = "yes"
          calculator.children_living_with_you = "no"
          assert_not calculator.eligible_for_disability_living_allowance_for_children?
        end
      end

      context "#eligible_for_child_disability_payment_scotland?" do
        should "return true if eligible for Child Disability Payment Scotland" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "scotland"
          calculator.carer_disability_or_health_condition = "yes"
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
          calculator.carer_disability_or_health_condition = "yes"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "1_or_under"
          calculator.children_with_disability = "yes"
          assert_not calculator.eligible_for_child_disability_payment_scotland?

          calculator.where_do_you_live = "scotland"
          calculator.carer_disability_or_health_condition = "yes"
          calculator.children_living_with_you = "yes"
          calculator.age_of_children = "1_or_under"
          calculator.children_with_disability = "no"
          assert_not calculator.eligible_for_child_disability_payment_scotland?
        end
      end

      context "#eligible_for_carers_allowance?" do
        should "return true if eligible for Carer's Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          %w[england wales scotland].each do |country|
            calculator.where_do_you_live = country
            calculator.carer_disability_or_health_condition = "yes"
            assert calculator.eligible_for_carers_allowance?
          end
        end

        should "return false if not eligible for Carer's Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "northern-ireland"
          calculator.carer_disability_or_health_condition = "yes"
          assert_not calculator.eligible_for_carers_allowance?

          %w[england wales scotland].each do |country|
            calculator.where_do_you_live = country
            calculator.carer_disability_or_health_condition = "no"
            assert_not calculator.eligible_for_carers_allowance?
          end
        end
      end

      context "#eligible_for_personal_independence_payment?" do
        should "return true if eligible for Personal Independence Payment" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          calculator.disability_or_health_condition = "yes"
          assert calculator.eligible_for_personal_independence_payment?
        end

        should "return false if not eligible for Personal Independence Payment" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          calculator.disability_or_health_condition = "no"
          assert_not calculator.eligible_for_personal_independence_payment?

          calculator.over_state_pension_age = "yes"
          calculator.disability_or_health_condition = "yes"
          assert_not calculator.eligible_for_personal_independence_payment?

          calculator.over_state_pension_age = "yes"
          calculator.disability_or_health_condition = "no"
          assert_not calculator.eligible_for_personal_independence_payment?
        end
      end

      context "#eligible_for_attendance_allowance?" do
        should "return true if eligible for Attendance Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          calculator.disability_or_health_condition = "yes"
          assert calculator.eligible_for_attendance_allowance?
        end

        should "return false if not eligible for Attendance Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          calculator.disability_or_health_condition = "no"
          assert_not calculator.eligible_for_attendance_allowance?

          calculator.over_state_pension_age = "yes"
          calculator.disability_or_health_condition = "yes"
          assert_not calculator.eligible_for_attendance_allowance?

          calculator.over_state_pension_age = "yes"
          calculator.disability_or_health_condition = "no"
          assert_not calculator.eligible_for_attendance_allowance?
        end
      end

      context "#eligible_for_free_tv_licence?" do
        should "return true if eligible for Free TV Licence" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "yes"
          assert calculator.eligible_for_free_tv_licence?
        end

        should "return false if not eligible for Free TV Licence" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          assert_not calculator.eligible_for_free_tv_licence?
        end
      end

      context "#eligible_for_universal_credit_advance?" do
        should "return true if eligible for Universal Credit Advance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          calculator.assets_and_savings = "under_16000"
          assert calculator.eligible_for_universal_credit_advance?
        end

        should "return false if not eligible for Universal Credit Advance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "yes"
          calculator.assets_and_savings = "under_16000"
          assert_not calculator.eligible_for_universal_credit_advance?

          calculator.over_state_pension_age = "no"
          calculator.assets_and_savings = "over_16000"
          assert_not calculator.eligible_for_universal_credit_advance?
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
