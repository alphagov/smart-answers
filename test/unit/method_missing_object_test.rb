require_relative '../test_helper'

class MethodMissingObjectTest < ActiveSupport::TestCase
  setup do
    @object = MethodMissingObject.new(:method_one)
  end

  should 'allow call to unknown method' do
    assert_nothing_raised(NoMethodError) { @object.method_two }
  end

  should 'use method name as description' do
    assert_equal :method_one, @object.description
  end

  should 'use description within ERB tags as to_s' do
    assert_equal '<%= method_one %>', @object.to_s
  end

  should 'mark string returned from to_s as being HTML-safe' do
    assert @object.to_s.html_safe?
  end

  context 'child object' do
    setup do
      @child = @object.method_two
    end

    should 'allow call to unknown method' do
      assert_nothing_raised(NoMethodError) { @child.method_three }
    end

    should 'use chained method names as description' do
      assert_equal 'method_one.method_two', @child.description
    end
  end

  context 'when object has blank to_s' do
    setup do
      @object = MethodMissingObject.new(:method_one, nil, true)
    end

    should 'return empty string from to_s' do
      assert_equal '', @object.to_s
    end

    should 'allow call to unknown method' do
      assert_nothing_raised(NoMethodError) { @object.method_two }
    end

    context 'child object' do
      setup do
        @child = @object.method_two
      end

      should 'return empty string from to_s' do
        assert_equal '', @child.to_s
      end
    end
  end
end
