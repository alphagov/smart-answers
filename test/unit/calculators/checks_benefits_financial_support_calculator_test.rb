require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CheckBenefitsFinancialSupportCalculatorTest < ActiveSupport::TestCase
    context CheckBenefitsFinancialSupportCalculator do
      setup do
        @calculator = CheckBenefitsFinancialSupportCalculator.new
      end

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
          @calculator.where_do_you_live = "england"
          @calculator.stubs(:eligible_for_employment_and_support_allowance?).returns(true)
          @calculator.stubs(:eligible_for_jobseekers_allowance?).returns(false)

          assert_equal @calculator.benefits_for_outcome, expected_benefits
        end
      end

      context "#number_of_benefits" do
        should "return the number of benefits for outcome" do
          number_of_results = rand(1..10)
          CheckBenefitsFinancialSupportCalculator.any_instance
            .stubs(:benefits_for_outcome).returns(Array.new(number_of_results, {}))
          assert_equal @calculator.number_of_benefits, number_of_results
        end
      end

      context "#benefits_selected?" do
        should "return true if benefits are present" do
          @calculator.current_benefits = "universal_credit"
          assert @calculator.benefits_selected?
        end

        should "return false if benefits are empty" do
          @calculator.current_benefits = "none"
          assert_not @calculator.benefits_selected?
        end
      end

      context "#eligible_for_maternity_allowance?" do
        context "when eligible" do
          should "be true if under state pension age, children living with eligible age" do
            @calculator.over_state_pension_age = "no"
            @calculator.children_living_with_you = "yes"
            %w[pregnant 1_or_under].each do |age|
              @calculator.age_of_children = age
              assert @calculator.eligible_for_maternity_allowance?
            end
          end
        end

        context "when ineligible" do
          should "be false if over state pension age" do
            @calculator.over_state_pension_age = "yes"
            assert_not @calculator.eligible_for_maternity_allowance?
          end

          should "be false if child age not eligible" do
            @calculator.over_state_pension_age = "no"
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "5_to_7"
            assert_not @calculator.eligible_for_maternity_allowance?
          end

          should "be false if child not living with you" do
            @calculator.over_state_pension_age = "no"
            @calculator.children_living_with_you = "no"
            assert_not @calculator.eligible_for_maternity_allowance?
          end
        end
      end

      context "#eligible_for_sure_start_maternity_grant?" do
        context "when eligible" do
          should "be true if under state pension age, living with eligible age children / claiming permitted benefits" do
            @calculator.children_living_with_you = "yes"
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "universal_credit"
            %w[pregnant 1_or_under].each do |age|
              @calculator.age_of_children = age
              assert @calculator.eligible_for_sure_start_maternity_grant?
            end
          end

          should "be true if under state pension age, children living with eligible age / don't know benefits" do
            @calculator.children_living_with_you = "yes"
            @calculator.on_benefits = "dont_know"
            %w[pregnant 1_or_under].each do |age|
              @calculator.age_of_children = age
              assert @calculator.eligible_for_sure_start_maternity_grant?
            end
          end
        end

        context "when ineligible" do
          should "be false if child not living with you" do
            @calculator.children_living_with_you = "no"
            assert_not @calculator.eligible_for_sure_start_maternity_grant?
          end

          should "be false if child age not eligible" do
            @calculator.children_living_with_you = "yes"
            @calculator.on_benefits = "dont_know"
            %w[2 3_to_4 5_to_7 8_to_11 12_to_15 16_to_17 18_to_19].each do |age|
              @calculator.age_of_children = age
              assert_not @calculator.eligible_for_sure_start_maternity_grant?
            end
          end

          should "be false if not claiming benefits" do
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "pregnant"
            @calculator.on_benefits = "no"
            assert_not @calculator.eligible_for_sure_start_maternity_grant?
          end

          should "be false if already selected relevant benefit" do
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "pregnant"
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "housing_benefit"
            assert_not @calculator.eligible_for_sure_start_maternity_grant?
          end
        end
      end

      context "#eligible_for_employment_and_support_allowance?" do
        context "when eligible" do
          should "be true if under state pension age with a health issue that affects work" do
            @calculator.over_state_pension_age = "no"
            @calculator.disability_or_health_condition = "yes"
            %w[yes_unable_to_work yes_limits_work].each do |affecting_work|
              @calculator.disability_affecting_work = affecting_work
              assert @calculator.eligible_for_employment_and_support_allowance?
            end
          end
        end

        context "when ineligible" do
          should "be false if under state pension age with a health condition that DOES NOT affect work" do
            @calculator.over_state_pension_age = "no"
            @calculator.disability_or_health_condition = "yes"
            @calculator.disability_affecting_work = "no"
            assert_not @calculator.eligible_for_employment_and_support_allowance?
          end

          should "be false if OVER state pension age with a health condition that affects work" do
            @calculator.over_state_pension_age = "yes"
            @calculator.disability_or_health_condition = "yes"
            @calculator.disability_affecting_work = "yes_limits_work"
            assert_not @calculator.eligible_for_employment_and_support_allowance?
          end

          should "be false if under state pension age WITHOUT a health condition" do
            @calculator.over_state_pension_age = "no"
            @calculator.disability_or_health_condition = "no"
            assert_not @calculator.eligible_for_employment_and_support_allowance?
          end

          should "be false if under state pension age, IS retired, with a health condition that affects work" do
            @calculator.over_state_pension_age = "no"
            @calculator.are_you_working = "no_retired"
            @calculator.disability_or_health_condition = "yes"
            @calculator.disability_affecting_work = "yes_limits_work"
            assert_not @calculator.eligible_for_employment_and_support_allowance?
          end
        end
      end

      context "#eligible_for_jobseekers_allowance?" do
        context "when eligible" do
          should "be true if under pension age, not retired, working under 16 hours" do
            @calculator.over_state_pension_age = "no"
            %w[no yes].each do |working|
              @calculator.are_you_working = working
              @calculator.how_many_paid_hours_work = "sixteen_or_less_per_week"

              assert @calculator.eligible_for_jobseekers_allowance?
            end
          end

          should "be true if under pension age, not retired, working under 16 hours and a health condition does not prevent work" do
            @calculator.over_state_pension_age = "no"
            %w[no yes].each do |working|
              @calculator.are_you_working = working
              @calculator.how_many_paid_hours_work = "sixteen_or_less_per_week"
              %w[no yes_limits_work].each do |disability_affecting_work|
                @calculator.disability_affecting_work = disability_affecting_work

                assert @calculator.eligible_for_jobseekers_allowance?
              end
            end
          end
        end

        context "when ineligible" do
          should "be false if OVER state pension age" do
            @calculator.over_state_pension_age = "yes"
            %w[no yes].each do |working|
              @calculator.are_you_working = working
              @calculator.how_many_paid_hours_work = "sixteen_or_less_per_week"

              assert_not @calculator.eligible_for_jobseekers_allowance?
            end
          end

          should "be false if retired" do
            @calculator.over_state_pension_age = "yes"
            @calculator.are_you_working = "no_retired"
            @calculator.how_many_paid_hours_work = "sixteen_or_less_per_week"

            assert_not @calculator.eligible_for_jobseekers_allowance?
          end

          should "be false if working OVER 16 hours per week" do
            @calculator.over_state_pension_age = "yes"
            %w[no yes].each do |working|
              @calculator.are_you_working = working
              @calculator.how_many_paid_hours_work = "sixteen_or_more_per_week"

              assert_not @calculator.eligible_for_jobseekers_allowance?
            end
          end

          should "be false if health condition prevents work" do
            @calculator.over_state_pension_age = "no"
            %w[no yes].each do |working|
              @calculator.are_you_working = working
              @calculator.how_many_paid_hours_work = "sixteen_or_less_per_week"
              @calculator.disability_affecting_work = "yes_unable_to_work"

              assert_not @calculator.eligible_for_jobseekers_allowance?
            end
          end
        end
      end

      context "#eligible_for_pension_credit?" do
        context "when eligible" do
          should "be true if over state pension age" do
            @calculator.over_state_pension_age = "yes"
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "tax_credits"
            assert @calculator.eligible_for_pension_credit?
          end

          should "be true if over state pension age and not claiming benefits" do
            @calculator.over_state_pension_age = "yes"
            @calculator.on_benefits = "no"
            assert @calculator.eligible_for_pension_credit?
          end
        end

        context "when ineligible" do
          should "be false if UNDER state pension age" do
            @calculator.over_state_pension_age = "no"
            @calculator.on_benefits = "no"
            assert_not @calculator.eligible_for_pension_credit?
          end

          should "be false if over state pension age but already claiming associated benefit" do
            @calculator.over_state_pension_age = "yes"
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "pension_credit"
            assert_not @calculator.eligible_for_pension_credit?
          end
        end
      end

      context "#eligible_for_access_to_work?" do
        context "when eligible" do
          should "return true with a health condition that does not prevent work" do
            @calculator.disability_or_health_condition = "yes"
            %w[no yes_limits_work].each do |affecting_work|
              @calculator.disability_affecting_work = affecting_work
              assert @calculator.eligible_for_access_to_work?
            end
          end
        end

        context "when ineligible" do
          should "return false if without a health condition" do
            @calculator.disability_or_health_condition = "no"
            assert_not @calculator.eligible_for_access_to_work?
          end

          should "return false with a health condition that DOES prevent work" do
            @calculator.disability_or_health_condition = "yes"
            @calculator.disability_affecting_work = "yes_unable_to_work"
            assert_not @calculator.eligible_for_access_to_work?
          end
        end
      end

      context "#eligible_for_universal_credit?" do
        context "when eligible" do
          should "be true if under state pension age with under 16000 assets" do
            @calculator.over_state_pension_age = "no"
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "housing_benefit"
            @calculator.assets_and_savings = "none"
          end

          should "be true if under state pension age with under 16000 assets and not claiming benefits" do
            @calculator.over_state_pension_age = "no"
            @calculator.on_benefits = "no"
            @calculator.assets_and_savings = "under_1600"
            assert @calculator.eligible_for_universal_credit?
          end
        end

        context "when ineligible" do
          should "be false if under state pension age with over 16000 in assets" do
            @calculator.over_state_pension_age = "no"
            @calculator.assets_and_savings = "over_16000"
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "housing_benefit"
            assert_not @calculator.eligible_for_universal_credit?
          end

          should "be false if over state pension age with under 16000 in assets" do
            @calculator.over_state_pension_age = "yes"
            @calculator.assets_and_savings = "under_16000"
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "housing_benefit"
            assert_not @calculator.eligible_for_universal_credit?
          end

          should "be false if over state pension age but already claiming associated benefit" do
            @calculator.over_state_pension_age = "no"
            @calculator.assets_and_savings = "none"
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "housing_benefit,universal_credit"
            assert_not @calculator.eligible_for_universal_credit?
          end
        end
      end

      context "#eligible_for_housing_benefit?" do
        context "when eligible" do
          should "be true if over state pension age" do
            @calculator.over_state_pension_age = "yes"
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "pension_credit"
            assert @calculator.eligible_for_housing_benefit?
          end

          should "be true if over state pension age and not claiming benefits" do
            @calculator.over_state_pension_age = "yes"
            @calculator.on_benefits = "no"
            assert @calculator.eligible_for_housing_benefit?
          end
        end

        context "when ineligible" do
          should "be false if UNDER state pension age" do
            @calculator.over_state_pension_age = "no"
            @calculator.on_benefits = "no"
            assert_not @calculator.eligible_for_housing_benefit?
          end

          should "be false if over state pension age but already claiming associated benefit" do
            @calculator.over_state_pension_age = "yes"
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "housing_benefit"
            assert_not @calculator.eligible_for_housing_benefit?
          end
        end
      end

      context "#eligible_for_an_older_persons_bus_pass?" do
        context "when eligible" do
          should "be true if over state pension age" do
            @calculator.over_state_pension_age = "yes"
            assert @calculator.eligible_for_an_older_persons_bus_pass?
          end
        end

        context "when ineligible" do
          should "be false if UNDER state pension age" do
            @calculator.over_state_pension_age = "no"
            assert_not @calculator.eligible_for_an_older_persons_bus_pass?
          end
        end
      end

      context "#eligible_for_a_disabled_persons_bus_pass?" do
        context "when eligible" do
          should "be true if with health condition" do
            @calculator.disability_or_health_condition = "yes"
            assert @calculator.eligible_for_a_disabled_persons_bus_pass?
          end
        end

        context "when ineligible" do
          should "be false if without health condition" do
            @calculator.disability_or_health_condition = "no"
            assert_not @calculator.eligible_for_a_disabled_persons_bus_pass?
          end
        end
      end

      context "#eligible_for_scottish_child_payment?" do
        context "when eligible" do
          should "be true if child living with you and aged 15 or under" do
            @calculator.children_living_with_you = "yes"
            @calculator.on_benefits = "dont_know"
            %w[1_or_under 2 3_to_4 5_to_7 8_to_11 12_to_15].each do |age|
              @calculator.age_of_children = age
              assert @calculator.eligible_for_scottish_child_payment?
            end
          end
        end

        context "when ineligible" do
          should "be false if child is over 15" do
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "16_to_17"
            @calculator.on_benefits = "dont_know"
            assert_not @calculator.eligible_for_scottish_child_payment?
          end

          should "be false if child is not living with you" do
            @calculator.children_living_with_you = "no"
            assert_not @calculator.eligible_for_scottish_child_payment?
          end

          should "be false if child if eligible but already claiming related benefit" do
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "2"
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "housing_benefit"
            assert_not @calculator.eligible_for_scottish_child_payment?
          end

          should "be false if child if eligible and not claiming benefits" do
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "2"
            @calculator.on_benefits = "no"
            assert_not @calculator.eligible_for_scottish_child_payment?
          end
        end
      end

      context "#eligible_for_tax_free_childcare?" do
        context "when eligible" do
          should "be true if working, with children between 1 and 11" do
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              @calculator.are_you_working = working_hours
              @calculator.children_living_with_you = "yes"
              %w[1_or_under 2 3_to_4 5_to_7 8_to_11].each do |age|
                @calculator.age_of_children = age
                assert @calculator.eligible_for_tax_free_childcare?
              end
            end
          end
        end

        context "when ineligible" do
          should "be false if not working, with children between 1 and 11" do
            @calculator.are_you_working = "no"
            %w[1_or_under 2 3_to_4 5_to_7 8_to_11].each do |age|
              @calculator.age_of_children = age
              assert_not @calculator.eligible_for_tax_free_childcare?
            end
          end

          should "be false if working, with children between 1 and 11, with a disabled child" do
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              @calculator.are_you_working = working_hours
              @calculator.children_living_with_you = "yes"
              @calculator.children_with_disability = "yes"
              %w[1_or_under 2 3_to_4 5_to_7 8_to_11].each do |age|
                @calculator.age_of_children = age
                assert_not @calculator.eligible_for_tax_free_childcare?
              end
            end
          end

          should "be false if working, with children aged between 12 and 19" do
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              @calculator.are_you_working = working_hours
              @calculator.children_living_with_you = "yes"
              %w[12_to_15 16_to_17 18_to_19].each do |age|
                @calculator.age_of_children = age
                assert_not @calculator.eligible_for_tax_free_childcare?
              end
            end
          end

          should "be false if working without children" do
            %w[yes_over_16_hours_per_week yes_under_16_hours_per_week].each do |working_hours|
              @calculator.are_you_working = working_hours
              @calculator.children_living_with_you = "no"
              assert_not @calculator.eligible_for_tax_free_childcare?
            end
          end
        end
      end

      context "#eligible_for_tax_free_childcare_with_disability?" do
        context "when eligible" do
          should "be true if working, with a disabled child and child between 1 and 17" do
            @calculator.are_you_working = "yes_over_16_hours_per_week"
            @calculator.children_living_with_you = "yes"
            @calculator.children_with_disability = "yes"
            %w[1_or_under 2 3_to_4 5_to_7 8_to_11 12_to_15 16_to_17].each do |age|
              @calculator.age_of_children = age
              assert @calculator.eligible_for_tax_free_childcare_with_disability?
            end
          end
        end

        context "when ineligible" do
          should "be false if not working" do
            @calculator.are_you_working = "no"
            assert_not @calculator.eligible_for_tax_free_childcare_with_disability?
          end

          should "be false if working, without children" do
            @calculator.are_you_working = "yes_over_16_hours_per_week"
            @calculator.children_living_with_you = "no"
            assert_not @calculator.eligible_for_tax_free_childcare_with_disability?
          end

          should "be false if working, without children with a disability" do
            @calculator.are_you_working = "yes_over_16_hours_per_week"
            @calculator.children_living_with_you = "no"
            @calculator.children_with_disability = "no"
            assert_not @calculator.eligible_for_tax_free_childcare_with_disability?
          end

          should "be false if working, with children with a disablity between 18 and 19" do
            @calculator.are_you_working = "yes_over_16_hours_per_week"
            @calculator.children_living_with_you = "yes"
            @calculator.children_with_disability = "yes"
            @calculator.age_of_children = "18_to_19"
            assert_not @calculator.eligible_for_tax_free_childcare_with_disability?
          end
        end
      end

      context "#eligible_for_free_childcare_2yr_olds?" do
        context "when eligible" do
          should "be true if child living with you and aged 2" do
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "2"
            @calculator.on_benefits = "dont_know"
            assert @calculator.eligible_for_free_childcare_2yr_olds?
          end
        end

        context "when ineligible" do
          should "be false if child that is not 2" do
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "1,3_to_4"
            assert_not @calculator.eligible_for_free_childcare_2yr_olds?
          end

          should "be false if child is not living with you" do
            @calculator.children_living_with_you = "no"
            @calculator.age_of_children = "2"
            assert_not @calculator.eligible_for_free_childcare_2yr_olds?
          end

          should "be false if child if eligible but already claiming related benefit" do
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "2"
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "housing_benefit"
            assert_not @calculator.eligible_for_free_childcare_2yr_olds?
          end

          should "be false if child if elibile and not claiming benefits" do
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "2"
            @calculator.on_benefits = "no"
            assert_not @calculator.eligible_for_free_childcare_2yr_olds?
          end
        end
      end

      context "#eligible_for_childcare_3_4yr_olds?" do
        context "when eligible" do
          should "be true if with child aged 3 to 4" do
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "3_to_4"
            assert @calculator.eligible_for_childcare_3_4yr_olds?
          end
        end

        context "when ineligible" do
          should "be false if no children" do
            @calculator.children_living_with_you = "no"
            assert_not @calculator.eligible_for_childcare_3_4yr_olds?
          end

          should "be false if child not aged 3 to 4" do
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "1,5_to_7"
            assert_not @calculator.eligible_for_childcare_3_4yr_olds?
          end
        end
      end

      context "#eligible_for_15hrs_free_childcare_3_4yr_olds?" do
        context "when eligible" do
          should "be true if country is England, with child aged 3 to 4" do
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "1,3_to_4"
            assert @calculator.eligible_for_15hrs_free_childcare_3_4yr_olds?
          end
        end

        context "when ineligible" do
          should "be false if without children" do
            @calculator.children_living_with_you = "no"
            assert_not @calculator.eligible_for_15hrs_free_childcare_3_4yr_olds?
          end

          should "be false if child not aged 3 to 4" do
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "1,5_to_7"
            assert_not @calculator.eligible_for_15hrs_free_childcare_3_4yr_olds?
          end
        end
      end

      context "#eligible_for_30hrs_free_childcare_3_4yrs?" do
        context "when eligible" do
          should "be true if working, with child aged 3 to 4" do
            @calculator.are_you_working = "yes"
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "3_to_4"
            assert @calculator.eligible_for_30hrs_free_childcare_3_4yrs?
          end
        end

        context "when ineligible" do
          should "be false if working, with child not aged 3 to 4" do
            @calculator.are_you_working = "yes"
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "1,5_to_7"
            assert_not @calculator.eligible_for_30hrs_free_childcare_3_4yrs?
          end

          should "be false if not working, with child aged 3 to 4" do
            %w[no no_retired].each do |working|
              @calculator.are_you_working = working
              @calculator.children_living_with_you = "yes"
              @calculator.age_of_children = "3_to_4"
              assert_not @calculator.eligible_for_30hrs_free_childcare_3_4yrs?
            end
          end
        end
      end

      context "#eligible_for_funded_early_learning_and_childcare?" do
        context "when eligible" do
          should "be true if child aged 2 or 3 to 4" do
            @calculator.children_living_with_you = "yes"
            %w[2 3_to_4].each do |age|
              @calculator.age_of_children = age
              assert @calculator.eligible_for_funded_early_learning_and_childcare?
            end
          end
        end

        context "when ineligible" do
          should "be false if child not aged 2 or 3 to 4" do
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "5_to_7"
            assert_not @calculator.eligible_for_funded_early_learning_and_childcare?
          end

          should "be false if not living with child" do
            @calculator.children_living_with_you = "no"
            assert_not @calculator.eligible_for_funded_early_learning_and_childcare?
          end
        end
      end

      context "#eligible_for_child_benefit?" do
        context "when eligible" do
          should "be true if living with child" do
            @calculator.children_living_with_you = "yes"
            assert @calculator.eligible_for_child_benefit?
          end
        end

        context "when ineligible" do
          should "be false if not living with child" do
            @calculator.children_living_with_you = "no"
            assert_not @calculator.eligible_for_child_benefit?
          end
        end
      end

      context "#eligible_for_free_tv_license?" do
        context "when eligible" do
          should "be true if with health condition" do
            @calculator.disability_or_health_condition = "yes"
            assert @calculator.eligible_for_free_tv_license?
          end

          should "be true if over state pension age and don't know if recieving benefits" do
            @calculator.over_state_pension_age = "yes"
            @calculator.on_benefits = "dont_know"
            assert @calculator.eligible_for_free_tv_license?
          end

          should "be true if over state pension age and recieve pension_credit" do
            @calculator.over_state_pension_age = "yes"
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "pension_credit,tax_credits"

            assert @calculator.eligible_for_free_tv_license?
          end
        end

        context "when ineligible" do
          should "be false if over state pension age but claim benefits other than pension_credit" do
            @calculator.over_state_pension_age = "yes"
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "income_support,tax_credits"
            assert_not @calculator.eligible_for_free_tv_license?
          end

          should "be false if under state pension age without health condition" do
            @calculator.over_state_pension_age = "no"
            @calculator.disability_or_health_condition = "no"
            assert_not @calculator.eligible_for_free_tv_license?
          end

          should "be false if under state pension age without health condition and do not claim benefits" do
            @calculator.over_state_pension_age = "no"
            @calculator.disability_or_health_condition = "no"
            @calculator.on_benefits = "no"
            assert_not @calculator.eligible_for_free_tv_license?
          end
        end
      end

      context "#eligible_for_child_disability_support?" do
        context "when eligible" do
          should "be true if living with child with disability aged under 15" do
            @calculator.children_living_with_you = "yes"
            @calculator.children_with_disability = "yes"
            %w[1_or_under 2 3_to_4 5_to_7 8_to_11 12_to_15].each do |age|
              @calculator.age_of_children = age
              assert @calculator.eligible_for_child_disability_support?
            end
          end
        end

        context "when ineligible" do
          should "be false if living with child with disability aged 18 to 19" do
            @calculator.children_living_with_you = "yes"
            @calculator.children_with_disability = "yes"
            @calculator.age_of_children = "18_to_19"
            assert_not @calculator.eligible_for_child_disability_support?
          end

          should "be false if living with child WITHOUT disability aged under 15" do
            @calculator.children_living_with_you = "yes"
            @calculator.children_with_disability = "no"
            %w[1_or_under 2 3_to_4 5_to_7 12_to_15].each do |age|
              @calculator.age_of_children = age
              assert_not @calculator.eligible_for_child_disability_support?
            end
          end
        end
      end

      context "#eligible_for_winter_fuel_payment?" do
        context "when eligible" do
          should "be true if eligible for state pension" do
            @calculator.over_state_pension_age = "yes"
            assert @calculator.eligible_for_winter_fuel_payment?
          end
        end

        context "when ineligible" do
          should "be false if ineligible for state pension" do
            @calculator.over_state_pension_age = "no"
            assert_not @calculator.eligible_for_winter_fuel_payment?
          end
        end
      end

      context "#eligible_for_personal_independence_payment?" do
        context "when eligible" do
          should "be true if under state pension age, without health condition and with child aged 16 to 19 with a health condition" do
            @calculator.over_state_pension_age = "no"
            @calculator.disability_or_health_condition = "no"
            @calculator.children_living_with_you = "yes"
            %w[16_to_17 18_to_19].each do |age|
              @calculator.age_of_children = age
              @calculator.children_with_disability = "yes"
              assert @calculator.eligible_for_personal_independence_payment?
            end
          end

          should "be true if under state pension age and with a health condition" do
            @calculator.over_state_pension_age = "no"
            @calculator.disability_or_health_condition = "yes"
            assert @calculator.eligible_for_personal_independence_payment?
          end
        end

        context "when ineligible" do
          should "be false if OVER state pension age, without health condition and with child aged 16 to 19 without a health condition" do
            @calculator.over_state_pension_age = "yes"
            @calculator.disability_or_health_condition = "no"
            @calculator.children_living_with_you = "yes"
            %w[16_to_17 18_to_19].each do |age|
              @calculator.age_of_children = age
              @calculator.children_with_disability = "no"
              assert_not @calculator.eligible_for_personal_independence_payment?
            end
          end

          should "be false if under state pension age, without health condition and with child aged 16 to 19 without a health condition" do
            @calculator.over_state_pension_age = "no"
            @calculator.disability_or_health_condition = "no"
            @calculator.children_living_with_you = "yes"
            %w[16_to_17 18_to_19].each do |age|
              @calculator.age_of_children = age
              @calculator.children_with_disability = "no"
              assert_not @calculator.eligible_for_personal_independence_payment?
            end
          end

          should "be false if under state pension age, without health condition and with child not aged 16 to 19" do
            @calculator.over_state_pension_age = "no"
            @calculator.disability_or_health_condition = "no"
            @calculator.children_living_with_you = "yes"
            @calculator.age_of_children = "5_to_7"
            assert_not @calculator.eligible_for_personal_independence_payment?
          end
        end
      end

      context "#eligible_for_adult_disability_payment_scotland?" do
        context "when eligible" do
          should "be true if under state pension age, with health condition" do
            @calculator.over_state_pension_age = "no"
            @calculator.disability_or_health_condition = "yes"
            assert @calculator.eligible_for_adult_disability_payment_scotland?
          end
        end

        context "when ineligible" do
          should "be false if OVER state pension age" do
            @calculator.over_state_pension_age = "yes"
            @calculator.disability_or_health_condition = "yes"
            assert_not @calculator.eligible_for_adult_disability_payment_scotland?
          end

          should "be false if under state pension age, without health condition" do
            @calculator.over_state_pension_age = "no"
            @calculator.disability_or_health_condition = "no"
            assert_not @calculator.eligible_for_adult_disability_payment_scotland?
          end
        end
      end

      context "#eligible_for_attendance_allowance?" do
        context "when eligible" do
          should "be true if over state pension age with a health condition" do
            @calculator.over_state_pension_age = "yes"
            @calculator.disability_or_health_condition = "yes"
            assert @calculator.eligible_for_attendance_allowance?
          end
        end

        context "when ineligible" do
          should "be false if over state pension age WITHOUT a health condition" do
            @calculator.over_state_pension_age = "yes"
            @calculator.disability_or_health_condition = "no"
            assert_not @calculator.eligible_for_attendance_allowance?
          end

          should "be false if UNDER state pension age with a health condition" do
            @calculator.over_state_pension_age = "no"
            @calculator.disability_or_health_condition = "yes"
            assert_not @calculator.eligible_for_attendance_allowance?
          end

          should "be false if UNDER state pension age WIHTOUT a health condition" do
            @calculator.over_state_pension_age = "no"
            @calculator.disability_or_health_condition = "no"
            assert_not @calculator.eligible_for_attendance_allowance?
          end
        end
      end

      context "#eligible_for_support_for_mortgage_interest?" do
        context "when eligible" do
          should "be true if not already claiming associated benefit" do
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "income_support"
            assert @calculator.eligible_for_support_for_mortgage_interest?
          end
        end

        context "when ineligible" do
          should "be false if already selected associated benefit" do
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "tax_credits"
            assert_not @calculator.eligible_for_support_for_mortgage_interest?
          end

          should "be false if not claiming benefits benefit" do
            @calculator.on_benefits = "no"
            assert_not @calculator.eligible_for_support_for_mortgage_interest?
          end
        end
      end

      context "#eligible_for_budgeting_loan?" do
        context "when eligible" do
          should "be true if not already claiming associated benefit" do
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "income_support"
            assert @calculator.eligible_for_budgeting_loan?
          end

          should "be true if dont know current benefits" do
            @calculator.on_benefits = "dont_know"
            assert @calculator.eligible_for_budgeting_loan?
          end
        end

        context "when ineligible" do
          should "be false if already selected associated benefit" do
            @calculator.on_benefits = "yes"
            @calculator.current_benefits = "universal_credit"
            assert_not @calculator.eligible_for_budgeting_loan?
          end
        end
      end

      context "#education_maintenance_allowance_ni?" do
        context "when eligible" do
          should "be true if living with children and eligible ages" do
            @calculator.children_living_with_you = "yes"
            %w[16_to_17 18_to_19].each do |age|
              @calculator.age_of_children = age
              assert @calculator.eligible_for_education_maintenance_allowance_ni?
            end
          end
        end

        context "when ineligible" do
          should "be false if no children living with you" do
            @calculator.children_living_with_you = "no"
            assert_not @calculator.eligible_for_education_maintenance_allowance_ni?
          end

          should "be false if children living but not eligible age" do
            @calculator.children_living_with_you = "no"
            @calculator.age_of_children = "5_to_7"
            assert_not @calculator.eligible_for_education_maintenance_allowance_ni?
          end
        end
      end

      context "#eligible_for_warm_home_discount_scheme?" do
        context "when eligible" do
          should "be true if receiving benefits" do
            @calculator.on_benefits = "yes"
            assert @calculator.eligible_for_warm_home_discount_scheme?
          end
        end

        context "when ineligible" do
          should "be false if not on benefits" do
            @calculator.on_benefits = "no"
            assert_not @calculator.eligible_for_warm_home_discount_scheme?
          end
        end
      end
    end
  end
end
