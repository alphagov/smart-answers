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
      context "nonregistrable_country? method" do
        should "indicate whether a country slug refers to a nonregistrable country" do
          assert @query.nonregistrable_country?("australia")
          assert_not @query.nonregistrable_country?("spain")
        end
      end
      context "has_consulate?" do
        should "be true for countries with a consulate" do
          assert @query.has_consulate?("russia")
          assert_not @query.has_consulate?("uganda")
        end
      end

      context "registration_country_slug" do
        should "map the country to a registration country if one exists" do
          assert_equal "spain", @query.registration_country_slug("andorra")
        end
        should "give the original if no mapping exists" do
          assert_equal "spain", @query.registration_country_slug("spain")
        end
      end

      context "oru_documents_variant_for_death?" do
        should "return true for Papua New Guinea" do
          assert @query.oru_documents_variant_for_death?("papua-new-guinea")
        end

        should "return false for Argentina" do
          assert_not @query.oru_documents_variant_for_death?("argentina")
        end
      end

      context "oru_courier_variant?" do
        should "return true for countries in the list" do
          assert @query.oru_courier_variant?("cambodia")
        end

        should "return false for countries not in the list" do
          assert_not @query.oru_courier_variant?("argentina")
        end
      end

      context "oru_courier_by_high_commission?" do
        should "return true for countries in the list" do
          assert @query.oru_courier_by_high_commission?("cameroon")
        end

        should "return false for countries not in the list" do
          assert_not @query.oru_courier_by_high_commission?("argentina")
        end
      end

      context "fetching document return fees" do
        should "support post_to_(uk|europe|rest_of_the_world) methods" do
          assert_respond_to(@query.document_return_fees, :post_to_uk)
          assert_respond_to(@query.document_return_fees, :post_to_europe)
          assert_respond_to(@query.document_return_fees, :post_to_rest_of_the_world)
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
