require_relative '../../test_helper'

#TODO Other contexts

module SmartAnswer::Calculators
  class ChildBenefitTaxCalculatorTest < ActiveSupport::TestCase

    setup do
      @calc = ChildBenefitTaxCalculator.new :child_benefit_start_date => Date.new(2012, 4, 6)
    end

    context "end date = 20/3/2013" do
      setup do
        @calc.child_benefit_end_date = Date.new(2013, 3, 20)
      end

      context "only child" do
        setup do
          @calc.children_claiming = 1
        end

        should "calculate the number of weeks for which benefit was claimed" do
          assert_equal 50, @calc.benefit_claimed_weeks
        end

        should "calculate the number of taxable weeks" do
          assert_equal 10, @calc.benefit_taxable_weeks
        end

        should "calculate the total amount of benefit claimed" do
          assert_equal SmartAnswer::Money.new(1015), @calc.benefit_claimed_amount
        end

        should "calculate the total amount of benefit claimed in taxable weeks" do
          assert_equal SmartAnswer::Money.new(203), @calc.benefit_taxable_amount
        end

        context "income = 65,000" do
          setup do
            @calc.income = SmartAnswer::Money.new 65000
          end

          should "calculate the % tax charge" do
            assert_equal 100, @calc.percent_tax_charge
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(203), @calc.benefit_tax
          end
        end # context - income = 65,000

        context "income = 54,000" do
          setup do
            @calc.income = SmartAnswer::Money.new 54000
          end

          should "calculate the % tax charge" do
            assert_equal 40, @calc.percent_tax_charge
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(81.20), @calc.benefit_tax
          end
        end # context - income = 54,000
      end # context - only child
      
      context "4 children" do
        setup do
          @calc.children_claiming = 4
        end

        should "calculate the number of weeks for which benefit was claimed" do
          assert_equal 50, @calc.benefit_claimed_weeks
        end

        should "calculate the number of taxable weeks" do
          assert_equal 10, @calc.benefit_taxable_weeks
        end

        should "calculate the total amount of benefit claimed" do
          assert_equal SmartAnswer::Money.new(3025), @calc.benefit_claimed_amount
        end

        should "calculate the total amount of benefit claimed in taxable weeks" do
          assert_equal SmartAnswer::Money.new(605), @calc.benefit_taxable_amount
        end

        context "income = 65,000" do
          setup do
            @calc.income = SmartAnswer::Money.new 65000
          end

          should "calculate the % tax charge" do
            assert_equal 100, @calc.percent_tax_charge
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(605), @calc.benefit_tax
          end
        end # context - income = 65,000

        context "income = 54,000" do
          setup do
            @calc.income = SmartAnswer::Money.new 54000
          end

          should "calculate the % tax charge" do
            assert_equal 40, @calc.percent_tax_charge
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(242), @calc.benefit_tax
          end
        end # context - income = 54,000
      end # context - 4 children
    end # context - end date = 20/3/2013

    context "end date = 8/8/2012" do
      setup do
        @calc.child_benefit_end_date = Date.new(2012, 8, 8)
      end

      context "only child" do
        setup do
          @calc.children_claiming = 1
        end

        should "calculate the number of weeks for which benefit was claimed" do
          assert_equal 18, @calc.benefit_claimed_weeks
        end

        should "calculate the number of taxable weeks" do
          assert_equal 0, @calc.benefit_taxable_weeks
        end

        should "calculate the total amount of benefit claimed" do
          assert_equal SmartAnswer::Money.new(365.4), @calc.benefit_claimed_amount
        end

        should "calculate the total amount of benefit claimed in taxable weeks" do
          assert_equal SmartAnswer::Money.new(0), @calc.benefit_taxable_amount
        end

        context "income = 65,000" do
          setup do
            @calc.income = SmartAnswer::Money.new 65000
          end

          should "calculate the % tax charge" do
            assert_equal 100, @calc.percent_tax_charge
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(0), @calc.benefit_tax
          end
        end # context - income = 65,000

        context "income = 54,000" do
          setup do
            @calc.income = SmartAnswer::Money.new 54000
          end

          should "calculate the % tax charge" do
            assert_equal 40, @calc.percent_tax_charge
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(0), @calc.benefit_tax
          end
        end # context - income = 54,000
      end # context - only child
      
      context "4 children" do
        setup do
          @calc.children_claiming = 4
        end

        should "calculate the number of weeks for which benefit was claimed" do
          assert_equal 18, @calc.benefit_claimed_weeks
        end

        should "calculate the number of taxable weeks" do
          assert_equal 0, @calc.benefit_taxable_weeks
        end

        should "calculate the total amount of benefit claimed" do
          assert_equal SmartAnswer::Money.new(1089), @calc.benefit_claimed_amount
        end

        should "calculate the total amount of benefit claimed in taxable weeks" do
          assert_equal SmartAnswer::Money.new(0), @calc.benefit_taxable_amount
        end

        context "income = 65,000" do
          setup do
            @calc.income = SmartAnswer::Money.new 65000
          end

          should "calculate the % tax charge" do
            assert_equal 100, @calc.percent_tax_charge
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(0), @calc.benefit_tax
          end
        end # context - income = 65,000

        context "income = 54,000" do
          setup do
            @calc.income = SmartAnswer::Money.new 54000
          end

          should "calculate the % tax charge" do
            assert_equal 40, @calc.percent_tax_charge
          end

          should "calculate the benefit tax" do
            assert_equal SmartAnswer::Money.new(0), @calc.benefit_tax
          end
        end # context - income = 54,000
      end # context - 4 children
    end # context - end date = 8/8/2012
  end
end
