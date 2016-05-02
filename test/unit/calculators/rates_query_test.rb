require_relative "../../test_helper"

module SmartAnswer::Calculators
  class RatesQueryTest < ActiveSupport::TestCase
    context "#rates" do
      setup do
        load_path = File.join("test", "fixtures", "rates")
        @test_rate = RatesQuery.from_file('exact_date_rates', load_path: load_path)
      end

      should "be 1 for 2013-01-31" do
        assert_equal 1, @test_rate.rates(Date.parse('2013-01-31')).rate
      end

      should "be 2 for 2013-02-01" do
        assert_equal 2, @test_rate.rates(Date.parse('2013-02-01')).rate
      end

      should "be the latest known rate (2) for uncovered future dates" do
        assert_equal 2, @test_rate.rates(Date.parse('2113-03-12')).rate
      end

      context 'given a rate has been loaded for one date' do
        should 'return the correct rate for a different date' do
          assert_equal 1, @test_rate.rates(Date.parse('2013-01-31')).rate
          assert_equal 2, @test_rate.rates(Date.parse("2013-02-01")).rate
        end
      end

      context 'with various dates' do
        setup do
          today = Date.today
          @yesterday = today - 1.day
          @tomorrow = today + 1.day

          yesterdays_rates = {
            start_date: @yesterday,
            end_date: @yesterday,
            rate: 3
          }
          todays_rates = {
            start_date: today,
            end_date: today,
            rate: 2
          }
          tomorrows_rates = {
            start_date: @tomorrow,
            end_date: @tomorrow,
            rate: 1
          }
          rates = [yesterdays_rates, todays_rates, tomorrows_rates]
          @rates_query = RatesQuery.new(rates)
        end

        should "return rate for date specified when calling the method" do
          assert_equal 3, @rates_query.rates(@yesterday).rate
        end

        should "return rate for date specified in RATES_QUERY_DATE environment variable if set" do
          begin
            ENV['RATES_QUERY_DATE'] = @tomorrow.to_s

            assert_equal 1, @rates_query.rates.rate
          ensure
            ENV['RATES_QUERY_DATE'] = nil
          end
        end

        should "return rate for today when no date is specified" do
          assert_equal 2, @rates_query.rates.rate
        end
      end
    end

    context 'register a death fees' do
      context 'for 2015/16' do
        setup do
          @rates_query = RatesQuery.from_file('register_a_death')
          @sixth_april_2015 = Date.parse('2015-04-06')
        end

        should 'be £105 for registering a death' do
          assert_equal 105, @rates_query.rates(@sixth_april_2015).register_a_death
        end

        should 'be £65 for a copy of the death registration certificate' do
          assert_equal 65, @rates_query.rates(@sixth_april_2015).copy_of_death_registration_certificate
        end
      end

      context 'for 2016/17' do
        setup do
          @rates_query = RatesQuery.from_file('register_a_death')
          @sixth_april_2016 = Date.parse('2016-04-06')
        end

        should 'be £150 for registering a death' do
          assert_equal 150, @rates_query.rates(@sixth_april_2016).register_a_death
        end

        should 'be £50 for a copy of the death registration certificate' do
          assert_equal 50, @rates_query.rates(@sixth_april_2016).copy_of_death_registration_certificate
        end
      end
    end

    context 'register a birth fees' do
      context 'for 2015/16' do
        setup do
          @rates_query = RatesQuery.from_file('register_a_birth')
          @sixth_april_2015 = Date.parse('2015-04-06')
        end

        should 'be £105 for registering a birth' do
          assert_equal 105, @rates_query.rates(@sixth_april_2015).register_a_birth
        end

        should 'be £65 for a copy of the birth registration certificate' do
          assert_equal 65, @rates_query.rates(@sixth_april_2015).copy_of_birth_registration_certificate
        end
      end

      context 'for 2016/17' do
        setup do
          @rates_query = RatesQuery.from_file('register_a_birth')
          @sixth_april_2016 = Date.parse('2016-04-06')
        end

        should 'be £150 for registering a birth' do
          assert_equal 150, @rates_query.rates(@sixth_april_2016).register_a_birth
        end

        should 'be £50 for a copy of the birth registration certificate' do
          assert_equal 50, @rates_query.rates(@sixth_april_2016).copy_of_birth_registration_certificate
        end
      end
    end
  end
end
