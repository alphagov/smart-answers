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

    test '#ceremony_type_lowercase returns "marriage" for opposite sex ceremonies' do
      assert_equal 'marriage', ceremony_type_lowercase('opposite_sex')
    end

    test '#ceremony_type_lowercase returns "civil partnership" for same sex ceremonies' do
      assert_equal 'civil partnership', ceremony_type_lowercase('same_sex')
    end

    test '#specific_local_authorities returns a name of local authorities in parenthesis leaded by a space' do
      assert_equal ' (the town hall or the local priest)', specific_local_authorities('greece')
    end

    test '#specific_local_authorities returns an empty string if local authorities in country are not specified' do
      assert_equal '', specific_local_authorities('narnia')
    end
  end
end
