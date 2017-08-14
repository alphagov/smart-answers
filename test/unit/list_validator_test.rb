require "test_helper"

class ListValidatorTest < ActiveSupport::TestCase
  context "#all_valid?" do
    setup do
      @list_validator = ListValidator.new(%i(a b c d))
    end

    should "returns true if list is valid" do
      assert @list_validator.all_valid?(%i(a b))
    end

    should "returns false if list contents are of different type" do
      refute @list_validator.all_valid?(%w(a b c))
    end

    should "returns false if list contents aren't valid" do
      refute @list_validator.all_valid?(%i(arbitary invalid))
    end

    should "returns false if list contains at least one invalid element" do
      refute @list_validator.all_valid?(%i(invalid a))
    end

    should "returns false if list isn't an array" do
      refute @list_validator.all_valid?("string")
    end

    should "returns false if list is empty" do
      refute @list_validator.all_valid?([])
    end

    should "returns false if list is nil" do
      refute @list_validator.all_valid?(nil)
    end
  end
end
