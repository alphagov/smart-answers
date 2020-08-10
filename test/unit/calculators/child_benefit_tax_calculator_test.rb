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
              0 => {
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
              0 => {
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
              0 => {
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
              0 => {
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
              0 => {
                start_date: Date.parse("14-05-2014"),
                end_date: Date.parse("13-05-2014"),
              },
            }

            assert_not calculator.valid_end_date?
          end
        end
      end
    end # ChildBenefitTaxCalculator
  end
end
