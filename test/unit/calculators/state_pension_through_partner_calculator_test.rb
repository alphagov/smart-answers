require_relative '../../test_helper'

module SmartAnswer::Calculators
  class StatePensionThroughPartnerCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = StatePensionThroughPartnerCalculator.new
    end

    context 'widow_and_new_pension?' do
      context 'you reached pension age before specific date' do
        setup do
          @calculator.when_will_you_reach_pension_age = 'your_pension_age_before_specific_date'
        end

        should 'be false when widowed' do
          @calculator.marital_status = 'widowed'
          refute @calculator.widow_and_new_pension?
        end

        should 'be false when married' do
          @calculator.marital_status = 'married'
          refute @calculator.widow_and_new_pension?
        end

        should 'be false when divorced' do
          @calculator.marital_status = 'divorced'
          refute @calculator.widow_and_new_pension?
        end
      end

      context 'you reached pension age after specific date' do
        setup do
          @calculator.when_will_you_reach_pension_age = 'your_pension_age_after_specific_date'
        end

        should 'be true when widowed' do
          @calculator.marital_status = 'widowed'
          assert @calculator.widow_and_new_pension?
        end

        should 'be false when married' do
          @calculator.marital_status = 'married'
          refute @calculator.widow_and_new_pension?
        end

        should 'be false when divorced' do
          @calculator.marital_status = 'divorced'
          refute @calculator.widow_and_new_pension?
        end
      end
    end
  end
end
