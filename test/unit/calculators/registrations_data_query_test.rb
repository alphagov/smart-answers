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
      context "commonwealth_country? method" do
        should "indicate whether a country slug refers to a commonwealth country" do
          assert @query.commonwealth_country?("australia")
          refute @query.commonwealth_country?("spain")
        end
      end
      context "has_consulate?" do
        should "be true for countries with a consulate" do
          assert @query.has_consulate?("russia")
          refute @query.has_consulate?("uganda")
        end
      end

      context "higher_risk_country?" do
        should "be true for higher risk countries" do
          assert @query.higher_risk_country?("afghanistan")
          refute @query.higher_risk_country?("france")
        end
      end

      context "lower_risk_country?" do
        should "be true for lower risk countries" do
          assert @query.lower_risk_country?("france")
          refute @query.lower_risk_country?("afghanistan")
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

      context "oru_documents_variant_for_birth?" do
        should "be true for Netherlands" do
          assert @query.oru_documents_variant_for_birth?("netherlands")
        end

        should "be true for Belgium" do
          assert @query.oru_documents_variant_for_birth?("belgium")
        end

        should "be false for Argentina" do
          refute @query.oru_documents_variant_for_birth?("argentina")
        end
      end

      context "oru_documents_variant_for_death?" do
        should "return true for Papua New Guinea" do
          assert @query.oru_documents_variant_for_death?("papua-new-guinea")
        end

        should "return false for Argentina" do
          refute @query.oru_documents_variant_for_death?("argentina")
        end
      end

      context "oru_courier_variant?" do
        should "return true for countries in the list" do
          assert @query.oru_courier_variant?("cambodia")
        end

        should "return false for countries not in the list" do
          refute @query.oru_courier_variant?("argentina")
        end
      end

      context "oru_courier_by_high_commission?" do
        should "return true for countries in the list" do
          assert @query.oru_courier_by_high_commission?("cameroon")
        end

        should "return false for countries not in the list" do
          refute @query.oru_courier_by_high_commission?("argentina")
        end
      end

      context "fetching document return fees" do
        context "when before 2015-08-01" do
          setup do
            Timecop.travel("2015-07-31")
          end

          should "display 4.50, 12.50 and 22" do
            assert_equal "£4.50", @query.document_return_fees.post_to_uk
            assert_equal "£12.50", @query.document_return_fees.post_to_europe
            assert_equal "£22", @query.document_return_fees.post_to_rest_of_the_world
          end
        end

        context "on and after 2015-08-01" do
          setup do
            Timecop.travel("2015-08-01")
          end

          should "display 4.50, 12.50 and 22" do
            assert_equal "£5.50", @query.document_return_fees.post_to_uk
            assert_equal "£14.50", @query.document_return_fees.post_to_europe
            assert_equal "£25", @query.document_return_fees.post_to_rest_of_the_world
          end
        end
      end

      context "#register_a_birth_fees" do
        should "instantiate RatesQuery using register_a_birth data" do
          rates_query = stub(rates: "register-a-birth-rates")
          RatesQuery.stubs(:from_file).with("register_a_birth").returns(rates_query)

          assert_equal "register-a-birth-rates", RegistrationsDataQuery.new.register_a_birth_fees
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
