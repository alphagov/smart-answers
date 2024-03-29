require_relative "../../test_helper"

module SmartAnswer::Calculators
  class RegisterADeathRatesQueryTest < ActiveSupport::TestCase
    setup do
      @rates_query = RatesQuery.from_file("register_a_death")
    end

    context "The current and last dates in the file" do
      setup do
        @rate_array = [
          @rates_query.rates,
          @rates_query.rates(Date.parse("2999-01-01")),
        ]
      end

      should "respond_to #register_a_death" do
        @rate_array.each { |r| assert_respond_to(r, :register_a_death) }
      end

      should "respond_to #copy_of_death_registration_certificate" do
        @rate_array.each { |r| assert_respond_to(r, :copy_of_death_registration_certificate) }
      end
    end
  end
end
