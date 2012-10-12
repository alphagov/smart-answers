require_relative '../../test_helper'

#TODO Other contexts

module SmartAnswer::Calculators
  class ChildBenefitTaxCalculatorTest < ActiveSupport::TestCase

    setup do
      @calc = ChildBenefitTaxCalculator.new
    end

    context "tax year 2012-13" do
      setup do
        @calc.start_of_tax_year = Date.new(2012, 4, 6)
        @calc.end_of_tax_year = Date.new(2013, 4, 5)
      end

      context "percent tax charge test 1" do
        setup do
          @calc.income = 50199
        end

        should "return 1% percent tax charge for 50199" do
          assert_equal 1, @calc.percent_tax_charge
        end
      end

      context "percent tax charge test 2" do
        setup do
          @calc.income = 60000
        end

        should "return 99% percent tax charge for 50199" do
          assert_equal 99, @calc.percent_tax_charge
        end
      end


      context "only child for full year" do
        setup do
          @calc.claim_periods = [Date.new(2012, 4, 6)..Date.new(2013, 4, 5)]
        end

        should "calculate the total amount of benefit claimed" do
          assert_equal SmartAnswer::Money.new(1055.6), @calc.benefit_claimed_amount
        end

        should "calculate the total amount of benefit claimed in taxable weeks" do
          assert_equal SmartAnswer::Money.new(263.90), @calc.benefit_taxable_amount
        end

        context "income >= 60001" do
          setup do
            @calc.income = 60001
          end

          should "calculate the % tax charge" do
            assert_equal 100, @calc.percent_tax_charge
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(263.90), @calc.benefit_tax
          end
        end # context - income >= 60001

        context "income == 55000" do
          setup do
            @calc.income = 55000
          end

          should "calculate the % tax charge" do
            assert_equal 50, @calc.percent_tax_charge
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(131.95), @calc.benefit_tax
          end
        end # context - income >= 50000

        context "income == 50000" do
          setup do
            @calc.income = 50000
          end

          should "calculate the % tax charge" do
            assert_equal 0, @calc.percent_tax_charge
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(0), @calc.benefit_tax
          end
        end # context - income >= 50000

      end # context - only child

      context "one child for full year, one child starting partial year" do
        setup do
          @calc.claim_periods = [Date.new(2012, 4, 6)..Date.new(2013, 4, 5), Date.new(2012, 9, 1)..Date.new(2013, 4, 5)]
        end

        should "calculate the total amount of benefit claimed" do
          assert_equal SmartAnswer::Money.new(1471), @calc.benefit_claimed_amount
        end

        should "calculate the total amount of benefit claimed in taxable weeks" do
          assert_equal SmartAnswer::Money.new(438.10), @calc.benefit_taxable_amount
        end

        context "income >= 60001" do
          setup do
            @calc.income = 60001
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(438.10), @calc.benefit_tax
          end
        end # context - income >= 60001
      end # context - one child for full year, one child starting partial year

      context "one child for full year, one child ending partial year" do
        setup do
          @calc.claim_periods = [Date.new(2012, 4, 6)..Date.new(2013, 4, 5), Date.new(2012, 4, 6)..Date.new(2013, 2, 14)]
        end

        should "calculate the total amount of benefit claimed" do
          assert_equal SmartAnswer::Money.new(1658.60), @calc.benefit_claimed_amount
        end

        should "calculate the total amount of benefit claimed in taxable weeks" do
          assert_equal SmartAnswer::Money.new(344.30), @calc.benefit_taxable_amount
        end

        context "income == 55000" do
          setup do
            @calc.income = 55000
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(172.15), @calc.benefit_tax
          end
        end # context - income >= 60000
      end # context - one child for full year, one child ending partial year

      context "two children for full year, one child starting partial year, one child ending partial year" do
        setup do
          @calc.claim_periods = [Date.new(2012, 4, 6)..Date.new(2013, 4, 5), Date.new(2012, 4, 6)..Date.new(2013, 4, 5), Date.new(2012, 9, 1)..Date.new(2013, 4, 5), Date.new(2012, 4, 6)..Date.new(2013, 2, 14)]
        end

        should "calculate the total amount of benefit claimed" do
          assert_equal SmartAnswer::Money.new(2770.80), @calc.benefit_claimed_amount
        end

        should "calculate the total amount of benefit claimed in taxable weeks" do
          assert_equal SmartAnswer::Money.new(692.70), @calc.benefit_taxable_amount
        end

        context "income == 55000" do
          setup do
            @calc.income = 55000
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(346.35), @calc.benefit_tax
          end
        end # context - income >= 60000
      end # context - one child for full year, one child starting partial year, one child ending partial year
    end # context - tax year 2012-13

    context "tax year 2013-14" do
      setup do
        @calc.start_of_tax_year = Date.new(2013, 4, 6)
        @calc.end_of_tax_year = Date.new(2014, 4, 5)
      end

      context "one child for full year" do
        setup do
          @calc.claim_periods = [Date.new(2013, 4, 6)..Date.new(2014, 4, 5)]
        end

        should "calculate the total amount of benefit claimed" do
          assert_equal SmartAnswer::Money.new(1055.60), @calc.benefit_claimed_amount
        end

        should "calculate the total amount of benefit claimed in taxable weeks" do
          assert_equal SmartAnswer::Money.new(1055.60), @calc.benefit_taxable_amount
        end

        context "income >= 60001" do
          setup do
            @calc.income = 60001
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(1055.60), @calc.benefit_tax
          end
        end # context - income >= 60000
      end # context - one child for full year

      context "one child for full year, one child starting partial year" do
        setup do
          @calc.claim_periods = [Date.new(2013, 4, 6)..Date.new(2014, 4, 5), Date.new(2013, 9, 1)..Date.new(2014, 4, 5)]
        end

        should "calculate the total amount of benefit claimed" do
          assert_equal SmartAnswer::Money.new(1471), @calc.benefit_claimed_amount
        end

        should "calculate the total amount of benefit claimed in taxable weeks" do
          assert_equal SmartAnswer::Money.new(1471), @calc.benefit_taxable_amount
        end

        context "income >= 60001" do
          setup do
            @calc.income = 60001
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(1471), @calc.benefit_tax
          end
        end # context - income >= 60000
      end # context - one child for full year, one child starting partial year

      context "two children for full year, one child starting partial year, one child ending partial year" do
        setup do
          @calc.claim_periods = [Date.new(2013, 4, 6)..Date.new(2014, 4, 5), Date.new(2013, 4, 6)..Date.new(2014, 4, 5), Date.new(2013, 9, 1)..Date.new(2014, 4, 5), Date.new(2013, 4, 6)..Date.new(2014, 2, 14)]
        end

        should "calculate the total amount of benefit claimed" do
          assert_equal SmartAnswer::Money.new(2770.80), @calc.benefit_claimed_amount
        end

        should "calculate the total amount of benefit claimed in taxable weeks" do
          assert_equal SmartAnswer::Money.new(2770.80), @calc.benefit_taxable_amount
        end

        context "income == 55000" do
          setup do
            @calc.income = 55000
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(1385.40), @calc.benefit_tax
          end
        end # context - income >= 60001
      end # context - one child for full year, one child starting partial year, one child ending partial year
    end
  end
end
