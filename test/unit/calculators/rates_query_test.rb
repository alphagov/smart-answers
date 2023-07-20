require_relative "../../test_helper"

module SmartAnswer::Calculators
  class RatesQueryTest < ActiveSupport::TestCase
    context "#rates" do
      setup do
        @test_rate = RatesQuery.from_file(
          "exact_date_rates",
          load_path: "test/fixtures/rates",
        )
      end

      should "be 1 for 2013-01-31" do
        assert_equal 1, @test_rate.rates(Date.parse("2013-01-31")).rate
      end

      should "be 2 for 2013-02-01" do
        assert_equal 2, @test_rate.rates(Date.parse("2013-02-01")).rate
      end

      should "be the latest known rate (2) for uncovered future dates" do
        assert_equal 2, @test_rate.rates(Date.parse("2113-03-12")).rate
      end

      context "given a rate has been loaded for one date" do
        should "return the correct rate for a different date" do
          assert_equal 1, @test_rate.rates(Date.parse("2013-01-31")).rate
          assert_equal 2, @test_rate.rates(Date.parse("2013-02-01")).rate
        end
      end

      context "with various dates" do
        setup do
          today = Time.zone.today
          @yesterday = today - 1.day
          @tomorrow = today + 1.day

          yesterdays_rates = {
            start_date: @yesterday,
            end_date: @yesterday,
            rate: 3,
          }
          todays_rates = {
            start_date: today,
            end_date: today,
            rate: 2,
          }
          tomorrows_rates = {
            start_date: @tomorrow,
            end_date: @tomorrow,
            rate: 1,
          }
          rates = [yesterdays_rates, todays_rates, tomorrows_rates]
          @rates_query = RatesQuery.new(rates)
        end

        should "return rate for date specified when calling the method" do
          assert_equal 3, @rates_query.rates(@yesterday).rate
        end

        should "return rate for date specified in RATES_QUERY_DATE environment variable if set" do
          ENV["RATES_QUERY_DATE"] = @tomorrow.to_s

          assert_equal 1, @rates_query.rates.rate
        ensure
          ENV["RATES_QUERY_DATE"] = nil
        end

        should "return rate for today when no date is specified" do
          assert_equal 2, @rates_query.rates.rate
        end
      end
    end

    context "#previous_period" do
      setup do
        @test_rate = RatesQuery.from_file(
          "exact_date_rates",
          load_path: "test/fixtures/rates",
        )
      end

      should "be nil for 2013-01-31" do
        assert_nil @test_rate.previous_period(date: Date.parse("2013-01-31"))
      end

      should "be 2013-01-31 for 2013-02-01" do
        assert_equal Date.parse("2012-01-01"), @test_rate.previous_period(date: Date.parse("2013-02-01"))[:start_date]
      end
    end
  end
end
