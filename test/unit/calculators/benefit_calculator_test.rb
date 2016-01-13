require_relative '../../test_helper'

module SmartAnswer::Calculators
  class BenefitCalculatorTest < ActiveSupport::TestCase
    context BenefitCalculator do
      setup do
        @calculator = BenefitCalculator.new
      end

      context '#benefit_cap' do
        should 'default to 500' do
          assert @calculator.benefit_cap, 500
        end

        should 'return 350 when single' do
          @calculator.single_couple_lone_parent == 'single'
          assert @calculator.benefit_cap, 350
        end
      end

      context '#amount' do
        should 'default to 0' do
          assert @calculator.amount(:anything), 0
        end

        should 'return the claimed amount' do
          @calculator.claim(:maternity, 200)

          assert @calculator.amount(:maternity), 200
        end
      end

      context '#total_benefits' do
        should 'default to 0' do
          assert @calculator.total_benefits, 0
        end

        should 'sum claimed benefits' do
          @calculator.claim(:maternity, 200)
          @calculator.claim(:paternity, 200)

          assert @calculator.total_benefits, 400
        end
      end

      context '#total_over_cap' do
        should 'return total_benefits minus benefit_cap' do
          assert @calculator.total_benefits, 0
          assert @calculator.benefit_cap, 500
          assert @calculator.total_over_cap, -500

          @calculator.claim(:maternity, 200)
          @calculator.claim(:paternity, 200)

          assert @calculator.total_benefits, 400
          assert @calculator.benefit_cap, 500
          assert @calculator.total_over_cap, -100

          @calculator.single_couple_lone_parent = 'single'

          assert @calculator.total_benefits, 400
          assert @calculator.benefit_cap, 350
          assert @calculator.total_over_cap, 50
        end
      end
    end
  end
end
