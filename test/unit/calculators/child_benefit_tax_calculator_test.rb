require_relative "../../test_helper"

module SmartAnswer::Calculators
  class ChildBenefitTaxCalculatorTest < ActiveSupport::TestCase
    context ChildBenefitTaxCalculator do
      context "validations" do
        context "#valid_number_of_children?" do
          should "be valid when there are less than 30 children" do
            calculator = ChildBenefitTaxCalculator.new(
              children_count: 2,
            )

            assert calculator.valid_number_of_children?
          end

          should "not be valid if the number of children entered is 0" do
            calculator = ChildBenefitTaxCalculator.new(
              children_count: 0,
            )

            assert_not calculator.valid_number_of_children?
          end

          should "not be valid if the number of children entered is negative" do
            calculator = ChildBenefitTaxCalculator.new(
              children_count: -1,
            )

            assert_not calculator.valid_number_of_children?
          end

          should "not be valid when there are more than 30 children" do
            calculator = ChildBenefitTaxCalculator.new(
              children_count: 31,
            )

            assert_not calculator.valid_number_of_children?
          end
        end

        context "#valid_number_of_part_year_children?" do
          should "be valid when the part_year_child_count is less than the children_count" do
            calculator = ChildBenefitTaxCalculator.new(
              children_count: 4,
              part_year_children_count: 2,
            )

            assert calculator.valid_number_of_part_year_children?
          end

          should "not be valid when the part_year_child_count is more than the children_count" do
            calculator = ChildBenefitTaxCalculator.new(
              children_count: 2,
              part_year_children_count: 4,
            )
            assert_not calculator.valid_number_of_part_year_children?
          end

          should "not be valid if the part_year_child_count entered is 0" do
            calculator = ChildBenefitTaxCalculator.new(
              children_count: 2,
              part_year_children_count: 0,
            )

            assert_not calculator.valid_number_of_part_year_children?
          end

          should "not be valid if the part_year_child_count entered is negative" do
            calculator = ChildBenefitTaxCalculator.new(
              children_count: 2,
              part_year_children_count: -1,
            )

            assert_not calculator.valid_number_of_part_year_children?
          end
        end

        context "#valid_within_tax_year" do
          should "not be valid when before the beginning of the tax year" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2014",
            )
            calculator.part_year_claim_dates = {
              1 => {
                start_date: Date.parse("14-01-2013"),
              },
            }

            assert_not calculator.valid_within_tax_year?(:start_date)
          end

          should "not be valid when after the end of the tax year" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2014",
            )
            calculator.part_year_claim_dates = {
              1 => {
                start_date: Date.parse("14-05-2015"),
              },
            }

            assert_not calculator.valid_within_tax_year?(:start_date)
          end

          should "be valid when within the tax year" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2014",
            )
            calculator.part_year_claim_dates = {
              1 => {
                start_date: Date.parse("14-05-2014"),
              },
            }

            assert calculator.valid_within_tax_year?(:start_date)
          end
        end

        context "#valid_end_date?" do
          should "be valid if after start date" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2014",
            )
            calculator.part_year_claim_dates = {
              1 => {
                start_date: Date.parse("14-05-2014"),
                end_date: Date.parse("15-05-2014"),
              },
            }

            assert calculator.valid_end_date?
          end

          should "not be valid if before start date" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2014",
            )
            calculator.part_year_claim_dates = {
              1 => {
                start_date: Date.parse("14-05-2014"),
                end_date: Date.parse("13-05-2014"),
              },
            }

            assert_not calculator.valid_end_date?
          end
        end
      end

      context "calculating for partial children benefit years" do
        should "give the total amount for a partial tax year for two children" do
          calculator = ChildBenefitTaxCalculator.new(
            income_details: 70_000,
            tax_year: "2017",
            children_count: 2,
            part_year_children_count: 2,
          )

          calculator.part_year_claim_dates = {
            "1" => { # 2 weeks/Mondays
              start_date: Date.parse("2017-04-06"),
              end_date: Date.parse("2017-04-23"),
            },
            "2" => { # 48 weeks/mondays
              start_date: Date.parse("2017-04-06"),
              end_date: Date.parse("2018-03-05"),
            },
          }
          assert_equal 1021.0, calculator.benefits_claimed_amount.round(2)
        end

        should "gives the total amount for a partial tax year for more than two children" do
          calculator = ChildBenefitTaxCalculator.new(
            income_details: 70_000,
            tax_year: "2017",
            children_count: 2,
            part_year_children_count: 2,
          )

          calculator.part_year_claim_dates = {
            "1" => { # 2 weeks/Mondays #
              start_date: Date.parse("2017-04-06"),
              end_date: Date.parse("2017-04-23"),
            },
            "2" => { # 48 weeks/Mondays
              start_date: Date.parse("2017-04-06"),
              end_date: Date.parse("2018-03-05"),
            },
            "3" => { # 10 weeks/Mondays
              start_date: Date.parse("2017-04-06"),
              end_date: Date.parse("2017-06-15"),
            },
            "4" => { # 12 weeks/Mondays
              start_date: Date.parse("2017-08-15"),
              end_date: Date.parse("2017-11-07"),
            },
          }
          assert_equal 1322.4, calculator.benefits_claimed_amount.round(2)
        end
      end

      context "calculating child benefits received" do
        context "for the tax year 2012" do
          should "give the total amount of benefits received for a full tax year 2012" do
            assert_equal 263.9, ChildBenefitTaxCalculator.new(
              tax_year: "2012",
              children_count: 1,
            ).benefits_claimed_amount.round(2)
          end

          should "give the total amount of benefits received for a partial tax year" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2012",
              children_count: 1,
              part_year_children_count: 1,
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("2012-06-01"),
                end_date: Date.parse("2013-04-01"),
              },
            }
            assert_equal 263.9, calculator.benefits_claimed_amount.round(2)
          end
        end

        context "for the tax year 2013" do
          should "give the total amount of benefits received for a full tax year 2013" do
            assert_equal 1055.6, ChildBenefitTaxCalculator.new(
              tax_year: "2013",
              children_count: 1,
            ).benefits_claimed_amount.round(2)
          end
        end

        context "for the tax year 2019" do
          should "give the total amount received for the full tax year for one child" do
            assert_equal 1076.4, ChildBenefitTaxCalculator.new(
              tax_year: "2019",
              children_count: 1,
            ).benefits_claimed_amount.round(2)
          end

          should "give the total amount received for the full tax year for more than one child" do
            assert_equal 1788.8, ChildBenefitTaxCalculator.new(
              tax_year: "2019",
              children_count: 2,
            ).benefits_claimed_amount.round(2)
          end

          should "give the total amount for a partial tax year for one child" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2019",
              children_count: 1,
              part_year_children_count: 1,
            )
            calculator.part_year_claim_dates = {
              "0" => {
                start_date: Date.parse("2020-01-06"),
                end_date: Date.parse("2020-04-05"),
              },
            }
            assert_equal 269.1, calculator.benefits_claimed_amount.round(2)
          end

          should "give the total amount for a partial tax year for more than one child" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2019",
              children_count: 2,
              part_year_children_count: 2,
            )

            calculator.part_year_claim_dates = {
              "1" => { # 18 weeks/Mondays
                start_date: Date.parse("2019-12-2"),
                end_date: Date.parse("2020-04-05"),
              },
              "2" => { # 13 weeks/Mondays
                start_date: Date.parse("2020-01-06"),
                end_date: Date.parse("2020-04-05"),
              },
            }
            assert_equal 550.7, calculator.benefits_claimed_amount.round(2)
          end

          should "give the total amount for three children, two of which are partial tax years" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2019",
              children_count: 3,
              part_year_children_count: 2,
            )
            calculator.part_year_claim_dates = {
              "1" => { # 18 weeks/Mondays
                start_date: Date.parse("2019-12-2"),
                end_date: Date.parse("2020-04-05"),
              },
              "2" => { # 13 weeks/Mondays
                start_date: Date.parse("2020-01-06"),
                end_date: Date.parse("2020-04-05"),
              },
            }
            assert_equal 1501.1, calculator.benefits_claimed_amount.round(2)
          end
        end

        context "for the tax year 2021" do
          should "give the total amount received for the full tax year for one child" do
            assert_equal 1099.8, ChildBenefitTaxCalculator.new(
              tax_year: "2021",
              children_count: 1,
            ).benefits_claimed_amount.round(2)
          end

          should "give the total amount received for the full tax year for more than one child" do
            assert_equal 1827.8, ChildBenefitTaxCalculator.new(
              tax_year: "2021",
              children_count: 2,
            ).benefits_claimed_amount.round(2)
          end

          should "give the total amount for a partial tax year for one child" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2021",
              children_count: 1,
              part_year_children_count: 1,
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("2022-01-06"),
                end_date: Date.parse("2022-04-05"),
              },
            }
            assert_equal 274.95, calculator.benefits_claimed_amount.round(2)
          end

          should "give the total amount for a partial tax year for more than one child" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2021",
              children_count: 2,
              part_year_children_count: 2,
            )

            calculator.part_year_claim_dates = {
              "1" => { # 18 weeks/Mondays
                start_date: Date.parse("2021-12-2"),
                end_date: Date.parse("2022-04-05"),
              },
              "2" => { # 13 weeks/Mondays
                start_date: Date.parse("2022-01-06"),
                end_date: Date.parse("2022-04-05"),
              },
            }
            assert_equal 562.7, calculator.benefits_claimed_amount.round(2)
          end

          should "give the total amount for three children, two of which are partial tax years" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2021",
              children_count: 3,
              part_year_children_count: 2,
            )
            calculator.part_year_claim_dates = {
              "1" => { # 18 weeks/Mondays
                start_date: Date.parse("2021-12-2"),
                end_date: Date.parse("2022-04-05"),
              },
              "2" => { # 13 weeks/Mondays
                start_date: Date.parse("2022-01-06"),
                end_date: Date.parse("2022-04-05"),
              },
            }
            assert_equal 1533.8, calculator.benefits_claimed_amount.round(2)
          end
        end

        context "for the tax year 2022" do
          should "give the total amount received for the full tax year for one child" do
            assert_equal 1133.6, ChildBenefitTaxCalculator.new(
              tax_year: "2022",
              children_count: 1,
            ).benefits_claimed_amount.round(2)
          end

          should "give the total amount received for the full tax year for more than one child" do
            assert_equal 1885.0, ChildBenefitTaxCalculator.new(
              tax_year: "2022",
              children_count: 2,
            ).benefits_claimed_amount.round(2)
          end

          should "give the total amount for a partial tax year for one child" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2022",
              children_count: 1,
              part_year_children_count: 1,
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("2023-01-06"),
                end_date: Date.parse("2023-04-05"),
              },
            }
            assert_equal 283.4, calculator.benefits_claimed_amount.round(2)
          end

          should "give the total amount for a partial tax year for more than one child" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2022",
              children_count: 2,
              part_year_children_count: 2,
            )

            calculator.part_year_claim_dates = {
              "1" => { # 18 weeks/Mondays
                start_date: Date.parse("2022-11-28"),
                end_date: Date.parse("2023-04-03"),
              },
              "2" => { # 13 weeks/Mondays
                start_date: Date.parse("2023-01-02"),
                end_date: Date.parse("2023-04-03"),
              },
            }
            assert_equal 616.5, calculator.benefits_claimed_amount.round(2)
          end

          should "give the total amount for three children, two of which are partial tax years" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2022",
              children_count: 3,
              part_year_children_count: 2,
            )
            calculator.part_year_claim_dates = {
              "1" => { # 18 weeks/Mondays
                start_date: Date.parse("2022-11-28"),
                end_date: Date.parse("2023-04-03"),
              },
              "2" => { # 13 weeks/Mondays
                start_date: Date.parse("2023-01-02"),
                end_date: Date.parse("2023-04-03"),
              },
            }
            assert_equal 1610.45, calculator.benefits_claimed_amount.round(2)
          end
        end

        context "for the tax year 2023" do
          should "give the total amount received for the full tax year for one child" do
            assert_equal 1248.0,
                         ChildBenefitTaxCalculator.new(
                           tax_year: "2023",
                           children_count: 1,
                         ).benefits_claimed_amount.round(2)
          end

          should "give the total amount received for the full tax year for more than one child" do
            assert_equal 2074.8,
                         ChildBenefitTaxCalculator.new(
                           tax_year: "2023",
                           children_count: 2,
                         ).benefits_claimed_amount.round(2)
          end

          should "give the total amount for a partial tax year for one child" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2023",
              children_count: 1,
              part_year_children_count: 1,
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("2024-01-06"),
                end_date: Date.parse("2024-04-05"),
              },
            }
            assert_equal 312.0, calculator.benefits_claimed_amount.round(2)
          end

          should "give the total amount for a partial tax year for more than one child" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2023",
              children_count: 2,
              part_year_children_count: 2,
            )

            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("2023-11-28"),
                end_date: Date.parse("2024-04-03"),
              },
              "2" => {
                start_date: Date.parse("2024-01-02"),
                end_date: Date.parse("2024-04-03"),
              },
            }
            assert_equal 638.7, calculator.benefits_claimed_amount.round(2)
          end

          should "give the total amount for three children, two of which are partial tax years" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2023",
              children_count: 3,
              part_year_children_count: 2,
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("2023-11-28"),
                end_date: Date.parse("2024-04-03"),
              },
              "2" => {
                start_date: Date.parse("2024-01-02"),
                end_date: Date.parse("2024-04-03"),
              },
            }
            assert_equal 1740.9, calculator.benefits_claimed_amount.round(2)
          end
        end
        context "for the tax year 2024" do
          should "give the total amount received for the full tax year for one child" do
            assert_equal 1331.2,
                         ChildBenefitTaxCalculator.new(
                           tax_year: "2024",
                           children_count: 1,
                         ).benefits_claimed_amount.round(2)
          end

          should "give the total amount received for the full tax year for more than one child" do
            assert_equal 2212.6,
                         ChildBenefitTaxCalculator.new(
                           tax_year: "2024",
                           children_count: 2,
                         ).benefits_claimed_amount.round(2)
          end

          should "give the total amount for a partial tax year for one child" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2024",
              children_count: 1,
              part_year_children_count: 1,
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("2024-01-06"),
                end_date: Date.parse("2024-04-05"),
              },
            }
            assert_equal 332.8, calculator.benefits_claimed_amount.round(2)
          end

          should "give the total amount for a partial tax year for more than one child" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2024",
              children_count: 2,
              part_year_children_count: 2,
            )

            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("2024-11-28"),
                end_date: Date.parse("2025-04-03"),
              },
              "2" => {
                start_date: Date.parse("2025-01-02"),
                end_date: Date.parse("2025-04-03"),
              },
            }
            assert_equal 681.15, calculator.benefits_claimed_amount.round(2)
          end

          should "give the total amount for three children, two of which are partial tax years" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2024",
              children_count: 3,
              part_year_children_count: 2,
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("2024-11-28"),
                end_date: Date.parse("2025-04-03"),
              },
              "2" => {
                start_date: Date.parse("2025-01-02"),
                end_date: Date.parse("2025-04-03"),
              },
            }
            assert_equal 1856.65, calculator.benefits_claimed_amount.round(2)
          end
        end
      end

      context "for the tax year 2025" do
        should "give the total amount received for the full tax year for one child" do
          assert_equal 1354.6,
                       ChildBenefitTaxCalculator.new(
                         tax_year: "2025",
                         children_count: 1,
                       ).benefits_claimed_amount.round(2)
        end

        should "give the total amount received for the full tax year for more than one child" do
          assert_equal 2251.6,
                       ChildBenefitTaxCalculator.new(
                         tax_year: "2025",
                         children_count: 2,
                       ).benefits_claimed_amount.round(2)
        end

        should "give the total amount for a partial tax year for one child" do
          calculator = ChildBenefitTaxCalculator.new(
            tax_year: "2025",
            children_count: 1,
            part_year_children_count: 1,
          )
          calculator.part_year_claim_dates = {
            "1" => {
              start_date: Date.parse("2025-01-06"),
              end_date: Date.parse("2025-04-05"),
            },
          }
          assert_equal 338.65, calculator.benefits_claimed_amount.round(2)
        end

        should "give the total amount for a partial tax year for more than one child" do
          calculator = ChildBenefitTaxCalculator.new(
            tax_year: "2025",
            children_count: 2,
            part_year_children_count: 2,
          )

          calculator.part_year_claim_dates = {
            "1" => {
              start_date: Date.parse("2025-11-28"),
              end_date: Date.parse("2026-04-03"),
            },
            "2" => {
              start_date: Date.parse("2026-01-02"),
              end_date: Date.parse("2026-04-03"),
            },
          }
          assert_equal 693.15, calculator.benefits_claimed_amount.round(2)
        end

        should "give the total amount for three children, two of which are partial tax years" do
          calculator = ChildBenefitTaxCalculator.new(
            tax_year: "2025",
            children_count: 3,
            part_year_children_count: 2,
          )
          calculator.part_year_claim_dates = {
            "1" => {
              start_date: Date.parse("2025-11-28"),
              end_date: Date.parse("2026-04-03"),
            },
            "2" => {
              start_date: Date.parse("2026-01-02"),
              end_date: Date.parse("2026-04-03"),
            },
          }
          assert_equal 1889.35, calculator.benefits_claimed_amount.round(2)
        end
      end

      context "calculating adjusted net income" do
        should "calculate the adjusted net income with the relevant params" do
          assert_equal 69_950, ChildBenefitTaxCalculator.new(
            income_details: 75_500,
            allowable_deductions: 3000,
            other_allowable_deductions: 1800,
            tax_year: "2012",
            children_count: 2,
          ).calculate_adjusted_net_income
        end
      end # context "calculating adjusted net income"

      context "calculating percentage tax charge pre 2024" do
        should "be 0.0 for an income of 50099" do
          assert_equal 0.0, ChildBenefitTaxCalculator.new(
            income_details: 50_099,
            tax_year: "2012",
            children_count: 2,
          ).percent_tax_charge
        end

        should "be 1.0 for an income of 50199" do
          assert_equal 1.0, ChildBenefitTaxCalculator.new(
            income_details: 50_199,
            tax_year: "2012",
            children_count: 2,
          ).percent_tax_charge
        end

        should "be 2.0 for an income of 50200" do
          assert_equal 2.0, ChildBenefitTaxCalculator.new(
            income_details: 50_200,
            tax_year: "2012",
            children_count: 2,
          ).percent_tax_charge
        end

        should "be 40.0 for an income of 54013" do
          assert_equal 40.0, ChildBenefitTaxCalculator.new(
            income_details: 54_013,
            tax_year: "2012",
            children_count: 2,
          ).percent_tax_charge
        end

        should "be 40.0 for an income of 54089" do
          assert_equal 40.0, ChildBenefitTaxCalculator.new(
            income_details: 54_089,
            tax_year: "2012",
            children_count: 2,
          ).percent_tax_charge
        end

        should "be 99.0 for an income of 59999" do
          assert_equal 99.0, ChildBenefitTaxCalculator.new(
            income_details: 59_999,
            tax_year: "2012",
            children_count: 2,
          ).percent_tax_charge
        end

        should "be 100.0 for an income of 60000" do
          assert_equal 100.0, ChildBenefitTaxCalculator.new(
            income_details: 60_000,
            tax_year: "2012",
            children_count: 2,
          ).percent_tax_charge
        end

        should "be 100.0 for an income of 60001" do
          assert_equal 100.0, ChildBenefitTaxCalculator.new(
            income_details: 60_001,
            tax_year: "2012",
            children_count: 2,
          ).percent_tax_charge
        end
      end # calculating percentage tax charge pre 2024"

      context "calculating percentage tax charge 2024" do
        should "be 0.0 for an income of 60099" do
          assert_equal 0.0, ChildBenefitTaxCalculator.new(
            income_details: 60_099,
            tax_year: "2024",
            children_count: 2,
          ).percent_tax_charge
        end

        should "be 1.0 for an income of 60399" do
          assert_equal 1.0, ChildBenefitTaxCalculator.new(
            income_details: 60_399,
            tax_year: "2024",
            children_count: 2,
          ).percent_tax_charge
        end

        should "be 2.0 for an income of 60400" do
          assert_equal 2.0, ChildBenefitTaxCalculator.new(
            income_details: 60_400,
            tax_year: "2024",
            children_count: 2,
          ).percent_tax_charge
        end

        should "be 40.0 for an income of 68013" do
          assert_equal 40.0, ChildBenefitTaxCalculator.new(
            income_details: 68_013,
            tax_year: "2024",
            children_count: 2,
          ).percent_tax_charge
        end

        should "be 40.0 for an income of 68089" do
          assert_equal 40.0, ChildBenefitTaxCalculator.new(
            income_details: 68_089,
            tax_year: "2024",
            children_count: 2,
          ).percent_tax_charge
        end

        should "be 99.0 for an income of 79999" do
          assert_equal 99.0, ChildBenefitTaxCalculator.new(
            income_details: 79_999,
            tax_year: "2024",
            children_count: 2,
          ).percent_tax_charge
        end

        should "be 100.0 for an income of 80000" do
          assert_equal 100.0, ChildBenefitTaxCalculator.new(
            income_details: 80_000,
            tax_year: "2024",
            children_count: 2,
          ).percent_tax_charge
        end

        should "be 100.0 for an income of 80001" do
          assert_equal 100.0, ChildBenefitTaxCalculator.new(
            income_details: 80_001,
            tax_year: "2024",
            children_count: 2,
          ).percent_tax_charge
        end
      end # calculating percentage tax charge 2024"

      context "starting and stopping children" do
        context "for the tax year 2012-2013" do
          should "calculate correctly with starting children" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2012",
              income_details: 61_000,
              children_count: 1,
              part_year_children_count: 1,
            )

            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("2013-03-01"),
              },
            }
            assert_equal 101, calculator.tax_estimate.round(1)
          end

          should "not tax before Jan 7th 2013" do
            calculator = ChildBenefitTaxCalculator.new(
              income_details: 61_000,
              children_count: 1,
              part_year_children_count: 1,
              tax_year: "2012",
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("2012-05-01"),
              },
            }
            assert_equal 263, calculator.tax_estimate.round(1)
          end
        end

        context "for the tax year 2013-2014" do
          should "calculate correctly for 60k income" do
            calculator = ChildBenefitTaxCalculator.new(
              income_details: 61_000,
              children_count: 1,
              part_year_children_count: 1,
              tax_year: "2013",
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("2014-02-22"),
              },
            }

            # starting child for 6 weeks
            assert_equal 121, calculator.tax_estimate.round(1)
          end
        end # tax year 2013-14

        context "for the tax year 2016-2017" do
          should "calculate correctly with starting children" do
            calculator = ChildBenefitTaxCalculator.new(
              income_details: 61_000,
              children_count: 1,
              part_year_children_count: 1,
              tax_year: "2016",
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("2017-03-01"),
              },
            }

            # child from 01/03 to 01/04 => 5 weeks * 20.7
            assert_equal 103, calculator.tax_estimate.round(1)
          end

          should "correctly calculate weeks for a child who started & stopped in tax year" do
            calculator = ChildBenefitTaxCalculator.new(
              income_details: 61_000,
              children_count: 1,
              part_year_children_count: 1,
              tax_year: "2016",
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("2017-02-01"),
                end_date: Date.parse("2017-03-01"),
              },
            }
            # child from 01/02 to 01/03 => 4 weeks * 20.7
            assert_equal 82, calculator.tax_estimate.round(1)
          end
        end # tax year 2016
      end # starting & stopping children

      context "HMRC test scenarios" do
        context "tests for 2012 rates" do
          should "calculate 3 children already in the household for 2012/2013" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2012",
              children_count: 3,
              part_year_children_count: 3,
            )

            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("06-01-2013"),
                end_date: Date.parse("05-04-2013"),
              },
              "2" => {
                start_date: Date.parse("06-01-2013"),
                end_date: Date.parse("05-04-2013"),
              },
              "3" => {
                start_date: Date.parse("06-01-2013"),
                end_date: Date.parse("05-04-2013"),
              },
            }

            assert_equal 612.30, calculator.benefits_claimed_amount.round(2)
          end

          should "should calculate 3 children for 2012/2013, one child starting on 7 Jan 2013" do
            calculator = ChildBenefitTaxCalculator.new(
              income_details: 56_000,
              tax_year: "2012",
              children_count: 3,
              part_year_children_count: 3,
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("06-01-2013"),
                end_date: Date.parse("05-04-2013"),
              },
              "2" => {
                start_date: Date.parse("06-01-2013"),
                end_date: Date.parse("05-04-2013"),
              },
              "3" => {
                start_date: Date.parse("07-01-2013"),
                end_date: Date.parse("05-04-2013"),
              },
            }

            assert_equal 612.30, calculator.benefits_claimed_amount.round(2)
            assert_equal 367, calculator.tax_estimate
          end

          should "calculate two weeks for one child observing the 'Monday' rules for 2012/2013" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2012",
              children_count: 1,
              part_year_children_count: 1,
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("14-01-2013"),
                end_date: Date.parse("21-01-2013"),
              },
            }

            assert_equal 40.60, calculator.benefits_claimed_amount.round(2)
          end
        end # tests for 2012 rates

        context "tests for 2013 rates" do
          should "should calculate 3 children already in the household for 2013/2014" do
            calculator = ChildBenefitTaxCalculator.new(
              income_details: 52_000,
              tax_year: "2013",
              children_count: 3,
            )
            assert_equal 2449.20, calculator.benefits_claimed_amount.round(2)
            assert_equal 489, calculator.tax_estimate.round(2)
          end

          should "calculate 3 children already in the household for 2013/2014, one child stopping on 14 June 2013" do
            calculator = ChildBenefitTaxCalculator.new(
              income_details: 53_000,
              tax_year: "2013",
              children_count: 3,
              part_year_children_count: 1,
            )

            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("06-04-2013"),
                end_date: Date.parse("14-06-2013"),
              },
            }
            assert_equal 1886.40, calculator.benefits_claimed_amount.round(2)
            assert_equal 565.0, calculator.tax_estimate.round(2)
          end

          should "give an accurate figure for 40 weeks at £20.30 for 2013/2014" do
            calculator = ChildBenefitTaxCalculator.new(
              income_details: 61_000,
              tax_year: "2013",
              children_count: 1,
              part_year_children_count: 1,
            )

            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("01-07-2013"),
              },
            }

            assert_equal 812.0, calculator.benefits_claimed_amount
            assert_equal 812, calculator.tax_estimate
          end
        end # tests for 2013 rates

        context "tests for 2014 rates" do
          should "calculate 3 children already in the household for all of 2014/15" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2014",
              children_count: 3,
            )
            assert_equal 2475.2, calculator.benefits_claimed_amount.round(2)
          end

          should "give the total amount of benefits received for a full tax year 2014" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2014",
              children_count: 1,
            )
            assert_equal 1066.0, calculator.benefits_claimed_amount.round(2)
          end

          should "give total amount of benefits one child full year and one child half a year" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2014",
              children_count: 2,
              part_year_children_count: 1,
            )

            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("06-04-2014"),
                end_date: Date.parse("06-11-2014"),
              },
            }
            assert_equal 1486.05, calculator.benefits_claimed_amount.round(2)
          end

          should "give total amount of benefits for one child for half a year" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2014",
              children_count: 1,
              part_year_children_count: 1,
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("06-04-2014"),
                end_date: Date.parse("06-11-2014"),
              },
            }
            assert_equal 635.5, calculator.benefits_claimed_amount.round(2)
          end
        end # tests for 2014 rates

        context "tests for 2015 rates" do
          should "calculate 3 children already in the household for all of 2015/16" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2015",
              children_count: 3,
            )
            assert_equal 2549.3, calculator.benefits_claimed_amount.round(2)
          end

          should "give the total amount of benefits received for a full tax year 2015" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2015",
              children_count: 1,
            )
            assert_equal 1097.1, calculator.benefits_claimed_amount.round(2)
          end

          should "give total amount of benefits one child full year one child half a year" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2015",
              children_count: 2,
              part_year_children_count: 1,
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("06-04-2015"),
                end_date: Date.parse("06-10-2015"),
              },
            }
            assert_equal 1467.0, calculator.benefits_claimed_amount.round(2)
          end

          should "give total amount of benefits for one child for half a year" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2015",
              children_count: 1,
              part_year_children_count: 1,
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("06-04-2015"),
                end_date: Date.parse("06-11-2015"),
              },
            }

            assert_equal 641.7, calculator.benefits_claimed_amount.round(2)
          end
        end # tests for 2015 rates

        context "tests for 2016 rates" do
          should "calculate 3 children already in the household for all of 2016/17" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2016",
              children_count: 3,
            )
            assert_equal 2501.2, calculator.benefits_claimed_amount.round(2)
          end

          should "give the total amount of benefits received for a full tax year 2016" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2016",
              children_count: 1,
            )
            assert_equal 1076.4, calculator.benefits_claimed_amount.round(2)
          end

          should "give total amount of benefits one child full year one child half a year" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2016",
              children_count: 2,
              part_year_children_count: 1,
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("06-04-2016"),
                end_date: Date.parse("06-10-2016"),
              },
            }
            assert_equal 1432.6, calculator.benefits_claimed_amount.round(2)
          end

          should "give total amount of benefits for one child for half a year" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2016",
              children_count: 1,
              part_year_children_count: 1,
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("06-04-2016"),
                end_date: Date.parse("06-11-2016"),
              },
            }

            assert_equal 621.0, calculator.benefits_claimed_amount.round(2)
          end

          should "correctly calculate the benefit amount for multiple full year and part year children" do
            calculator = ChildBenefitTaxCalculator.new(
              tax_year: "2016",
              children_count: 4,
              part_year_children_count: 2,
            )
            calculator.part_year_claim_dates = {
              "1" => {
                start_date: Date.parse("01-06-2016"),
                end_date: Date.parse("01-09-2016"),
              },
              "2" => {
                start_date: Date.parse("01-01-2017"),
                end_date: Date.parse("01-04-2017"),
              },
            }

            assert_equal 2145, calculator.benefits_claimed_amount.round(2)
          end
        end # tests for 2016 rates
      end # HMRC test scenarios
    end # ChildBenefitTaxCalculator
  end
end
