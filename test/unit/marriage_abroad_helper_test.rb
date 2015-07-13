require_relative '../test_helper'

module SmartAnswer
  class MarriageAbroadHelperTest < ActiveSupport::TestCase
    include MarriageAbroadHelper

    test '#ceremony_type returns "Marriage" for opposite sex ceremonies' do
      assert_equal 'Marriage', ceremony_type('opposite_sex')
    end

    test '#ceremony_type returns "Civil partnership" for same sex ceremonies' do
      assert_equal 'Civil partnership', ceremony_type('same_sex')
    end
  end
end
