require_relative '../../test_helper'

module SmartAnswer::Calculators
  class BenefitCalculatorTest < ActiveSupport::TestCase
    context BenefitCalculator do
      setup do
        @calculator = BenefitCalculator.new
      end

      context '#benefit_cap' do
        should 'default value' do
          assert_equal @calculator.benefit_cap, 384
        end

        should 'return 350 when single' do
          @calculator.single_couple_lone_parent = 'single'
          assert_equal @calculator.benefit_cap, 257
        end
      end

      context '#amount' do
        should 'default to 0' do
          assert_equal @calculator.amount(:anything), 0
        end

        should 'return the claimed amount' do
          @calculator.claim(:maternity, 200)

          assert_equal @calculator.amount(:maternity), 200
        end
      end

      context '#total_benefits' do
        should 'default to 0' do
          assert_equal @calculator.total_benefits, 0
        end

        should 'sum claimed benefits' do
          @calculator.claim(:maternity, 200)
          @calculator.claim(:paternity, 100)

          assert_equal @calculator.total_benefits, 300
        end
      end

      context '#total_over_cap' do
        should 'return total_benefits minus benefit_cap' do
          assert_equal @calculator.total_benefits, 0
          assert_equal @calculator.benefit_cap, 384
          assert_equal @calculator.total_over_cap, -384

          @calculator.claim(:maternity, 200)
          @calculator.claim(:paternity, 100)

          assert_equal @calculator.total_benefits, 300
          assert_equal @calculator.benefit_cap, 384
          assert_equal @calculator.total_over_cap, -84

          @calculator.single_couple_lone_parent = 'single'

          assert_equal @calculator.total_benefits, 300
          assert_equal @calculator.benefit_cap, 257
          assert_equal @calculator.total_over_cap, 43
        end
      end
    end
  end
end
