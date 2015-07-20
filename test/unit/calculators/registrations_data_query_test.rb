require_relative "../../test_helper"

module SmartAnswer::Calculators
  class RegistrationsDataQueryTest < ActiveSupport::TestCase
    context RegistrationsDataQuery do
      setup do
        @described_class = SmartAnswer::Calculators::RegistrationsDataQuery
        @query = @described_class.new
      end
      context "registration_data method" do
        should "read registrations data" do
          assert_equal Hash, @query.data.class
        end
      end
      context "commonwealth_country? method" do
        should "indicate whether a country slug refers to a commonwealth country" do
          assert @query.commonwealth_country?('australia')
          refute @query.commonwealth_country?('spain')
        end
      end
      context "has_high_commission?" do
        should "be true for countries with a high commission" do
          assert @query.has_high_commission?('trinidad-and-tobago')
          refute @query.has_high_commission?('australia')
        end
      end
      context "has_consulate?" do
        should "be true for countries with a consulate" do
          assert @query.has_consulate?('russia')
          refute @query.has_consulate?('uganda')
        end
      end
      context "cash_only?" do
        should "be true for countries that only accept cash" do
          assert @query.cash_only?('iceland')
          refute @query.cash_only?('spain')
        end
      end
      context "register_death_by_post?" do
        should "be true for countries that allow registration by post" do
          assert @query.register_death_by_post?('barbados')
          refute @query.register_death_by_post?('afghanistan')
        end
      end
      context "postal_form" do
        should "give the form url if it exists" do
          assert_equal "/government/publications/passport-credit-debit-card-payment-authorisation-slip-austria", @query.postal_form('austria')
          refute @query.postal_form('usa')
        end
      end
      context "postal_return_form" do
        should "give the form url if it exists" do
          assert_equal "/government/publications/registered-post-return-delivery-form-italy", @query.postal_return_form('italy')
          refute @query.postal_return_form('belgium')
        end
      end
      context "registration_country_slug" do
        should "map the country to a registration country if one exists" do
          assert_equal "spain", @query.registration_country_slug('andorra')
        end
        should "give the original if no mapping exists" do
          assert_equal "spain", @query.registration_country_slug('spain')
        end
      end

      context "oru transition countries" do
        should "be true for Wallis and Fortuna" do
          assert @described_class::ORU_TRANSITIONED_COUNTRIES.include?('wallis-and-futuna')
        end

        should "be true for Martinique" do
          assert @described_class::ORU_TRANSITIONED_COUNTRIES.include?('martinique')
          refute @described_class::ORU_TRANSITIONED_COUNTRIES.include?('ireland')
        end
      end

      context "oru birth documents variant countries" do
        should "be true for Netherlands" do
          assert @described_class::ORU_DOCUMENTS_VARIANT_COUNTRIES_BIRTH.include?('netherlands')
        end

        should "be true for Belgium" do
          assert @described_class::ORU_DOCUMENTS_VARIANT_COUNTRIES_BIRTH.include?('belgium')
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
    end
  end
end
