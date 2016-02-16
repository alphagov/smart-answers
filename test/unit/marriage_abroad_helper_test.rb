require_relative '../test_helper'
require 'smart_answer/calculators/marriage_abroad_calculator'

module SmartAnswer
  class MarriageAbroadHelperTest < ActiveSupport::TestCase
    include MarriageAbroadHelper
    include SmartAnswer::Calculators

    test '#ceremony_type returns "Marriage" for opposite sex ceremonies' do
      calculator = MarriageAbroadCalculator.new
      calculator.sex_of_your_partner = 'opposite_sex'
      assert_equal 'Marriage', ceremony_type(calculator)
    end

    test '#ceremony_type returns "Civil partnership" for same sex ceremonies' do
      calculator = MarriageAbroadCalculator.new
      calculator.sex_of_your_partner = 'same_sex'
      assert_equal 'Civil partnership', ceremony_type(calculator)
    end

    test '#ceremony_type_lowercase returns "marriage" for opposite sex ceremonies' do
      calculator = MarriageAbroadCalculator.new
      calculator.sex_of_your_partner = 'opposite_sex'
      assert_equal 'marriage', ceremony_type_lowercase(calculator)
    end

    test '#ceremony_type_lowercase returns "civil partnership" for same sex ceremonies' do
      calculator = MarriageAbroadCalculator.new
      calculator.sex_of_your_partner = 'same_sex'
      assert_equal 'civil partnership', ceremony_type_lowercase(calculator)
    end

    test '#specific_local_authorities returns a name of local authorities in parenthesis leaded by a space' do
      assert_equal ' (the town hall or the local priest)', specific_local_authorities('greece')
    end

    test '#specific_local_authorities returns an empty string if local authorities in country are not specified' do
      assert_equal '', specific_local_authorities('narnia')
    end
  end
end
