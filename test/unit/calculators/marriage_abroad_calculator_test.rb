require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class MarriageAbroadCalculatorTest < ActiveSupport::TestCase
      context '#partner_british?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if partner is british' do
          @calculator.partner_nationality = 'partner_british'
          assert @calculator.partner_british?
        end

        should 'be false if partner is not british' do
          @calculator.partner_nationality = 'not-partner_british'
          refute @calculator.partner_british?
        end
      end

      context '#partner_not_british?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if partner is not british' do
          @calculator.partner_nationality = 'not-partner_british'
          assert @calculator.partner_not_british?
        end

        should 'be false if partner is british' do
          @calculator.partner_nationality = 'partner_british'
          refute @calculator.partner_not_british?
        end
      end

      context '#partner_is_national_of_ceremony_country?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if partner is a national of the ceremony country' do
          @calculator.partner_nationality = 'partner_local'
          assert @calculator.partner_is_national_of_ceremony_country?
        end

        should 'be false if partner is not a national of the ceremony country' do
          @calculator.partner_nationality = 'not-partner_local'
          refute @calculator.partner_is_national_of_ceremony_country?
        end
      end

      context '#partner_is_not_national_of_ceremony_country?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if partner is not a national of the ceremony country' do
          @calculator.partner_nationality = 'not-partner_local'
          assert @calculator.partner_is_not_national_of_ceremony_country?
        end

        should 'be false if partner is a national of the ceremony country' do
          @calculator.partner_nationality = 'partner_local'
          refute @calculator.partner_is_not_national_of_ceremony_country?
        end
      end

      context '#partner_is_neither_british_nor_a_national_of_ceremony_country?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if partner is a national of a country other than britain or the ceremony country' do
          @calculator.partner_nationality = 'partner_other'
          assert @calculator.partner_is_neither_british_nor_a_national_of_ceremony_country?
        end

        should 'be false if partner is not a national of a country other than britain or the ceremony country' do
          @calculator.partner_nationality = 'not-partner_other'
          refute @calculator.partner_is_neither_british_nor_a_national_of_ceremony_country?
        end
      end

      context '#resident_of_uk?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if resident of uk' do
          @calculator.resident_of = 'uk'
          assert @calculator.resident_of_uk?
        end

        should 'be false if not a resident of uk' do
          @calculator.resident_of = 'not-uk'
          refute @calculator.resident_of_uk?
        end
      end

      context '#resident_outside_of_uk?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if not resident of uk' do
          @calculator.resident_of = 'not-uk'
          assert @calculator.resident_outside_of_uk?
        end

        should 'be false if resident of uk' do
          @calculator.resident_of = 'uk'
          refute @calculator.resident_outside_of_uk?
        end
      end

      context '#resident_of_ceremony_country?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if resident of ceremony country' do
          @calculator.resident_of = 'ceremony_country'
          assert @calculator.resident_of_ceremony_country?
        end

        should 'be false if not resident of ceremony country' do
          @calculator.resident_of = 'not-ceremony_country'
          refute @calculator.resident_of_ceremony_country?
        end
      end

      context '#resident_outside_of_ceremony_country?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if not resident of ceremony country' do
          @calculator.resident_of = 'not-ceremony_country'
          assert @calculator.resident_outside_of_ceremony_country?
        end

        should 'be false if resident of ceremony country' do
          @calculator.resident_of = 'ceremony_country'
          refute @calculator.resident_outside_of_ceremony_country?
        end
      end

      context '#resident_of_third_country?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if resident of third country' do
          @calculator.resident_of = 'third_country'
          assert @calculator.resident_of_third_country?
        end

        should 'be false if not resident of third country' do
          @calculator.resident_of = 'not-third_country'
          refute @calculator.resident_of_third_country?
        end
      end

      context '#resident_outside_of_third_country?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if resident_of != "third_country"' do
          @calculator.resident_of = 'not-third_country'
          assert @calculator.resident_outside_of_third_country?
        end

        should 'be false if resident_of == "third_country"' do
          @calculator.resident_of = 'third_country'
          refute @calculator.resident_outside_of_third_country?
        end
      end

      context '#partner_is_opposite_sex?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true when partner is of the opposite sex' do
          @calculator.sex_of_your_partner = 'opposite_sex'
          assert @calculator.partner_is_opposite_sex?
        end

        should 'be false when partner is not of the opposite sex' do
          @calculator.sex_of_your_partner = 'not-opposite_sex'
          refute @calculator.partner_is_opposite_sex?
        end
      end

      context '#partner_is_same_sex?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true when partner is of the same sex' do
          @calculator.sex_of_your_partner = 'same_sex'
          assert @calculator.partner_is_same_sex?
        end

        should 'be false when partner is not of the same sex' do
          @calculator.sex_of_your_partner = 'not-same_sex'
          refute @calculator.partner_is_same_sex?
        end
      end

      context '#want_to_get_married?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true when the couple want to get married' do
          @calculator.marriage_or_pacs = 'marriage'
          assert @calculator.want_to_get_married?
        end

        should "be false when the couple don't want to get married" do
          @calculator.marriage_or_pacs = 'not-marriage'
          refute @calculator.want_to_get_married?
        end
      end

      context '#world_location' do
        setup do
          @calculator = MarriageAbroadCalculator.new
          @calculator.ceremony_country = 'ceremony-country'
        end

        should 'return the world location for the given ceremony country' do
          WorldLocation.stubs(:find).with('ceremony-country').returns('world-location')

          assert_equal 'world-location', @calculator.world_location
        end

        should 'raise an InvalidResponse exception if the world location cannot be found for the ceremony country' do
          WorldLocation.stubs(:find).with('ceremony-country').returns(nil)

          assert_raise(InvalidResponse) do
            @calculator.world_location
          end
        end
      end

      context '#fco_organisation' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'return the fco organisation for the world location' do
          fco_organisation = stub.quacks_like(WorldwideOrganisation.new({}))
          world_location = stub.quacks_like(WorldLocation.new({}))
          world_location.stubs(:fco_organisation).returns(fco_organisation)
          WorldLocation.stubs(:find).with('ceremony-country-with-fco-organisation').returns(world_location)
          @calculator.ceremony_country = 'ceremony-country-with-fco-organisation'

          assert_equal fco_organisation, @calculator.fco_organisation
        end

        should "return nil if the world location doesn't have an fco organisation" do
          world_location = stub.quacks_like(WorldLocation.new({}))
          world_location.stubs(:fco_organisation).returns(nil)
          WorldLocation.stubs(:find).with('ceremony-country-without-fco-organisation').returns(world_location)
          @calculator.ceremony_country = 'ceremony-country-without-fco-organisation'

          assert_nil @calculator.fco_organisation
        end
      end

      context '#overseas_passports_embassies' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'return the offices that offer registrations of marriage and civil partnerships' do
          world_office = stub('World Office')
          organisation = stub.quacks_like(WorldwideOrganisation.new({}))
          organisation.stubs(:offices_with_service).with('Registrations of Marriage and Civil Partnerships').returns([world_office])
          @calculator.stubs(:fco_organisation).returns(organisation)

          assert_equal [world_office], @calculator.overseas_passports_embassies
        end

        should 'return an empty array when there is no fco organisation' do
          @calculator.stubs(:fco_organisation).returns(nil)

          assert_equal [], @calculator.overseas_passports_embassies
        end
      end

      context '#marriage_and_partnership_phrases' do
        setup do
          @data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          @data_query.stubs(:ss_marriage_countries?).returns(false)
          @data_query.stubs(:ss_marriage_countries_when_couple_british?).returns(false)
          @data_query.stubs(:ss_marriage_and_partnership?).returns(false)
          @calculator = MarriageAbroadCalculator.new(data_query: @data_query)
        end

        should 'return ss_marriage when the ceremony country is in the list of same sex marriage countries' do
          @calculator.ceremony_country = 'same-sex-marriage-country'
          @data_query.stubs(:ss_marriage_countries?).with('same-sex-marriage-country').returns(true)

          assert_equal 'ss_marriage', @calculator.marriage_and_partnership_phrases
        end

        should 'return ss_marriage when the ceremony country is in the list of same sex marriage countries for british couples' do
          @calculator.ceremony_country = 'same-sex-marriage-country-for-british-couple'
          @data_query.stubs(:ss_marriage_countries_when_couple_british?).with('same-sex-marriage-country-for-british-couple').returns(true)

          assert_equal 'ss_marriage', @calculator.marriage_and_partnership_phrases
        end

        should 'return ss_marriage_and_partnership when the ceremony country is in the list of same sex marriage and partnership countries' do
          @calculator.ceremony_country = 'same-sex-marriage-and-partnership-country'
          @data_query.stubs(:ss_marriage_and_partnership?).with('same-sex-marriage-and-partnership-country').returns(true)

          assert_equal 'ss_marriage_and_partnership', @calculator.marriage_and_partnership_phrases
        end
      end
    end
  end
end
