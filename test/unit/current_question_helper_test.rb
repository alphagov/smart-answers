require_relative "../test_helper"

class CurrentQuestionHelperTest < ActionView::TestCase
  tests CurrentQuestionHelper

  context "default_for_date" do
    should "return nil for a nil input" do
      default = default_for_date(nil)
      assert_nil(default)
    end

    should "return nil for an empty string input" do
      default = default_for_date("")
      assert_nil(default)
    end

    should "return nil for an array input" do
      default = default_for_date(%w(foo bar))
      assert_nil(default)
    end

    should "return an integer for an integer input" do
      default = default_for_date(1)
      assert_equal(1, default)
    end

    should "return an integer for a zero input" do
      default = default_for_date(0)
      assert_equal(0, default)
    end

    should "return an integer for a numerical string input" do
      default = default_for_date("1")
      assert_equal(1, default)
    end

    should "return nil for a non-numerical string input" do
      default = default_for_date("foo")
      assert_nil(default)
    end

    should "return nil for a float input" do
      default = default_for_date(1.1)
      assert_nil(default)
    end
  end
end
