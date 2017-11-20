require_relative '../../test_helper'
require_relative 'flow_test_helper'

require 'smart_answer_flows/marriage-abroad'

class MarriageAbroadTest < ActiveSupport::TestCase
  include FlowTestHelper

  FLATTEN_COUNTRIES_2_OUTCOMES = %w(australia china cyprus egypt france ireland luxembourg japan philippines thailand turkey usa).freeze
  FLATTEN_COUNTRIES_6_OUTCOMES = %w(greece italy spain poland).freeze
  FLATTEN_COUNTRIES_18_OUTCOMES = %w(algeria azerbaijan brazil british-indian-ocean-territory burma cambodia chile colombia denmark el-salvador gambia germany hungary indonesia iran jordan kenya kuwait latvia maldives moldova mozambique nicaragua portugal romania south-africa sweden tanzania tunisia vietnam).freeze
  FLATTEN_COUNTRIES = FLATTEN_COUNTRIES_2_OUTCOMES + FLATTEN_COUNTRIES_6_OUTCOMES + FLATTEN_COUNTRIES_18_OUTCOMES
  NOT_FLATTEN_COUNTRIES = %w(albania american-samoa anguilla argentina armenia aruba austria bahamas belarus belgium bonaire-st-eustatius-saba burundi canada costa-rica cote-d-ivoire croatia czech-republic democratic-republic-of-the-congo ecuador estonia finland hong-kong kazakhstan kosovo kyrgyzstan laos lebanon lithuania macao macedonia malta mayotte mexico monaco montenegro morocco netherlands north-korea norway oman guatemala paraguay peru qatar russia rwanda saint-barthelemy san-marino saudi-arabia serbia seychelles slovakia slovenia somalia st-maarten st-martin south-korea spain switzerland turkmenistan ukraine united-arab-emirates uzbekistan wallis-and-futuna yemen zimbabwe).freeze

  def self.translations
    @translations ||= YAML.load_file("lib/smart_answer_flows/locales/en/marriage-abroad.yml")
  end

  setup do
    stub_shared_component_locales
    @location_slugs = NOT_FLATTEN_COUNTRIES + FLATTEN_COUNTRIES
    stub_world_locations(@location_slugs)
    setup_for_testing_flow SmartAnswer::MarriageAbroadFlow
  end

  should "which country you want the ceremony to take place in" do
    assert_current_node :country_of_ceremony?
  end

  context "newly added country that has no logic to handle opposite sex marriages" do
    setup do
      stub_world_locations(['narnia'])
      add_response 'ceremony_country'
      add_response 'partner_local'
      assert_raises(SmartAnswer::Question::Base::NextNodeUndefined) do
        add_response 'opposite_sex'
      end
    end
  end

  context "ceremony is outside ireland" do
    setup do
      add_response 'bahamas'
    end
    should "ask your country of residence" do
      assert_current_node :legal_residency?
      assert_equal 'Bahamas', current_state.calculator.ceremony_country_name
      assert_equal "the Bahamas", current_state.calculator.country_name_lowercase_prefix
    end

    context "resident in UK" do
      setup do
        add_response 'uk'
      end

      should "go to partner nationality question" do
        assert_current_node :what_is_your_partners_nationality?
        assert_equal 'Bahamas', current_state.calculator.ceremony_country_name
        assert_equal "the Bahamas", current_state.calculator.country_name_lowercase_prefix
      end

      context "partner is british" do
        setup do
          add_response 'partner_british'
        end
        should "ask what sex is your partner" do
          assert_current_node :partner_opposite_or_same_sex?
        end
        context "opposite sex partner" do
          setup do
            add_response 'opposite_sex'
          end
          should "give outcome opposite sex commonwealth" do
            assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
            expected_location = WorldLocation.find('bahamas')
            assert_equal expected_location, current_state.calculator.world_location
          end
        end
        context "same sex partner" do
          setup do
            add_response 'same_sex'
          end
          should "give outcome same sex all other countries" do
            assert_current_node :outcome_same_sex_marriage_and_civil_partnership_not_possible
          end
        end
      end
    end

    context "resident in the ceremony country" do
      setup do
        add_response 'ceremony_country'
      end

      should "go to partner's nationality question" do
        assert_current_node :what_is_your_partners_nationality?
        assert_equal 'Bahamas', current_state.calculator.ceremony_country_name
      end

      context "partner is local" do
        setup do
          add_response 'partner_local'
        end
        should "ask what sex is your partner" do
          assert_current_node :partner_opposite_or_same_sex?
        end
        context "opposite sex partner" do
          setup do
            add_response 'opposite_sex'
          end
          should "give outcome opposite sex commonwealth" do
            assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
            expected_location = WorldLocation.find('bahamas')
            assert_equal expected_location, current_state.calculator.world_location
          end
        end
        context "same sex partner" do
          setup do
            add_response 'same_sex'
          end
          should "give outcome all other countries" do
            assert_current_node :outcome_same_sex_marriage_and_civil_partnership_not_possible
          end
        end
      end
    end

    context "resident in 3rd country" do
      setup do
        add_response 'third_country'
      end

      should "go to partner's nationality question" do
        assert_current_node :what_is_your_partners_nationality?
        assert_equal 'Bahamas', current_state.calculator.ceremony_country_name
      end

      context "partner is local" do
        setup do
          add_response 'partner_local'
        end
        should "ask what sex is your partner" do
          assert_current_node :partner_opposite_or_same_sex?
        end
        context "opposite sex partner" do
          setup do
            add_response 'opposite_sex'
          end
          should "give outcome opposite sex commonwealth" do
            assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
            expected_location = WorldLocation.find('bahamas')
            assert_equal expected_location, current_state.calculator.world_location
          end
        end
        context "same sex partner" do
          setup do
            add_response 'same_sex'
          end
          should "give outcome all other countries" do
            assert_current_node :outcome_same_sex_marriage_and_civil_partnership_not_possible
          end
        end
      end
    end
  end

  context "local resident but ceremony not in zimbabwe" do
    setup do
      add_response 'albania'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
      expected_location = WorldLocation.find('albania')
      assert_equal expected_location, current_state.calculator.world_location
    end
  end

  context "uk resident but ceremony not in zimbabwe" do
    setup do
      add_response 'bahamas'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
      expected_location = WorldLocation.find('bahamas')
      assert_equal expected_location, current_state.calculator.world_location
    end
  end

  context "other resident but ceremony not in zimbabwe" do
    setup do
      add_response 'albania'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
    end
  end

  context "ceremony in zimbabwe" do
    setup do
      add_response 'zimbabwe'
    end
    should "go to commonwealth os outcome for uk resident " do
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
    end
    should "go to commonwealth os outcome for non-uk resident" do
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
    end
  end

  context "resident in anguilla, ceremony in anguilla" do
    setup do
      add_response 'anguilla'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to bos os outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_british_overseas_territory
    end
  end

  context "uk resident, ceremony in estonia, partner british" do
    setup do
      add_response 'estonia'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
    end
  end

  context "resident in estonia, ceremony in estonia" do
    setup do
      add_response 'estonia'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_ceremony_country
    end
  end

  context "ceremony in Estonia, lives in 3rd country" do
    setup do
      add_response 'estonia'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country
    end
  end

  #variants for uk residency (again)

  #variant for uk resident
  context "ceremony in guatemala, resident in wales, partner other" do
    setup do
      add_response 'guatemala'
      add_response 'uk'
      add_response 'partner_other'
    end
    should "go to consular cni os outcome for opposite sex marriage" do
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
    end

    should "go to outcome_same_sex_civil_partnership_in_consular_countries outcome for same sex marriage" do
      add_response 'same_sex'
      assert_current_node :outcome_same_sex_civil_partnership_in_consular_countries
    end
  end
  #variant for local resident

  context "ceremony in belgium, lives in 3rd country, partner british" do
    setup do
      add_response 'belgium'
    end

    should "go to outcome_opposite_sex_marriage_in_affirmation_countries for opposite sex marriages" do
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_belgium
    end

    should "go to outcome_same_sex_civil_partnership_in_affirmation_countries for same sex marriages for residents in a third country" do
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'same_sex'
      assert_current_node :outcome_same_sex_civil_partnership_in_affirmation_countries
    end

    should "go to outcome_same_sex_civil_partnership_in_affirmation_countries for same sex marriages for residents in Belgium" do
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'same_sex'
      assert_current_node :outcome_same_sex_civil_partnership_in_affirmation_countries
    end
  end

  context "ceremony in armenia, resident in the UK, partner other" do
    setup do
      add_response 'armenia'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
    end
  end

  #French overseas territories outcome
  context "ceremony in fot" do
    setup do
      add_response 'mayotte'
    end
    should "go to marriage in france or fot outcome" do
      assert_current_node :outcome_marriage_in_france_or_french_overseas_territory
    end
  end

  context "ceremony in lebanon, lives elsewhere, partner other" do
    setup do
      add_response 'lebanon'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_affirmation_countries
    end
  end

  context "ceremony in UAE, resident in UAE, partner local" do
    setup do
      add_response 'united-arab-emirates'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_united_arab_emirates
    end
  end

  context "ceremony in Oman, resident in Oman, partner local" do
    setup do
      add_response 'oman'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to os oman outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_oman
    end
  end

  context "ceremony in Ecuador, resident in Ecuador, partner other" do
    should "go to outcome os affirmation" do
      add_response 'ecuador'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_ecuador
    end
  end

  #tests for no cni or consular services
  context "ceremony in aruba, resident in the UK, partner other" do
    setup do
      add_response 'aruba'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
    end
  end

  context "ceremony in aruba, resident in aruba, partner british" do
    setup do
      add_response 'aruba'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_opposite_sex_in_no_cni_countries_when_residing_in_ceremony_or_third_country
    end
  end

  context "ceremony in aruba, lives elsewhere, partner other" do
    setup do
      add_response 'aruba'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_opposite_sex_in_no_cni_countries_when_residing_in_ceremony_or_third_country
    end
  end

  context "ceremony in cote-d-ivoire" do
    setup do
      add_response 'cote-d-ivoire'
    end

    should "lead to outcome_ceremonies_in_netherlands_or_marriage_via_local_authority_countries when in the UK" do
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_ceremonies_in_netherlands_or_marriage_via_local_authority_countries
    end

    should "lead to outcome_ceremonies_in_netherlands_or_marriage_via_local_authority_countries when in a third country" do
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_ceremonies_in_netherlands_or_marriage_via_local_authority_countries
    end
  end

  context "ceremony in monaco, maps to France, marriage" do
    setup do
      add_response 'monaco'
      add_response 'marriage'
    end
    should "go to outcome_marriage_in_monaco" do
      assert_current_node :outcome_marriage_in_monaco
    end
  end

  context "ceremony in monaco, maps to France, pacs" do
    setup do
      add_response 'monaco'
      add_response 'pacs'
    end
    should "go to outcome_civil_partnership_in_monaco" do
      assert_current_node :outcome_civil_partnership_in_monaco
    end
  end

  context "user lives in 3rd country, ceremony in macedonia, partner os (any nationality)" do
    setup do
      add_response 'macedonia'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country
    end
  end

  context "user lives in macedonia, ceremony in macedonia" do
    setup do
      add_response 'macedonia'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_ceremony_country
    end
  end

  context "ceremony in argentina, lives elsewhere, partner other" do
    should "go to outcome_ceremonies_in_netherlands_or_marriage_via_local_authority_countries" do
      add_response 'argentina'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
      assert_current_node :outcome_ceremonies_in_netherlands_or_marriage_via_local_authority_countries
    end
  end

  context "ceremony in burundi, resident in 3rd country, partner anywhere" do
    setup do
      add_response 'burundi'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_opposite_sex_in_no_cni_countries_when_residing_in_ceremony_or_third_country
    end
  end

  context "ceremony in north korea, resident in the UK, partner local" do
    setup do
      add_response 'north-korea'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to outcome_opposite_sex_marriage_in_north_korea" do
      assert_current_node :outcome_opposite_sex_marriage_in_north_korea
    end
  end

  context "ceremony in somalia, resident in the UK, partner local" do
    setup do
      add_response 'somalia'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_other_countries
    end
  end

  context "ceremony in yemen, resident in the UK, partner local" do
    setup do
      add_response 'yemen'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to outcome_opposite_sex_marriage_in_yemen" do # Consular services in Yemen are temporarily ceased. Normal outcome: consular cni os outcome
      assert_current_node :outcome_opposite_sex_marriage_in_yemen
    end
  end

  context "ceremony in saudi arabia, resident in the UK, partner other" do
    setup do
      add_response 'saudi-arabia'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to outcome_opposite_sex_marriage_in_saudi_arabia_when_residing_in_uk_or_third_country" do
      assert_current_node :outcome_opposite_sex_marriage_in_saudi_arabia_when_residing_in_uk_or_third_country
    end
  end

  context "ceremony in saudi arabia, resident in saudi arabia, partner british" do
    setup do
      add_response 'saudi-arabia'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to outcome_opposite_sex_marriage_in_saudi_arabia_when_residing_in_saudi_arabia" do
      assert_current_node :outcome_opposite_sex_marriage_in_saudi_arabia_when_residing_in_saudi_arabia
    end
  end

  context "ceremony in saudi arabia, resident in saudi arabia, partner other" do
    setup do
      add_response 'saudi-arabia'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to outcome_opposite_sex_marriage_in_saudi_arabia_when_residing_in_saudi_arabia" do
      assert_current_node :outcome_opposite_sex_marriage_in_saudi_arabia_when_residing_in_saudi_arabia
    end
  end

  context "ceremony in russia, resident in russia, partner british" do
    setup do
      add_response 'russia'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to russia CNI outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_ceremony_country
    end
  end

  context "ceremony in czech republic, lives elsewhere, partner local" do
    setup do
      add_response 'czech-republic'
      add_response 'third_country'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to cp or equivalent outcome" do
      assert_current_node :outcome_same_sex_civil_partnership
    end
  end

  context "ceremony in wallis and futuna, pacs" do
    setup do
      add_response 'wallis-and-futuna'
      add_response 'pacs'
    end
    should "go to france or fot pacs outcome" do
      assert_current_node :outcome_civil_partnership_in_france_or_french_overseas_territory
    end
  end

  context "ceremony in bonaire, resident in the UK, partner other" do
    setup do
      add_response 'bonaire-st-eustatius-saba'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to cp no cni required outcome" do
      assert_current_node :outcome_same_sex_civil_partnership_in_no_cni_countries
    end
  end

  context "ceremony in bonaire, resident in bonaire, partner british" do
    setup do
      add_response 'bonaire-st-eustatius-saba'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to cp no cni required outcome" do
      assert_current_node :outcome_same_sex_civil_partnership_in_no_cni_countries
    end
  end

  context "ceremony in bonaire, resident in third country, partner other" do
    setup do
      add_response 'bonaire-st-eustatius-saba'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to cp no cni required outcome" do
      assert_current_node :outcome_same_sex_civil_partnership_in_no_cni_countries
    end
  end

  context "ceremony in canada, UK resident, partner other" do
    setup do
      add_response 'canada'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to cp commonwealth countries outcome" do
      assert_current_node :outcome_same_sex_civil_partnership_in_commonwealth_countries
    end
  end

  context "ceremony in czech-republic, uk resident, partner other" do
    setup do
      add_response 'czech-republic'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to consular cni cp countries outcome" do
      assert_current_node :outcome_same_sex_civil_partnership
    end
  end

  context "ceremony in turkmenistan" do
    setup do
      add_response 'turkmenistan'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to all other countries outcome" do
      assert_current_node :outcome_same_sex_marriage_and_civil_partnership_not_possible
    end
  end

  context "ceremony in serbia, lives elsewhere, partner british" do
    setup do
      add_response 'serbia'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to cp all other countries outcome" do
      assert_current_node :outcome_same_sex_marriage_and_civil_partnership
    end
  end

  context 'Ceremony in Slovenia' do
    setup do
      add_response 'slovenia'
    end

    context 'for opposite sex couples' do
      setup do
        add_response 'ceremony_country'
        add_response 'partner_other'
        add_response 'opposite_sex'
      end

      should 'give a Slovenia specific outcome' do
        assert_current_node :outcome_opposite_sex_marriage_in_slovenia_when_residing_in_uk_or_slovenia
      end
    end
  end

  context "ceremony in switzerland, resident in switzerland, partner opposite sex" do
    should "give swiss outcome with variants (gender variant)" do
      add_response 'switzerland'
      add_response 'uk'
      add_response 'opposite_sex'
      assert_current_node :outcome_ceremonies_in_switzerland
    end
  end

  context "ceremony in switzerland, resident in switzerland, partner same sex" do
    should "give swiss outcome with variants" do
      add_response 'switzerland'
      add_response 'ceremony_country'
      add_response 'same_sex'
      assert_current_node :outcome_ceremonies_in_switzerland
    end
  end

  context "ceremony in switzerland, not resident in switzerland, partner opposite sex" do
    should "give swiss outcome with variants" do
      add_response 'switzerland'
      add_response 'uk'
      add_response 'same_sex'
      assert_current_node :outcome_ceremonies_in_switzerland
    end
  end

  context "ceremony in switzerland, not resident in switzerland, partner same sex" do
    should "give swiss outcome with variants" do
      add_response 'switzerland'
      add_response 'third_country'
      add_response 'opposite_sex'
      assert_current_node :outcome_ceremonies_in_switzerland
    end
  end

  context "peru outcome mapped to lebanon for same sex" do
    should "go to outcome cp all other countries" do
      add_response 'peru'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'same_sex'
      assert_current_node :outcome_same_sex_marriage_and_civil_partnership
    end
  end

  context "peru outcome mapped to lebanon for opposite sex" do
    should "go to outcome os affirmation" do
      add_response 'peru'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_peru
    end
  end

  context "ceremony in finland, resident in the UK, partner british" do
    setup do
      add_response 'finland'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to cni outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
    end
  end

  context "ceremony in finland, resident in the UK, partner local" do
    setup do
      add_response 'finland'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to cni outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
    end
  end

  context "ceremony in finland, resident in Albania, partner other" do
    setup do
      add_response 'finland'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to affirmation outcome with specific fee table" do
      assert_current_node :outcome_opposite_sex_marriage_in_affirmation_countries
    end
  end

  context "ceremony in finland, resident in the UK, partner other" do
    setup do
      add_response 'finland'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to outcome cni with specific fee table" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
    end
  end

  context "ceremony in finland, resident in the UK, partner other, SS" do
    setup do
      add_response 'finland'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to affirmation outcome with specific fee table" do
      assert_current_node :outcome_same_sex_civil_partnership
    end
  end

  context "south-korea new outcome" do
    should "go to :outcome_opposite_sex_marriage_in_affirmation_countries outcome" do
      add_response 'south-korea'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_south_korea
    end
  end

  context "Slovakia" do
    should "lead to outcome_ceremonies_in_netherlands_or_marriage_via_local_authority_countries" do
      add_response 'slovakia'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_slovakia
    end
  end

  context "Ukraine" do
    should "lead to outcome_ceremonies_in_netherlands_or_marriage_via_local_authority_countries" do
      add_response 'ukraine'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_ceremonies_in_netherlands_or_marriage_via_local_authority_countries
    end
  end

  context "Netherlands" do
    should "bring you to outcome_ceremonies_in_netherlands_or_marriage_via_local_authority_countries" do
      add_response 'netherlands'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_ceremonies_in_netherlands_or_marriage_via_local_authority_countries
    end
  end

  context "aruba opposite sex outcome" do
    should "bring you to aruba os outcome" do
      add_response 'aruba'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
    end
  end

  context "uk resident, ceremony in estonia, partner same sex british" do
    setup do
      add_response 'estonia'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to ss outcome" do
      assert_current_node :outcome_same_sex_marriage_and_civil_partnership
    end
  end

  context "ceremony in russia, lives elsewhere, same sex marriage, non british partner" do
    setup do
      add_response 'russia'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to outcome_same_sex_marriage_and_civil_partnership_not_possible" do
      assert_current_node :outcome_same_sex_marriage_and_civil_partnership_not_possible
    end
  end

  context "kazakhstan should show its correct embassy page" do
    setup do
      add_response 'kazakhstan'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country
    end
  end

  context "Residency Country and ceremony country = Croatia" do
    setup do
      add_response 'croatia'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_ceremony_country outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_ceremony_country
    end
  end

  context "Marrying in Qatar" do
    setup do
      add_response 'qatar'
    end
    should "go to :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk_or_ceremony_country outcome" do
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_qatar
    end

    should "go to outcome_opposite_sex_marriage_in_affirmation_countries outcome" do
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_qatar
    end
  end

  context "ceremony in Lithuania, partner same sex, partner british" do
    setup do
      add_response 'lithuania'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to outcome_same_sex_marriage_and_civil_partnership" do
      assert_current_node :outcome_same_sex_marriage_and_civil_partnership
    end
  end

  context "ceremony in Lithuania, partner same sex, partner not british" do
    setup do
      add_response 'lithuania'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to outcome 'no same sex marriage allowed' because partner is not british" do
      assert_current_node :outcome_same_sex_marriage_and_civil_partnership_not_possible
    end
  end

  context "Ceremony in Belarus" do
    setup do
      add_response 'belarus'
    end
    should "go to outcome_opposite_sex_marriage_in_belarus and show correct link for appointments in Minsk, opposite sex marriage" do
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_belarus
      assert_match(/Make an appointment at the embassy in Minsk/, outcome_body)
    end

    should "go to outcome_opposite_sex_marriage_in_belarus when in third country" do
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_belarus
    end
  end

  context "test morocco specific, living in the UK" do
    setup do
      add_response 'morocco'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_morocco
    end
  end

  context "test morocco specific, living elsewhere" do
    setup do
      add_response 'morocco'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_opposite_sex_marriage_in_morocco
    end
  end

  context "Mexico" do
    setup do
      add_response 'mexico'
    end

    should "go to outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country" do
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country
    end

    should "show outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_ceremony_country when partner is local" do
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_ceremony_country
    end

    should "show outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_ceremony_country when partner is british" do
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_ceremony_country
    end
  end

  context "Marriage in Albania, living elsewhere, partner British, opposite sex" do
    setup do
      add_response 'albania'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "lead to outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country
    end
  end

  context "Marriage in Democratic Republic of the Congo, living elsewhere, partner British, opposite sex" do
    setup do
      add_response 'democratic-republic-of-the-congo'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "lead to outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country
    end
  end

  context "Marriage in Mexico, living in the UK, partner British, opposite sex" do
    setup do
      add_response 'mexico'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "show outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
    end
  end

  context "Marriage in Albania, living in the UK, partner British, opposite sex" do
    setup do
      add_response 'albania'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "show outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
    end
  end

  #Marriage that requires a 7 day notice to be given
  context "Marriage in Canada, living elsewhere" do
    setup do
      add_response 'canada'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "show 7 day notice" do
      assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
    end
  end

  context "ceremony in Rwanda," do
    setup do
      add_response 'rwanda'
    end

    context "resident in ceremony country," do
      setup { add_response 'ceremony_country' }
      context "partner is british," do
        setup { add_response 'partner_british' }
        context "opposite sex" do
          setup { add_response 'opposite_sex' }
          should "go to rwandan marriage outcome mirroring other commonwealth countries" do
            assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
          end
        end
      end
      context "partner is elsewhere," do
        setup { add_response 'partner_other' }
        context "opposite sex" do
          setup { add_response 'opposite_sex' }
          should "go to rwandan marriage outcome mirroring other commonwealth countries" do
            assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
          end
        end
      end

      context "partner is ceremony country," do
        setup { add_response 'partner_local' }
        context "opposite sex" do
          setup { add_response 'opposite_sex' }
          should "go to rwandan marriage outcome mirroring other commonwealth countries" do
            assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
          end
        end
      end
    end
    context "resident in third country," do
      setup { add_response 'third_country' }
      context "partner is british," do
        setup { add_response 'partner_british' }
        context "opposite sex" do
          setup { add_response 'opposite_sex' }
          should "go to rwandan marriage outcome mirroring other commonwealth countries" do
            assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
          end
        end
      end
      context "partner is elsewhere," do
        setup { add_response 'partner_other' }
        context "opposite sex" do
          setup { add_response 'opposite_sex' }
          should "go to rwandan marriage outcome mirroring other commonwealth countries" do
            assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
          end
        end
      end

      context "partner is ceremony country," do
        setup { add_response 'partner_local' }
        context "opposite sex" do
          setup { add_response 'opposite_sex' }
          should "go to rwandan marriage outcome mirroring other commonwealth countries" do
            assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
          end
        end
      end
    end
    context "resident in uk," do
      setup { add_response 'uk' }
      context "partner is british," do
        setup { add_response 'partner_british' }
        context "opposite sex" do
          setup { add_response 'opposite_sex' }
          should "go to rwandan marriage outcome mirroring other commonwealth countries" do
            assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
          end
        end
      end
      context "partner is elsewhere," do
        setup { add_response 'partner_other' }
        context "opposite sex" do
          setup { add_response 'opposite_sex' }
          should "go to rwandan marriage outcome mirroring other commonwealth countries" do
            assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
          end
        end
      end
      context "partner is ceremony country," do
        setup { add_response 'partner_local' }
        context "opposite sex" do
          setup { add_response 'opposite_sex' }
          should "go to rwandan marriage outcome mirroring other commonwealth countries" do
            assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
          end
        end
      end
    end
  end

  context "same sex marriage in San Marino is not allowed" do
    setup do
      add_response 'san-marino'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "do not allow marriage" do
      assert_current_node :outcome_same_sex_marriage_and_civil_partnership_not_possible
    end
  end

  context "same sex marriage in Malta" do
    setup do
      add_response 'malta'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "do not allow marriage" do
      assert_current_node :outcome_same_sex_marriage_and_civil_partnership_in_malta
    end
  end

  context "opposite sex marriage in Malta" do
    setup do
      add_response 'malta'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "do not allow marriage" do
      assert_current_node :outcome_opposite_sex_marriage_in_commonwealth_countries
    end
  end

  context "ceremony in Uzbekistan, resident in the UK, partner from anywhere, opposite sex" do
    setup do
      add_response 'uzbekistan'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "not include the links to download documents" do
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
    end
  end

  context "ceremony in Laos" do
    setup do
      add_response 'laos'
    end

    context "resident in the UK, opposite sex partner from Laos" do
      setup do
        add_response 'uk'
        add_response 'partner_local'
        add_response 'opposite_sex'
      end
      should "lead to outcome_opposite_sex_marriage_in_laos_with_lao_national" do
        assert_current_node :outcome_opposite_sex_marriage_in_laos_with_lao_national
      end
    end

    context "resident in 3rd country, opposite sex partner from Laos" do
      setup do
        add_response 'third_country'
        add_response 'partner_local'
        add_response 'opposite_sex'
      end
      should "lead to outcome_opposite_sex_marriage_in_laos_with_lao_national" do
        assert_current_node :outcome_opposite_sex_marriage_in_laos_with_lao_national
      end
    end

    context "resident in Laos, opposite sex partner from Laos" do
      setup do
        add_response 'ceremony_country'
        add_response 'partner_local'
        add_response 'opposite_sex'
      end
      should "lead to outcome_opposite_sex_marriage_in_laos_with_lao_national" do
        assert_current_node :outcome_opposite_sex_marriage_in_laos_with_lao_national
      end
    end

    context "opposite sex partner, no Laos nationals" do
      setup do
        add_response 'uk'
        add_response 'partner_other'
        add_response 'opposite_sex'
      end
      should "lead to outcome_opposite_sex_marriage_in_laos_without_lao_national" do
        assert_current_node :outcome_opposite_sex_marriage_in_laos_without_lao_national
      end
    end
  end

  context "Albania" do
    should "allow same sex marriage and civil partnership conversion to marriage, has custom appointment booking link" do
      add_response 'albania'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'same_sex'

      assert_current_node :outcome_same_sex_marriage_and_civil_partnership
    end
  end

  context "Costa Rica" do
    should "indicate that same sex marriage or civil partnership is not recognised anymore" do
      add_response 'costa-rica'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'same_sex'

      assert_current_node :outcome_same_sex_marriage_and_civil_partnership_not_possible
    end
  end

  context "Kosovo" do
    setup do
      add_response 'kosovo'
    end

    should "lead to outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country if in third country" do
      add_response 'third_country'
      add_response 'partner_local'
      add_response 'opposite_sex'

      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country
    end

    should "lead to a :outcome_opposite_sex_marriage_in_kosovo_when_residing_in_uk_or_kosovo outcome for uk, partner_local and opposite_sex" do
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'

      assert_current_node :outcome_opposite_sex_marriage_in_kosovo_when_residing_in_uk
    end

    should "lead to a :outcome_opposite_sex_marriage_in_kosovo_when_residing_in_uk_or_kosovo outcome for ceremony_country, partner_local and opposite_sex" do
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'

      assert_current_node :outcome_opposite_sex_marriage_in_kosovo_when_residing_in_kosovo
    end
  end

  context "Montenegro" do
    setup do
      add_response 'montenegro'
      add_response 'ceremony_country'
    end

    should "lead to outcome_same_sex_marriage_and_civil_partnership when both partners are same sex british" do
      add_response 'partner_british'
      add_response 'same_sex'
      assert_current_node :outcome_same_sex_marriage_and_civil_partnership
    end

    should "lead to outcome_same_sex_marriage_and_civil_partnership_not_possible when both partners are same sex not british" do
      add_response 'partner_local'
      add_response 'same_sex'
      assert_current_node :outcome_same_sex_marriage_and_civil_partnership_not_possible
    end
  end

  context "Saint-Barthélemy" do
    setup do
      add_response 'saint-barthelemy'
      add_response 'third_country'
      add_response 'partner_british'
    end

    should "suggest to contact local authorities even if the user is in third country for OS (because they don't have many embassies)" do
      add_response 'opposite_sex'

      assert_current_node :outcome_opposite_sex_in_no_cni_countries_when_residing_in_ceremony_or_third_country
    end

    should "suggest to contact local authorities even if the user is in third country for SS (because they don't have many embassies)" do
      add_response 'same_sex'

      assert_current_node :outcome_opposite_sex_in_no_cni_countries_when_residing_in_ceremony_or_third_country
    end
  end

  context "St Martin" do
    setup do
      add_response 'st-martin'
      add_response 'third_country'
      add_response 'partner_british'
    end

    should "suggest to contact local authorities even if the user is in third country for OS (because they don't have many embassies)" do
      add_response 'opposite_sex'

      assert_current_node :outcome_opposite_sex_in_no_cni_countries_when_residing_in_ceremony_or_third_country
    end

    should "suggest to contact local authorities even if the user is in third country for SS (because they don't have many embassies)" do
      add_response 'same_sex'

      assert_current_node :outcome_opposite_sex_in_no_cni_countries_when_residing_in_ceremony_or_third_country
    end
  end

  context "Macao" do
    should "lead to an affirmation outcome for opposite sex marriages directing users to Hong Kong" do
      add_response 'macao'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'

      assert_current_node :outcome_opposite_sex_marriage_in_macao
    end

    should "lead to an affirmation outcome for opposite sex marriages directing users to Hong Kong with an intro about residency" do
      add_response 'macao'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'

      assert_current_node :outcome_opposite_sex_marriage_in_macao
    end
  end

  context "Hong Kong" do
    should "lead to the custom outcome directing users to the local Immigration Department for opposite sex marriages" do
      add_response 'hong-kong'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'

      assert_current_node :outcome_opposite_sex_marriage_in_hong_kong
    end
  end

  context "Norway" do
    setup do
      add_response 'norway'
    end

    should "lead to the affirmation outcome when in Norway" do
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_norway
    end

    should "lead to the CNI outcome for opposite sex marriages for UK residents" do
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_uk
    end

    should "lead to a custom CNI third country outcome when in a thiord country" do
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_third_country
    end

    should "lead to SS affirmation outcome" do
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'same_sex'

      assert_current_node :outcome_same_sex_civil_partnership_in_affirmation_countries
    end
  end

  context "Seychelles" do
    should "lead to outcome_same_sex_marriage_and_civil_partnership for same sex marriages" do
      add_response 'seychelles'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'same_sex'
      assert_current_node :outcome_same_sex_marriage_and_civil_partnership_not_possible
    end
  end

  context "Kyrgyzstan" do
    should "lead to the CNI outcome with a suggestion to post notice in Almaty, Kazakhstan" do
      add_response 'kyrgyzstan'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_opposite_sex_marriage_in_consular_cni_countries_when_residing_in_ceremony_country
    end
  end

  FLATTEN_COUNTRIES_18_OUTCOMES.each do |country|
    context "ceremony in #{country}," do
      setup do
        add_response "#{country}"
      end
      context "resident in uk," do
        setup { add_response "uk" }
        context "partner is british," do
          setup { add_response "partner_british" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
        context "partner is local," do
          setup { add_response "partner_local" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
        context "partner is other," do
          setup { add_response "partner_other" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
      end
      context "resident in ceremony country" do
        setup { add_response "ceremony_country" }
        context "partner is british," do
          setup { add_response "partner_british" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
        context "partner is local," do
          setup { add_response "partner_local" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
        context "partner is other," do
          setup { add_response "partner_other" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
      end
      context "resident in third country" do
        setup { add_response "third_country" }
        context "partner is british," do
          setup { add_response "partner_british" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
        context "partner is local," do
          setup { add_response "partner_local" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
        context "partner is other," do
          setup { add_response "partner_other" }
          context "opposite sex" do
            setup { add_response "opposite_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
          context "same sex" do
            setup { add_response "same_sex" }
            should "go to generic country outcome" do
              assert_current_node :outcome_marriage_abroad_in_country
            end
          end
        end
      end
    end
  end

  FLATTEN_COUNTRIES_6_OUTCOMES.each do |country|
    context "ceremony in #{country}," do
      setup do
        add_response "#{country}"
      end
      context "resident in uk," do
        setup { add_response "uk" }
        context "opposite sex" do
          setup { add_response "opposite_sex" }
          should "go to generic country outcome" do
            assert_current_node :outcome_marriage_abroad_in_country
          end
        end
        context "same sex" do
          setup { add_response "same_sex" }
          should "go to generic country outcome" do
            assert_current_node :outcome_marriage_abroad_in_country
          end
        end
      end
      context "resident in ceremony country" do
        setup { add_response "ceremony_country" }
        context "opposite sex" do
          setup { add_response "opposite_sex" }
          should "go to generic country outcome" do
            assert_current_node :outcome_marriage_abroad_in_country
          end
        end
        context "same sex" do
          setup { add_response "same_sex" }
          should "go to generic country outcome" do
            assert_current_node :outcome_marriage_abroad_in_country
          end
        end
      end
      context "resident in third country" do
        setup { add_response "third_country" }
        context "opposite sex" do
          setup { add_response "opposite_sex" }
          should "go to generic country outcome" do
            assert_current_node :outcome_marriage_abroad_in_country
          end
        end
        context "same sex" do
          setup { add_response "same_sex" }
          should "go to generic country outcome" do
            assert_current_node :outcome_marriage_abroad_in_country
          end
        end
      end
    end
  end

  FLATTEN_COUNTRIES_2_OUTCOMES.each do |country|
    context "ceremony in #{country}," do
      setup do
        add_response "#{country}"
      end

      context "opposite sex" do
        setup { add_response "opposite_sex" }
        should "go to generic country outcome" do
          assert_current_node :outcome_marriage_abroad_in_country
        end
      end

      context "same sex" do
        setup { add_response "same_sex" }
        should "go to generic country outcome" do
          assert_current_node :outcome_marriage_abroad_in_country
        end
      end
    end
  end
end
