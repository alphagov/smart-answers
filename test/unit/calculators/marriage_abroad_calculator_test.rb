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
      end

      context '#valid_ceremony_country?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'return true if the world location can be found' do
          @calculator.stubs(:world_location).returns(stub('world-location'))

          assert @calculator.valid_ceremony_country?
        end

        should 'return false if the world location cannot be found' do
          @calculator.stubs(:world_location).returns(nil)

          refute @calculator.valid_ceremony_country?
        end
      end

      context '#fco_organisation' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'return the fco organisation for the world location' do
          fco_organisation = stub.quacks_like(WorldwideOrganisation.new({}))
          world_location = stub.quacks_like(WorldLocation.new({}))
          world_location.stubs(fco_organisation: fco_organisation)
          WorldLocation.stubs(:find).with('ceremony-country-with-fco-organisation').returns(world_location)
          @calculator.ceremony_country = 'ceremony-country-with-fco-organisation'

          assert_equal fco_organisation, @calculator.fco_organisation
        end

        should "return nil if the world location doesn't have an fco organisation" do
          world_location = stub.quacks_like(WorldLocation.new({}))
          world_location.stubs(fco_organisation: nil)
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
          @calculator.stubs(fco_organisation: organisation)

          assert_equal [world_office], @calculator.overseas_passports_embassies
        end

        should 'return an empty array when there is no fco organisation' do
          @calculator.stubs(fco_organisation: nil)

          assert_equal [], @calculator.overseas_passports_embassies
        end
      end

      context '#marriage_and_partnership_phrases' do
        setup do
          @data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          @data_query.stubs(
            ss_marriage_countries?: false,
            ss_marriage_countries_when_couple_british?: false,
            ss_marriage_and_partnership?: false
          )
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

      context '#ceremony_country_name' do
        should 'return the name of the world location associated with the ceremony country' do
          world_location = stub.quacks_like(WorldLocation.new({}))
          world_location.stubs(name: 'world-location-name')
          calculator = MarriageAbroadCalculator.new
          calculator.stubs(world_location: world_location)

          assert_equal 'world-location-name', calculator.ceremony_country_name
        end
      end

      context '#country_name_lowercase_prefix' do
        setup do
          @country_name_formatter = stub.quacks_like(CountryNameFormatter.new)
          @calculator = MarriageAbroadCalculator.new(country_name_formatter: @country_name_formatter)
          @calculator.ceremony_country = 'country-slug'
        end

        should 'return the definitive article if ceremony country is in the list of countries with definitive article' do
          @country_name_formatter.stubs(:requires_definite_article?).with('country-slug').returns(true)
          @country_name_formatter.stubs(:definitive_article).with('country-slug').returns('the-country-name')

          assert_equal 'the-country-name', @calculator.country_name_lowercase_prefix
        end

        should 'return the friendly country name if definitive article not required and friendly country name found' do
          @country_name_formatter.stubs(:requires_definite_article?).with('country-slug').returns(false)
          @country_name_formatter.stubs(:has_friendly_name?).with('country-slug').returns(true)
          @country_name_formatter.stubs(:friendly_name).with('country-slug').returns('friendly-country-name')

          assert_equal 'friendly-country-name', @calculator.country_name_lowercase_prefix
        end

        should 'return an html safe version of the friendly country name' do
          @country_name_formatter.stubs(:requires_definite_article?).with('country-slug').returns(false)
          @country_name_formatter.stubs(:has_friendly_name?).with('country-slug').returns(true)
          @country_name_formatter.stubs(:friendly_name).with('country-slug').returns('friendly-country-name')

          assert @calculator.country_name_lowercase_prefix.html_safe?
        end

        should 'return the ceremony country name if not in the list of definitive articles or friendly country names' do
          @country_name_formatter.stubs(:requires_definite_article?).with('country-slug').returns(false)
          @country_name_formatter.stubs(:has_friendly_name?).with('country-slug').returns(false)
          @calculator.stubs(ceremony_country_name: 'country-name')

          assert_equal 'country-name', @calculator.country_name_lowercase_prefix
        end
      end

      context '#country_name_uppercase_prefix' do
        setup do
          @country_name_formatter = stub.quacks_like(CountryNameFormatter.new)
          @calculator = MarriageAbroadCalculator.new(country_name_formatter: @country_name_formatter)
          @calculator.ceremony_country = 'country-slug'
        end

        should 'return the ceremony country with upper case definite article' do
          @country_name_formatter.stubs(:definitive_article).with('country-slug', true).returns('The-country-name')

          assert_equal 'The-country-name', @calculator.country_name_uppercase_prefix
        end
      end

      context '#country_name_partner_residence' do
        setup do
          @data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          @data_query.stubs(
            british_overseas_territories?: false,
            french_overseas_territories?: false,
            dutch_caribbean_islands?: false
          )

          @calculator = MarriageAbroadCalculator.new(data_query: @data_query)
          @calculator.ceremony_country = 'country-slug'
        end

        should 'return "British (overseas territories citizen)" when ceremony country is British overseas territory' do
          @data_query.stubs(:british_overseas_territories?).with('country-slug').returns(true)

          assert_equal 'British (overseas territories citizen)', @calculator.country_name_partner_residence
        end

        should 'return "French" when ceremony country is French overseas territory' do
          @data_query.stubs(:french_overseas_territories?).with('country-slug').returns(true)

          assert_equal 'French', @calculator.country_name_partner_residence
        end

        should 'return "Dutch" when ceremony country is in the Dutch Caribbean islands' do
          @data_query.stubs(:dutch_caribbean_islands?).with('country-slug').returns(true)

          assert_equal 'Dutch', @calculator.country_name_partner_residence
        end

        should 'return "Chinese" when ceremony country is Hong Kong' do
          @calculator.ceremony_country = 'hong-kong'

          assert_equal 'Chinese', @calculator.country_name_partner_residence
        end

        should 'return "Chinese" when ceremony country is Macao' do
          @calculator.ceremony_country = 'macao'

          assert_equal 'Chinese', @calculator.country_name_partner_residence
        end

        should 'return "National of <country_name_lowercase_prefix>" in all other cases' do
          @calculator.stubs(country_name_lowercase_prefix: 'country-name-lowercase-prefix')

          assert_equal 'National of country-name-lowercase-prefix', @calculator.country_name_partner_residence
        end
      end

      context '#embassy_or_consulate_ceremony_country' do
        setup do
          @registrations_data_query = stub.quacks_like(RegistrationsDataQuery.new)
          @registrations_data_query.stubs(
            has_consulate?: false,
            has_consulate_general?: false
          )

          @calculator = MarriageAbroadCalculator.new(registrations_data_query: @registrations_data_query)
          @calculator.ceremony_country = 'country-slug'
        end

        should 'return "consulate" if ceremony country has consulate' do
          @registrations_data_query.stubs(:has_consulate?).with('country-slug').returns(true)

          assert_equal 'consulate', @calculator.embassy_or_consulate_ceremony_country
        end

        should 'return "consulate" if ceremony country has consulate general' do
          @registrations_data_query.stubs(:has_consulate_general?).with('country-slug').returns(true)

          assert_equal 'consulate', @calculator.embassy_or_consulate_ceremony_country
        end

        should 'return "embassy" if ceremony country has neither consulate nor consulate general' do
          assert_equal 'embassy', @calculator.embassy_or_consulate_ceremony_country
        end
      end

      context '#ceremony_country_is_french_overseas_territory?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:french_overseas_territories?).with('ceremony-country').returns('french-overseas-territory')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'french-overseas-territory', calculator.ceremony_country_is_french_overseas_territory?
        end
      end

      context '#opposite_sex_consular_cni_country' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:os_consular_cni_countries?).with('ceremony-country').returns('opposite-sex-consular-cni-country')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'opposite-sex-consular-cni-country', calculator.opposite_sex_consular_cni_country?
        end
      end

      context '#opposite_sex_consular_cni_in_nearby_country?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:os_consular_cni_in_nearby_country?).with('ceremony-country').returns('opposite-sex-consular-cni-in-nearby-country')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'opposite-sex-consular-cni-in-nearby-country', calculator.opposite_sex_consular_cni_in_nearby_country?
        end
      end

      context '#opposite_sex_no_marriage_related_consular_services_in_ceremony_country?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:os_no_marriage_related_consular_services?).with('ceremony-country').returns('opposite-sex-no-marriage-related-consular-servies')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'opposite-sex-no-marriage-related-consular-servies', calculator.opposite_sex_no_marriage_related_consular_services_in_ceremony_country?
        end
      end

      context '#opposite_sex_affirmation_country?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:os_affirmation_countries?).with('ceremony-country').returns('opposite-sex-affirmation-country')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'opposite-sex-affirmation-country', calculator.opposite_sex_affirmation_country?
        end
      end

      context '#ceremony_country_in_the_commonwealth' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:commonwealth_country?).with('ceremony-country').returns('commonwealth-country')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'commonwealth-country', calculator.ceremony_country_in_the_commonwealth?
        end
      end

      context '#ceremony_country_is_british_overseas_territory?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:british_overseas_territories?).with('ceremony-country').returns('british-overseas-territory')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'british-overseas-territory', calculator.ceremony_country_is_british_overseas_territory?
        end
      end

      context '#opposite_sex_no_consular_cni_country' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:os_no_consular_cni_countries?).with('ceremony-country').returns('opposite-sex-no-consular-cni-country')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'opposite-sex-no-consular-cni-country', calculator.opposite_sex_no_consular_cni_country?
        end
      end

      context '#opposite_sex_marriage_via_local_authorities?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:os_marriage_via_local_authorities?).with('ceremony-country').returns('opposite-sex-marriage-via-local-authorities')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'opposite-sex-marriage-via-local-authorities', calculator.opposite_sex_marriage_via_local_authorities?
        end
      end

      context '#same_sex_ceremony_country_unknown_or_has_no_embassies?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:ss_unknown_no_embassies?).with('ceremony-country').returns('unknown-or-no-embassies')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'unknown-or-no-embassies', calculator.same_sex_ceremony_country_unknown_or_has_no_embassies?
        end
      end

      context '#same_sex_marriage_not_possible?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          data_query.stubs(:ss_marriage_not_possible?).with('ceremony-country', calculator).returns('same-sex-marriage-not-possible')
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'same-sex-marriage-not-possible', calculator.same_sex_marriage_not_possible?
        end
      end

      context '#same_sex_marriage_country?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:ss_marriage_countries?).with('ceremony-country').returns('same-sex-marriage-country')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'same-sex-marriage-country', calculator.same_sex_marriage_country?
        end
      end

      context '#same_sex_marriage_country_when_couple_british?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:ss_marriage_countries_when_couple_british?).with('ceremony-country').returns('same-sex-marriage-country-when-couple-british')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'same-sex-marriage-country-when-couple-british', calculator.same_sex_marriage_country_when_couple_british?
        end
      end

      context '#same_sex_marriage_and_civil_partnership?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:ss_marriage_and_partnership?).with('ceremony-country').returns('same-sex-marriage-and-civil-partnership')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'same-sex-marriage-and-civil-partnership', calculator.same_sex_marriage_and_civil_partnership?
        end
      end

      context 'civil_partnership_equivalent_country?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:cp_equivalent_countries?).with('ceremony-country').returns('civil-partnership-equivalent-country')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'civil-partnership-equivalent-country', calculator.civil_partnership_equivalent_country?
        end
      end

      context 'civil_partnership_cni_not_required_country?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:cp_cni_not_required_countries?).with('ceremony-country').returns('civil-partnership-cni-not-required-country')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'civil-partnership-cni-not-required-country', calculator.civil_partnership_cni_not_required_country?
        end
      end

      context 'civil_partnership_consular_country?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:cp_consular_countries?).with('ceremony-country').returns('civil-partnership-consular-country')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'civil-partnership-consular-country', calculator.civil_partnership_consular_country?
        end
      end

      context 'country_without_consular_facilities?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:countries_without_consular_facilities?).with('ceremony-country').returns('country-without-consular-facilities')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'country-without-consular-facilities', calculator.country_without_consular_facilities?
        end
      end

      context 'opposite_sex_21_days_residency_required?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:os_21_days_residency_required_countries?).with('ceremony-country').returns('21-days-residency-required')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal '21-days-residency-required', calculator.opposite_sex_21_days_residency_required?
        end
      end

      context 'ceremony_country_is_dutch_caribbean_island?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:dutch_caribbean_islands?).with('ceremony-country').returns('dutch-caribbean-island')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'dutch-caribbean-island', calculator.ceremony_country_is_dutch_caribbean_island?
        end
      end

      context 'requires_7_day_notice?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:requires_7_day_notice?).with('ceremony-country').returns('requires-7-day-notice')
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'requires-7-day-notice', calculator.requires_7_day_notice?
        end
      end

      context 'same_sex_alt_fees_table_country?' do
        should 'delegate to the data query' do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          calculator = MarriageAbroadCalculator.new(data_query: data_query)
          data_query.stubs(:ss_alt_fees_table_country?).with('ceremony-country', calculator).returns('same-sex-alt-fees-table')
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'same-sex-alt-fees-table', calculator.same_sex_alt_fees_table_country?
        end
      end

      context '#civil_partnership_institution_name' do
        should 'return "High Commission" if the ceremony country is cyprus' do
          calculator = MarriageAbroadCalculator.new
          calculator.ceremony_country = 'cyprus'
          assert_equal 'High Commission', calculator.civil_partnership_institution_name
        end

        should 'return "British embassy or consulate" if the ceremony country is not cyprus' do
          calculator = MarriageAbroadCalculator.new
          calculator.ceremony_country = 'not-cyprus'
          assert_equal 'British embassy or consulate', calculator.civil_partnership_institution_name
        end
      end

      context '#outcome_path_when_resident_in_uk' do
        should 'build the path' do
          calculator = MarriageAbroadCalculator.new
          calculator.ceremony_country = 'ceremony-country'
          calculator.partner_nationality = 'partner-nationality'
          calculator.sex_of_your_partner = 'sex-of-your-partner'

          expected_path = '/marriage-abroad/y/ceremony-country/uk/partner-nationality/sex-of-your-partner'
          assert_equal expected_path, calculator.outcome_path_when_resident_in_uk
        end
      end

      context '#outcome_path_when_resident_in_ceremony_country' do
        should 'build the path' do
          calculator = MarriageAbroadCalculator.new
          calculator.ceremony_country = 'ceremony-country'
          calculator.partner_nationality = 'partner-nationality'
          calculator.sex_of_your_partner = 'sex-of-your-partner'

          expected_path = '/marriage-abroad/y/ceremony-country/ceremony_country/partner-nationality/sex-of-your-partner'
          assert_equal expected_path, calculator.outcome_path_when_resident_in_ceremony_country
        end
      end

      context '#three_day_residency_requirement_applies?' do
        should 'return true if ceremony country requires 3 day residency' do
          calculator = MarriageAbroadCalculator.new
          calculator.ceremony_country = 'albania'

          assert calculator.three_day_residency_requirement_applies?
        end

        should 'return false if ceremony country does not require 3 days residency' do
          calculator = MarriageAbroadCalculator.new
          calculator.ceremony_country = 'country-not-requiring-three-day-residency'

          refute calculator.three_day_residency_requirement_applies?
        end
      end

      context '#cni_posted_after_14_days?' do
        should 'return true if ceremony country will post notice after 14 days' do
          calculator = MarriageAbroadCalculator.new
          calculator.ceremony_country = 'jordan'

          assert calculator.cni_posted_after_14_days?
        end

        should 'return false if ceremony country will not post notice after 14 days' do
          calculator = MarriageAbroadCalculator.new
          calculator.ceremony_country = 'ceremony-country-not-posting-notice-after-14-days'

          refute calculator.cni_posted_after_14_days?
        end
      end

      context '#birth_certificate_required_as_supporting_document?' do
        should 'return true when a birth certificate is required' do
          calculator = MarriageAbroadCalculator.new
          calculator.ceremony_country = 'ceremony-country-requiring-birth-certificate'

          assert calculator.birth_certificate_required_as_supporting_document?
        end

        should 'return false when no birth certificate is required' do
          calculator = MarriageAbroadCalculator.new
          calculator.ceremony_country = 'albania'

          refute calculator.birth_certificate_required_as_supporting_document?
        end
      end

      context '#notary_public_ceremony_country?' do
        should 'return true if country has a notary public' do
          calculator = MarriageAbroadCalculator.new
          calculator.ceremony_country = 'albania'

          assert calculator.notary_public_ceremony_country?
        end

        should 'return false if country has no notary public' do
          calculator = MarriageAbroadCalculator.new
          calculator.ceremony_country = 'country-without-notary-public'

          refute calculator.notary_public_ceremony_country?
        end
      end

      context '#document_download_link_if_opposite_sex_resident_of_uk_countries?' do
        should 'return true if you can download forms' do
          calculator = MarriageAbroadCalculator.new
          calculator.ceremony_country = 'country-allowing-you-to-download-forms'

          assert calculator.document_download_link_if_opposite_sex_resident_of_uk_countries?
        end

        should "return false if you can't download forms" do
          calculator = MarriageAbroadCalculator.new
          calculator.ceremony_country = 'albania'

          refute calculator.document_download_link_if_opposite_sex_resident_of_uk_countries?
        end
      end

      context '#consular_fee' do
        setup do
          consular_fees = { fee: 55 }
          rates_query = stub(rates: consular_fees)

          @calculator = MarriageAbroadCalculator.new(rates_query: rates_query)
        end

        should 'return the fee value for a consular service' do
          assert_equal 55, @calculator.consular_fee(:fee)
        end

        should 'return nil for an unknown consular service' do
          assert_nil @calculator.consular_fee(:invalid)
        end
      end

      context '#services' do
        setup do
          services_data = {
            'albania' => {
              'opposite_sex' => {
                'default' => {
                  'default' => [:partner_sex_specific_default_service],
                  'partner_local' => [:partner_sex_and_nationality_specific_service]
                },
                'uk' => {
                  'default' => [:residency_specific_default_service],
                  'partner_local' => [:residency_and_nationality_specific_service]
                }
              }
            }
          }
          @calculator = MarriageAbroadCalculator.new(services_data: services_data)
        end

        should 'return empty array if country not found in data' do
          @calculator.ceremony_country = 'country-not-in-data'

          assert_equal [], @calculator.services
        end

        should 'return empty array if country found but no services available for type of ceremony' do
          @calculator.ceremony_country = 'albania'
          @calculator.sex_of_your_partner = 'same_sex'

          assert_equal [], @calculator.services
        end

        should 'return default services matching the country and sex of partner' do
          @calculator.ceremony_country = 'albania'
          @calculator.sex_of_your_partner = 'opposite_sex'

          assert_equal [:partner_sex_specific_default_service], @calculator.services
        end

        should 'return default services matching the country, sex of partner and residency' do
          @calculator.ceremony_country = 'albania'
          @calculator.sex_of_your_partner = 'opposite_sex'
          @calculator.resident_of = 'uk'

          assert_equal [:residency_specific_default_service], @calculator.services
        end

        should 'return services matching the country, sex of partner, default residency and nationality of partner' do
          @calculator.ceremony_country = 'albania'
          @calculator.sex_of_your_partner = 'opposite_sex'
          @calculator.partner_nationality = 'partner_local'

          assert_equal [:partner_sex_and_nationality_specific_service], @calculator.services
        end

        should 'return services matching the country, sex of partner, residency and nationality of partner' do
          @calculator.ceremony_country = 'albania'
          @calculator.sex_of_your_partner = 'opposite_sex'
          @calculator.resident_of = 'uk'
          @calculator.partner_nationality = 'partner_local'

          assert_equal [:residency_and_nationality_specific_service], @calculator.services
        end
      end

      context '#ceremony_country_offers_pacs?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'return true if a PACS is available in the ceremony country' do
          @calculator.ceremony_country = 'france'
          assert @calculator.ceremony_country_offers_pacs?
        end

        should 'return false if a PACS is not available in the ceremony country' do
          @calculator.ceremony_country = 'country-without-pacs'
          refute @calculator.ceremony_country_offers_pacs?
        end
      end

      context '#french_overseas_territory_offering_pacs?' do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'return true if a PACS is available in the ceremony country and the country is a French overseas territory' do
          @calculator.ceremony_country = 'new-caledonia'
          assert @calculator.ceremony_country_offers_pacs?
          assert @calculator.french_overseas_territory_offering_pacs?
        end

        should "return false if PACS is available in the ceremony country but it's not a French overseas territory" do
          @calculator.ceremony_country = 'france'
          assert @calculator.ceremony_country_offers_pacs?
          refute @calculator.french_overseas_territory_offering_pacs?
        end
      end

      context '#services_payment_partial_name' do
        should "return nil if there's no data for the ceremony country" do
          calculator = MarriageAbroadCalculator.new(services_data: {})
          calculator.ceremony_country = 'ceremony-country'

          assert_nil calculator.services_payment_partial_name
        end

        should "return nil if there's no payment information partial set for the ceremony country" do
          services_data = { 'ceremony-country' => {} }
          calculator = MarriageAbroadCalculator.new(services_data: services_data)
          calculator.ceremony_country = 'ceremony-country'

          assert_nil calculator.services_payment_partial_name
        end

        should 'return the name of the payment information partial' do
          services_data = {
            'ceremony-country' => {
              'payment_partial_name' => 'partial-name'
            }
          }
          calculator = MarriageAbroadCalculator.new(services_data: services_data)
          calculator.ceremony_country = 'ceremony-country'

          assert_equal 'partial-name', calculator.services_payment_partial_name
        end
      end
    end
  end
end
