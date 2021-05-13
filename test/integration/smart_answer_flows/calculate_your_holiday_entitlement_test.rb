require "test_helper"

class CalculateYourHolidayEntitlementTest < ActionDispatch::IntegrationTest
  setup do
    stub_content_store_has_item("/calculate-your-holiday-entitlement")
  end

  context "compressed hours outcome" do
    should "render the correct results page" do
      get "/calculate-your-holiday-entitlement/y/compressed-hours/full-year/40/5"
      assert_select "p", "The statutory holiday entitlement is 224 hours and 0 minutes holiday for the year. Rather than taking a day’s holiday it’s 8 hours and 0 minutes holiday for each day otherwise worked."
    end
  end

  context "days per week outcome" do
    should "render the correct results page" do
      get "/calculate-your-holiday-entitlement/y/days-worked-per-week/full-year/5"
      assert_select "p", "The statutory holiday entitlement is 28 days holiday."
    end
  end

  context "hours per week outcome" do
    should "render the correct results page" do
      get "/calculate-your-holiday-entitlement/y/hours-worked-per-week/full-year/40/5"
      assert_select "p", "The statutory entitlement is 224 hours holiday."
    end
  end

  context "irregular and annualised outcome" do
    should "render the correct results page" do
      get "/calculate-your-holiday-entitlement/y/annualised-hours/full-year"
      assert_select "p", "The statutory holiday entitlement is 5.6 weeks holiday."
    end
  end

  context "shift worker outcome" do
    should "render the correct results page" do
      get "/calculate-your-holiday-entitlement/y/shift-worker/full-year/6/8/14"
      assert_select "p", "The statutory holiday entitlement is 22.4 shifts for the year. Each shift being 6.0 hours."
    end
  end

  context "start and end date - non-shift worker" do
    should "render the correct results page" do
      get "/calculate-your-holiday-entitlement/y/days-worked-per-week/starting-and-leaving/2021-01-01/2021-10-01/5.0"
      assert_select "p", "The statutory holiday entitlement is 21.1 days holiday."
    end
  end

  context "start and end date - shift worker" do
    should "render the correct results page" do
      get "/calculate-your-holiday-entitlement/y/shift-worker/starting/2021-01-01/2020-10-01/8.0/7/7.0"
      assert_select "p", "The statutory holiday entitlement is 21 shifts for the year. Each shift being 8.0 hours."
    end
  end
end
