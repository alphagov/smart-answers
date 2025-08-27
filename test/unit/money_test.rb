require_relative "../test_helper"

module SmartAnswer
  class MoneyTest < ActiveSupport::TestCase
    test "Can compare money with money" do
      two = SmartAnswer::Money.new("2")
      assert SmartAnswer::Money.new("2") == two
      assert SmartAnswer::Money.new("3") > two
      assert SmartAnswer::Money.new("1") < two
    end

    test "Can compare money with number" do
      m = SmartAnswer::Money.new("520")
      assert m == 520
      assert m > 1
      assert m < 1000
    end

    test "Money with spaces or commas gets parsed correctly" do
      one = SmartAnswer::Money.new("1,000")
      assert one == 1000

      two = SmartAnswer::Money.new("2 000")
      assert two == 2000
    end

    test "Values with £ sign are stripped out and parsed correctly" do
      salary = SmartAnswer::Money.new("£15000")
      assert salary == 15_000
    end

    test "should be possible to initialize with a BigDecimal" do
      v = BigDecimal("1234.5678")
      money = SmartAnswer::Money.new(v)
      assert_equal "1234.5678", money.to_s
    end

    test "should not accept negative numbers" do
      assert_raises(SmartAnswer::InvalidResponse) do
        SmartAnswer::Money.new("-1")
      end
    end

    test "should not accept numbers too big" do
      assert_raises(SmartAnswer::InvalidResponse) do
        SmartAnswer::Money.new 1_111_111_111_111_111_122_222_222_222_222_222_222_222_222_222_222_222_222_222_222_222_222_222_222_222_222_222_222_222_222_222_222_225_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_222_222_222_222_222_222_222_211_111_111_111_111_111_133_333_333_333_333_333_333_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_555_444_444_444_444_444_444_444_444_444_448_888_888_888_888_888_888_888_888_888_888_888_888_888_888_888_888_888_888_888_887_777_777_777_777_778_888_888_888_888_889_999_999_999.0 # rubocop:disable Lint/FloatOutOfRange
      end
      assert_raises(SmartAnswer::InvalidResponse) do
        SmartAnswer::Money.new "1111111111111111122222222222222222222222222222222222222222222222222222222222222222222222222222222225555555555555555555555555555555555555555555555555555555555222222222222222222222211111111111111111133333333333333333333555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555444444444444444444444444444448888888888888888888888888888888888888888888888888888888888887777777777777778888888888888889999999999.0"
      end
      assert_raises(SmartAnswer::InvalidResponse) do
        SmartAnswer::Money.new "111,1111111111111122222222222222222222222222222222222222222222222222222222222222222222222222222222225555555555555555555555555555555555555555555555555555555555222222222222222222222211111111111111111133333333333333333333555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555444444444444444444444444444448888888888888888888888888888888888888888888888888888888888887777777777777778888888888888889999999999.0"
      end
    end
  end
end
