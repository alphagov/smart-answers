require "test_helper"

class ListValidatorTest < ActiveSupport::TestCase
  context "#all_valid?" do
    setup do
      @list_validator = ListValidator.new(%i[a b c d])
    end

    should "returns true if list is valid" do
      assert @list_validator.all_valid?(%i[a b])
    end

    should "returns false if list contents are of different type" do
      assert_not @list_validator.all_valid?(%w[a b c])
    end

    should "returns false if list contents aren't valid" do
      assert_not @list_validator.all_valid?(%i[arbitary invalid])
    end

    should "returns false if list contains at least one invalid element" do
      assert_not @list_validator.all_valid?(%i[invalid a])
    end

    should "returns false if list isn't an array" do
      assert_not @list_validator.all_valid?("string")
    end

    should "returns false if list is empty" do
      assert_not @list_validator.all_valid?([])
    end

    should "returns false if list is nil" do
      assert_not @list_validator.all_valid?(nil)
    end
  end

  context ".call" do
    setup do
      @constraint = { a: 1, b: 1 }
    end

    should "return true if test sample within contraint keys" do
      assert ListValidator.call(constraint: @constraint, test: [:a])
    end

    should "return true if test sample within contraint keys and a string" do
      assert ListValidator.call(constraint: @constraint, test: %w[a])
    end

    should "return false if test sample not with contraint keys" do
      assert_not ListValidator.call(constraint: @constraint, test: [:x])
    end
  end
end
