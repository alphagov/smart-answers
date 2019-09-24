require_relative "../test_helper"

module SmartAnswer
  class FormattingHelperTest < ActiveSupport::TestCase
    include FormattingHelper

    test "#format_money accepts large formatted values" do
      assert_equal "£1,234.56", format_money("1,234.56")
      assert_equal "-£1,234.56", format_money("-1,234.56")
    end

    test "#format_money doesn't add pence for amounts in whole pounds, or for amounts that round to whole pounds" do
      assert_equal "£1", format_money("1.00")
      assert_equal "£1", format_money(SmartAnswer::Money.new("1.00"))
      assert_equal "£1", format_money("1.00001")
      assert_equal "£1", format_money(SmartAnswer::Money.new(1.00001))

      assert_equal "-£1", format_money("-1.00")
      assert_equal "-£1", format_money(SmartAnswer::Money.new(-1.00))
      assert_equal "-£1", format_money("-1.00001")
      assert_equal "-£1", format_money(SmartAnswer::Money.new(-1.00001))
    end

    test "#format_money adds pence for amounts that aren't whole pounds" do
      assert_equal "£1.23", format_money("1.23")
      assert_equal "£1.23", format_money(SmartAnswer::Money.new("1.23"))

      assert_equal "-£1.23", format_money("-1.23")
      assert_equal "-£1.23", format_money(SmartAnswer::Money.new(-1.23))
    end

    test "#format_money doesn't use pounds for amounts less than £1 and greater than -£1" do
      assert_equal "10p", format_money("0.10")
      assert_equal "10p", format_money(SmartAnswer::Money.new("0.10"))

      assert_equal "-10p", format_money("-0.10")
      assert_equal "-10p", format_money(SmartAnswer::Money.new(-0.10))
    end

    test "#format_money leaves the value in pounds if it is exactly 0, or rounds to 0" do
      assert_equal "£0", format_money("0")
      assert_equal "£0", format_money(SmartAnswer::Money.new("0"))

      assert_equal "£0", format_money("0.00001")
      assert_equal "£0", format_money(SmartAnswer::Money.new(0.00001))
    end

    test "#format_money doesn't use leading 0s for amounts less than 10p" do
      assert_equal "5p", format_money("0.05")
      assert_equal "5p", format_money(SmartAnswer::Money.new("0.05"))

      assert_equal "-5p", format_money("-0.05")
      assert_equal "-5p", format_money(SmartAnswer::Money.new(-0.05))
    end

    test "#format_money can be asked to ignore pence" do
      assert_equal "£1", format_money("1.23", pounds_only: true)
      assert_equal "£1", format_money(SmartAnswer::Money.new("1.23"), pounds_only: true)
    end

    test '#format_date returns the date formatted using "%e %B %Y"' do
      assert_equal " 1 January 2015", format_date(Date.parse("2015-01-01"))
    end

    test "#format_date returns nil when the value is nil" do
      assert_nil format_date(nil)
    end

    test "#format_salary returns whole number of pounds plus the period in which it was earned" do
      assert_equal "£123 per week", format_salary(Salary.new("123.45", "week"))
    end
  end
end
