# coding:utf-8

require_relative '../test_helper'

module SmartAnswer
  class MoneyTest < ActiveSupport::TestCase
    test "Can compare money with money" do
      two = Money.new("2")
      assert Money.new("2") == two
      assert Money.new("3") > two
      assert Money.new("1") < two
    end                           

    test "Can compare money with number" do
      m = Money.new("520")
      assert m == 520
      assert m > 1
      assert m < 1000
    end                           
    
    test "Money with spaces or commas gets parsed correctly" do
      one = Money.new("1,000")                        
      assert one == 1000
      
      two = Money.new("2 000")
      assert two == 2000
    end
  end
end