require_relative "../../test_helper"

module SmartAnswer::Calculators
  class RegistrationsDataQueryTest < ActiveSupport::TestCase
    context RegistrationsDataQuery do
      setup do
        @described_class = RegistrationsDataQuery
        @query = @described_class.new
      end
      context "registration_data method" do
        should "read registrations data" do
          assert_equal Hash, @query.data.class
        end
      end
      context "has_consulate?" do
        should "be true for countries with a consulate" do
          assert @query.has_consulate?("russia")
          assert_not @query.has_consulate?("uganda")
        end
      end

      context "#register_a_death_fees" do
        should "instantiate RatesQuery using register_a_death data" do
          rates_query = stub(rates: "register-a-death-rates")
          RatesQuery.stubs(:from_file).with("register_a_death").returns(rates_query)

          assert_equal "register-a-death-rates", RegistrationsDataQuery.new.register_a_death_fees
        end
      end
    end
  end
end
