require_relative '../../lib/data/state_pension_date'
require_relative '../test_helper'

class StatePensionDateTest < ActiveSupport::TestCase

  context '#born_in_range' do
    setup do
      @pension_date = StatePensionDate.new(:female, Date.parse('6 April 1950'), Date.parse('5 May 1950'), Date.parse('6 May 2010'))
    end

    should 'return false for a date before the start date' do
      assert_not @pension_date.born_in_range?(Date.parse('5 April 1950'))
    end

    should 'return true for a date on exactly the start date' do
      assert @pension_date.born_in_range?(Date.parse('6 April 1950'))
    end

    should 'return true for a date within the start and end date' do
      assert @pension_date.born_in_range?(Date.parse('7 April 1950'))
      assert @pension_date.born_in_range?(Date.parse('4 May 1950'))
    end

    should 'return true for a date exactly on the end date' do
      assert @pension_date.born_in_range?(Date.parse('5 May 1950'))
    end

    should 'return false for a date just outside the end date' do
      assert_not @pension_date.born_in_range?(Date.parse('6 May 1950'))
    end
  end

  context '#same_gender?' do

    context 'with a pension date for females' do
      setup do
        @pension_date = StatePensionDate.new(:female, Date.parse('6 April 1950'), Date.parse('5 May 1950'), Date.parse('6 May 2010'))
      end

      should 'return true for female' do
        assert @pension_date.same_gender?(:female)
      end

      should 'return false for male' do
        assert_not @pension_date.same_gender?(:male)
      end
    end

    context 'with a pension date for males' do
      setup do
        @pension_date = StatePensionDate.new(:male, Date.parse('6 April 1950'), Date.parse('5 May 1950'), Date.parse('6 May 2010'))
      end

      should 'return false for female' do
        assert_not @pension_date.same_gender?(:female)
      end

      should 'return true for male' do
        assert @pension_date.same_gender?(:male)
      end
    end

    context 'with a pension date for both genders' do
      setup do
        @pension_date = StatePensionDate.new(:both, Date.parse('6 April 1950'), Date.parse('5 May 1950'), Date.parse('6 May 2010'))
      end

      should 'return true for female' do
        assert @pension_date.same_gender?(:female)
      end

      should 'return true for male' do
        assert @pension_date.same_gender?(:male)
      end
    end
  end

  context '#match?' do
    setup do
      @pension_date = StatePensionDate.new(:female, Date.parse('6 April 1950'), Date.parse('5 May 1950'), Date.parse('6 May 2010'))
    end

    should 'return false if same_gender? is false' do
      @pension_date.match?(Date.parse('6 April 1950'), :male)
    end

    should 'return false if born_in_range? is false' do
      @pension_date.match?(Date.parse('5 April 1950'), :female)
    end

    should 'return true when both same_gender? && born_in_range? return true' do
      @pension_date.match?(Date.parse('6 April 1950'), :female)
    end
  end
end
