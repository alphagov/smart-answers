# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'

class MarriageAbroadV2Test < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide

  setup do
    @location_slugs = %w(albania american-samoa anguilla argentina armenia aruba australia austria azerbaijan bahamas belarus belgium bonaire-st-eustatius-saba british-indian-ocean-territory burma burundi cambodia canada china cote-d-ivoire croatia cyprus czech-republic denmark egypt estonia finland france germany indonesia iran ireland italy japan jordan kazakhstan latvia lebanon lithuania mayotte mexico monaco morocco netherlands nicaragua north-korea guatemala paraguay peru philippines poland portugal qatar russia saudi-arabia serbia slovakia south-africa st-maarten south-korea spain sweden switzerland thailand turkey united-arab-emirates usa vietnam wallis-and-futuna yemen zimbabwe)
    worldwide_api_has_locations(@location_slugs)
    setup_for_testing_flow 'marriage-abroad-v2'
  end

  should "which country you want the ceremony to take place in" do
    assert_current_node :country_of_ceremony?
  end
  context "ceremony in ireland" do
    setup do
      worldwide_api_has_organisations_for_location('ireland', read_fixture_file('worldwide/ireland_organisations.json'))
      add_response 'ireland'
    end
    should "go to partner's sex question" do
      assert_current_node :partner_opposite_or_same_sex?
    end
    context "partner is opposite sex" do
      setup do
        add_response 'opposite_sex'
      end
      should "give outcome ireland os" do
        assert_current_node :outcome_ireland
        assert_phrase_list :ireland_partner_sex_variant, [:outcome_ireland_opposite_sex]
      end
    end
    context "partner is same sex" do
      setup do
        add_response 'same_sex'
      end
      should "give outcome ireland ss" do
        assert_current_node :outcome_ireland
        assert_phrase_list :ireland_partner_sex_variant, [:outcome_ireland_same_sex]
        expected_location = WorldLocation.find('ireland')
        assert_state_variable :location, expected_location
      end
    end
  end

  context "ceremony is outside ireland" do
    setup do
      worldwide_api_has_organisations_for_location('bahamas', read_fixture_file('worldwide/bahamas_organisations.json'))
      add_response 'bahamas'
    end
    should "ask your country of residence" do
      assert_current_node :legal_residency?
      assert_state_variable :ceremony_country, 'bahamas'
      assert_state_variable :ceremony_country_name, 'Bahamas'
      assert_state_variable :country_name_lowercase_prefix, "the Bahamas"
    end

    context "resident in UK" do
      setup do
        add_response 'uk'
      end
      should "go to uk residency region question" do
        assert_current_node :residency_uk?
        assert_state_variable :ceremony_country, 'bahamas'
        assert_state_variable :ceremony_country_name, 'Bahamas'
        assert_state_variable :country_name_lowercase_prefix, "the Bahamas"
        assert_state_variable :resident_of, 'uk'
      end

      context "resident in england" do
        setup do
          add_response 'uk_england'
        end
        should "go to partner nationality question" do
          assert_current_node :what_is_your_partners_nationality?
          assert_state_variable :ceremony_country, 'bahamas'
          assert_state_variable :ceremony_country_name, 'Bahamas'
          assert_state_variable :country_name_lowercase_prefix, "the Bahamas"
          assert_state_variable :resident_of, 'uk'
          assert_state_variable :residency_uk_region, 'uk_england'
        end

        context "partner is british" do
          setup do
            add_response 'partner_british'
          end
          should "ask what sex is your partner" do
            assert_current_node :partner_opposite_or_same_sex?
            assert_state_variable :partner_nationality, 'partner_british'
          end
          context "opposite sex partner" do
            setup do
              add_response 'opposite_sex'
            end
            should "give outcome opposite sex commonwealth" do
              assert_current_node :outcome_os_commonwealth
              assert_phrase_list :commonwealth_os_outcome, [:uk_resident_os_ceremony_not_zimbabwe, :commonwealth_os_all_cni]
              expected_location = WorldLocation.find('bahamas')
              assert_state_variable :location, expected_location
            end
          end
          context "same sex partner" do
            setup do
              add_response 'same_sex'
            end
            should "give outcome same sex all other countries" do
              assert_current_node :outcome_cp_all_other_countries
            end
          end
        end
      end
    end
    context "resident in non-UK country" do
      setup do
        add_response 'other'
      end
      should "go to non-uk residency country question" do
        assert_current_node :residency_nonuk?
        assert_state_variable :ceremony_country, 'bahamas'
        assert_state_variable :ceremony_country_name, 'Bahamas'
        assert_state_variable :resident_of, 'other'
      end

      context "resident in australia" do
        setup do
          worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
          add_response 'australia'
        end
        should "go to partner's nationality question" do
          assert_current_node :what_is_your_partners_nationality?
          assert_state_variable :ceremony_country, 'bahamas'
          assert_state_variable :ceremony_country_name, 'Bahamas'
          assert_state_variable :resident_of, 'other'
          assert_state_variable :residency_country, 'australia'
          assert_state_variable :residency_country_name, 'Australia'
        end
        context "partner is local" do
          setup do
            add_response 'partner_local'
          end
          should "ask what sex is your partner" do
            assert_current_node :partner_opposite_or_same_sex?
            assert_state_variable :partner_nationality, 'partner_local'
          end
          context "opposite sex partner" do
            setup do
              add_response 'opposite_sex'
            end
            should "give outcome opposite sex commonwealth" do
              assert_current_node :outcome_os_commonwealth
              assert_phrase_list :commonwealth_os_outcome, [:other_resident_os_ceremony_not_zimbabwe, :commonwealth_os_all_cni, :commonwealth_os_naturalisation]
              expected_location = WorldLocation.find('australia')
              assert_state_variable :location, expected_location
            end
          end
          context "same sex partner" do
            setup do
              add_response 'same_sex'
            end
            should "give outcome all other countries" do
              assert_current_node :outcome_cp_all_other_countries
            end
          end
        end
      end
    end
  end

  # tests for specific countries
  # testing for zimbabwe variants
  context "local resident but ceremony not in zimbabwe" do
    setup do
      worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
      add_response 'australia'
      add_response 'other'
      add_response 'australia'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:local_resident_os_ceremony_not_zimbabwe, :commonwealth_os_all_cni]
      expected_location = WorldLocation.find('australia')
      assert_state_variable :location, expected_location
    end
  end
  context "uk resident but ceremony not in zimbabwe" do
    setup do
      worldwide_api_has_organisations_for_location('bahamas', read_fixture_file('worldwide/bahamas_organisations.json'))
      add_response 'bahamas'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:uk_resident_os_ceremony_not_zimbabwe, :commonwealth_os_all_cni]
      expected_location = WorldLocation.find('bahamas')
      assert_state_variable :location, expected_location
    end
  end
  context "other resident but ceremony not in zimbabwe" do
    setup do
      worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
      worldwide_api_has_organisations_for_location('canada', read_fixture_file('worldwide/canada_organisations.json'))
      add_response 'australia'
      add_response 'other'
      add_response 'canada'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:other_resident_os_ceremony_not_zimbabwe, :commonwealth_os_all_cni]
    end
  end
  context "uk resident ceremony in zimbabwe" do
    setup do
      worldwide_api_has_organisations_for_location('zimbabwe', read_fixture_file('worldwide/zimbabwe_organisations.json'))
      add_response 'zimbabwe'
      add_response 'uk'
      add_response 'uk_wales'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:uk_resident_os_ceremony_zimbabwe, :commonwealth_os_all_cni_zimbabwe]
    end
  end
  # testing for other commonwealth countries
  context "uk resident ceremony in south-africa" do
    setup do
      worldwide_api_has_organisations_for_location('south-africa', read_fixture_file('worldwide/south-africa_organisations.json'))
      add_response 'south-africa'
      add_response 'uk'
      add_response 'uk_wales'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:uk_resident_os_ceremony_not_zimbabwe, :commonwealth_os_all_cni, :commonwealth_os_other_countries_south_africa, :commonwealth_os_naturalisation]
    end
  end
  context "resident in cyprus, ceremony in cyprus" do
    setup do
      worldwide_api_has_organisations_for_location('cyprus', read_fixture_file('worldwide/cyprus_organisations.json'))
      add_response 'cyprus'
      add_response 'other'
      add_response 'cyprus'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:local_resident_os_ceremony_not_zimbabwe, :commonwealth_os_all_cni, :commonwealth_os_other_countries_cyprus, :commonwealth_os_naturalisation]
    end
  end
  # testing for british overseas territories
  context "uk resident ceremony in british indian ocean territory" do
    setup do
      worldwide_api_has_organisations_for_location('british-indian-ocean-territory', read_fixture_file('worldwide/british-indian-ocean-territory_organisations.json'))
      add_response 'british-indian-ocean-territory'
      add_response 'uk'
      add_response 'uk_wales'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to bot os outcome" do
      assert_current_node :outcome_os_bot
      assert_phrase_list :bot_outcome, [:bot_os_ceremony_biot]
    end
  end
  context "resident in anguilla, ceremony in anguilla" do
    setup do
      worldwide_api_has_organisations_for_location('anguilla', read_fixture_file('worldwide/anguilla_organisations.json'))
      add_response 'anguilla'
      add_response 'other'
      add_response 'anguilla'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to bos os outcome" do
      assert_current_node :outcome_os_bot
      assert_phrase_list :bot_outcome, [:bot_os_ceremony_non_biot, :bot_os_naturalisation]
    end
  end
  # testing for consular cni countries
  context "uk resident, ceremony in estonia, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('estonia', read_fixture_file('worldwide/estonia_organisations.json'))
      add_response 'estonia'
      add_response 'uk'
      add_response 'uk_wales'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :cni_at_local_register_office, :consular_cni_os_uk_resident_legalisation, :consular_cni_os_uk_resident_not_italy_or_portugal]
      assert_phrase_list :consular_cni_os_remainder, [:partner_will_need_a_cni, :consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "resident in estonia, ceremony in estonia" do
    setup do
      worldwide_api_has_organisations_for_location('estonia', read_fixture_file('worldwide/estonia_organisations.json'))
      add_response 'estonia'
      add_response 'other'
      add_response 'estonia'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :check_with_embassy_or_consulate, :embassies_data, :living_in_residence_country_3_days, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :display_notice_of_marriage_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "resident in canada, ceremony in estonia" do
    setup do
      worldwide_api_has_organisations_for_location('estonia', read_fixture_file('worldwide/estonia_organisations.json'))
      worldwide_api_has_organisations_for_location('canada', read_fixture_file('worldwide/canada_organisations.json'))
      add_response 'estonia'
      add_response 'other'
      add_response 'canada'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_commonwealth_resident, :consular_cni_os_commonwealth_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_commonwealth_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "local resident, ceremony in jordan, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('jordan', read_fixture_file('worldwide/jordan_organisations.json'))
      add_response 'jordan'
      add_response 'other'
      add_response 'jordan'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :gulf_states_os_consular_cni, :gulf_states_os_consular_cni_local_resident_partner_not_irish, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :check_with_embassy_or_consulate, :embassies_data, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :display_notice_of_marriage_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  # variants for italy
  context "ceremony in italy, resident in england, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('italy', read_fixture_file('worldwide/italy_organisations.json'))
      add_response 'italy'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:italy_os_consular_cni_ceremony_italy, :consular_cni_all_what_you_need_to_do, :italy_os_consular_cni_uk_resident, :italy_os_consular_cni_uk_resident_two, :cni_at_local_register_office, :consular_cni_os_scotland_or_ni_partner_irish_or_partner_not_irish_three]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "ceremony in italy, resident in italy, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('italy', read_fixture_file('worldwide/italy_organisations.json'))
      add_response 'italy'
      add_response 'other'
      add_response 'italy'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:italy_os_consular_cni_ceremony_italy, :consular_cni_all_what_you_need_to_do, :italy_os_consular_cni_uk_resident_three, :consular_cni_os_local_resident_italy, :italy_consular_cni_os_partner_local, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :consular_cni_os_local_resident_italy_two]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "ceremony in italy, resident in austria, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('italy', read_fixture_file('worldwide/italy_organisations.json'))
      worldwide_api_has_organisations_for_location('austria', read_fixture_file('worldwide/austria_organisations.json'))
      add_response 'italy'
      add_response 'other'
      add_response 'austria'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:italy_os_consular_cni_ceremony_italy, :consular_cni_all_what_you_need_to_do, :italy_os_consular_cni_uk_resident_three, :consular_cni_os_foreign_resident_ceremony_country_italy, :consular_cni_os_foreign_resident_3_days, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :consular_cni_os_foreign_resident_ceremony_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #variants for denmark
  context "ceremony in denmark, resident in canada, partner irish" do
    setup do
      worldwide_api_has_organisations_for_location('denmark', read_fixture_file('worldwide/denmark_organisations.json'))
      worldwide_api_has_organisations_for_location('canada', read_fixture_file('worldwide/canada_organisations.json'))
      add_response 'denmark'
      add_response 'other'
      add_response 'canada'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_denmark, :consular_cni_os_commonwealth_resident, :consular_cni_os_commonwealth_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_commonwealth_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #variants for germany
  context "ceremony in germany, resident in germany, partner irish" do
    setup do
      worldwide_api_has_organisations_for_location('germany', read_fixture_file('worldwide/germany_organisations.json'))
      add_response 'germany'
      add_response 'other'
      add_response 'germany'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_german_resident, :consular_cni_os_ceremony_germany_not_uk_resident]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #variants for uk residency (again)
  context "ceremony in azerbaijan, resident in scotland, partner non-irish" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      add_response 'azerbaijan'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :cni_at_local_register_office, :consular_cni_os_uk_resident_legalisation, :consular_cni_os_uk_resident_not_italy_or_portugal]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "ceremony in azerbaijan, resident in northern ireland, partner irish" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      add_response 'azerbaijan'
      add_response 'uk'
      add_response 'uk_ni'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :cni_at_local_register_office, :consular_cni_os_uk_resident_legalisation, :consular_cni_os_uk_resident_not_italy_or_portugal]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #variant for england and wales, irish partner - ceremony not italy
  context "ceremony in guatemala, resident in wales, partner irish" do
    setup do
      worldwide_api_has_organisations_for_location('guatemala', read_fixture_file('worldwide/guatemala_organisations.json'))
      add_response 'guatemala'
      add_response 'uk'
      add_response 'uk_wales'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_england_or_wales_resident_not_italy, :consular_cni_os_uk_resident_legalisation, :consular_cni_os_uk_resident_not_italy_or_portugal]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #variant for uk resident, ceremony not in italy
  context "ceremony in guatemala, resident in wales, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('guatemala', read_fixture_file('worldwide/guatemala_organisations.json'))
      add_response 'guatemala'
      add_response 'uk'
      add_response 'uk_wales'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :cni_at_local_register_office, :consular_cni_os_uk_resident_legalisation, :consular_cni_os_uk_resident_not_italy_or_portugal]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #variant for local resident, ceremony not in italy or germany
  context "ceremony in azerbaijan, resident in azerbaijan, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      add_response 'azerbaijan'
      add_response 'other'
      add_response 'azerbaijan'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :check_with_embassy_or_consulate, :embassies_data, :living_in_residence_country_3_days, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :display_notice_of_marriage_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  #variants for commonwealth or ireland resident
  context "ceremony in denmark, resident in canada, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('denmark', read_fixture_file('worldwide/denmark_organisations.json'))
      worldwide_api_has_organisations_for_location('canada', read_fixture_file('worldwide/canada_organisations.json'))
      add_response 'denmark'
      add_response 'other'
      add_response 'canada'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_denmark, :consular_cni_os_commonwealth_resident, :consular_cni_os_commonwealth_resident_british_partner, :consular_cni_os_commonwealth_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_british_partner, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_commonwealth_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "ceremony in denmark, resident in ireland, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('denmark', read_fixture_file('worldwide/denmark_organisations.json'))
      worldwide_api_has_organisations_for_location('ireland', read_fixture_file('worldwide/ireland_organisations.json'))
      add_response 'denmark'
      add_response 'other'
      add_response 'ireland'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ireland_resident]
      assert_phrase_list :consular_cni_os_remainder, []
    end
  end
  #variants for ireland residents
  context "ceremony in denmark, resident in ireland, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('denmark', read_fixture_file('worldwide/denmark_organisations.json'))
      worldwide_api_has_organisations_for_location('ireland', read_fixture_file('worldwide/ireland_organisations.json'))
      add_response 'denmark'
      add_response 'other'
      add_response 'ireland'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_denmark, :consular_cni_os_ireland_resident, :consular_cni_os_ireland_resident_british_partner, :consular_cni_os_ireland_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_british_partner, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_ireland_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "ceremony in denmark, resident in ireland, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('denmark', read_fixture_file('worldwide/denmark_organisations.json'))
      worldwide_api_has_organisations_for_location('ireland', read_fixture_file('worldwide/ireland_organisations.json'))
      add_response 'denmark'
      add_response 'other'
      add_response 'ireland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_denmark, :consular_cni_os_ireland_resident, :consular_cni_os_ireland_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_ireland_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #variants for commonwealth or ireland residents
  context "ceremony in denmark, resident in australia, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('denmark', read_fixture_file('worldwide/denmark_organisations.json'))
      worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
      add_response 'denmark'
      add_response 'other'
      add_response 'australia'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_denmark, :consular_cni_os_commonwealth_resident, :consular_cni_os_commonwealth_resident_british_partner, :consular_cni_os_commonwealth_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_british_partner, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_commonwealth_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "ceremony in denmark, resident in australia, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('denmark', read_fixture_file('worldwide/denmark_organisations.json'))
      worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
      add_response 'denmark'
      add_response 'other'
      add_response 'australia'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_denmark, :consular_cni_os_commonwealth_resident, :consular_cni_os_commonwealth_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_commonwealth_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #variant for local residents (not germany or spain)
  context "ceremony in denmark, resident in denmark, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('denmark', read_fixture_file('worldwide/denmark_organisations.json'))
      add_response 'denmark'
      add_response 'other'
      add_response 'denmark'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_denmark, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :check_with_embassy_or_consulate, :embassies_data, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :display_notice_of_marriage_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #variant for foreign resident
  context "ceremony in azerbaijan, resident in denmark, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      worldwide_api_has_organisations_for_location('denmark', read_fixture_file('worldwide/denmark_organisations.json'))
      add_response 'azerbaijan'
      add_response 'other'
      add_response 'denmark'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :consular_cni_os_foreign_resident_3_days, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :consular_cni_os_foreign_resident_ceremony_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #testing for spain variants
  context "ceremony in spain, resident in uk, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('spain', read_fixture_file('worldwide/spain_organisations.json'))
      add_response 'spain'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :spain_os_consular_cni_opposite_sex, :spain_os_consular_civil_registry, :spain_os_consular_cni_not_local_resident, :consular_cni_all_what_you_need_to_do, :spain_os_consular_cni_two, :cni_at_local_register_office, :consular_cni_os_uk_resident_legalisation, :consular_cni_os_uk_resident_not_italy_or_portugal]
      assert_phrase_list :consular_cni_os_remainder, [:partner_will_need_a_cni, :consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_ceremony_spain, :consular_cni_os_ceremony_spain_partner_british, :consular_cni_os_ceremony_spain_two, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "ceremony in spain, resident in spain, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('spain', read_fixture_file('worldwide/spain_organisations.json'))
      add_response 'spain'
      add_response 'other'
      add_response 'spain'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :spain_os_consular_cni_opposite_sex, :spain_os_consular_civil_registry, :consular_cni_all_what_you_need_to_do, :spain_os_consular_cni_two, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :check_with_embassy_or_consulate, :consular_cni_variant_local_resident_spain, :consular_cni_os_not_uk_resident_ceremony_not_germany, :spain_os_consular_cni_three]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_ceremony_spain, :consular_cni_os_ceremony_spain_two, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "ceremony in spain, resident in poland, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('spain', read_fixture_file('worldwide/spain_organisations.json'))
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'spain'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :spain_os_consular_cni_opposite_sex, :spain_os_consular_civil_registry, :spain_os_consular_cni_not_local_resident, :consular_cni_all_what_you_need_to_do, :spain_os_consular_cni_two, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :consular_cni_os_foreign_resident_3_days, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :consular_cni_os_foreign_resident_ceremony_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_ceremony_spain, :consular_cni_os_ceremony_spain_two, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  #variant for local residents (not germany or spain) again
  context "ceremony in poland, resident in poland, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'poland'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :check_with_embassy_or_consulate, :embassies_data, :living_in_residence_country_3_days, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :display_notice_of_marriage_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #variant for local resident (not germany or spain) or foreign residents
  context "ceremony in azerbaijan, resident in denmark, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      worldwide_api_has_organisations_for_location('denmark', read_fixture_file('worldwide/denmark_organisations.json'))
      add_response 'azerbaijan'
      add_response 'other'
      add_response 'denmark'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :consular_cni_os_foreign_resident_3_days, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :consular_cni_os_foreign_resident_ceremony_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "ceremony in azerbaijan, resident in azerbaijan, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      add_response 'azerbaijan'
      add_response 'other'
      add_response 'azerbaijan'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :check_with_embassy_or_consulate, :embassies_data, :living_in_residence_country_3_days, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :display_notice_of_marriage_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #variant for foreign resident, ceremony not in italy
  context "ceremony in azerbaijan, resident in poland, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'azerbaijan'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :consular_cni_os_foreign_resident_3_days, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :consular_cni_os_foreign_resident_ceremony_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #variant for commonwealth resident, ceremony not in italy
  context "ceremony in azerbaijan, resident in canada, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      worldwide_api_has_organisations_for_location('canada', read_fixture_file('worldwide/canada_organisations.json'))
      add_response 'azerbaijan'
      add_response 'other'
      add_response 'canada'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_commonwealth_resident, :consular_cni_os_commonwealth_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_commonwealth_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "ceremony in azerbaijan, resident in ireland, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      worldwide_api_has_organisations_for_location('ireland', read_fixture_file('worldwide/ireland_organisations.json'))
      add_response 'azerbaijan'
      add_response 'other'
      add_response 'ireland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_ireland_resident, :consular_cni_os_ireland_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_ireland_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  #tests using better code
  #testing for ceremony in poland, british partner
  context "ceremony in poland, resident in ireland, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      worldwide_api_has_organisations_for_location('ireland', read_fixture_file('worldwide/ireland_organisations.json'))
      add_response 'poland'
      add_response 'other'
      add_response 'ireland'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do,
 :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_ireland_resident,
 :consular_cni_os_ireland_resident_british_partner, :consular_cni_os_ireland_resident_two,
 :consular_cni_os_commonwealth_or_ireland_resident_british_partner, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_ireland_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #testing for belgium variant
  context "ceremony in belgium, resident in ireland, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('belgium', read_fixture_file('worldwide/belgium_organisations.json'))
      worldwide_api_has_organisations_for_location('ireland', read_fixture_file('worldwide/ireland_organisations.json'))
      add_response 'belgium'
      add_response 'other'
      add_response 'ireland'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_ireland_resident, :consular_cni_os_ireland_resident_british_partner, :consular_cni_os_ireland_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_british_partner, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_ireland_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_ceremony_belgium, :consular_cni_os_belgium_clickbook, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  #testing for azerbaijan variant
  context "ceremony in azerbaijan, resident in ireland, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      worldwide_api_has_organisations_for_location('ireland', read_fixture_file('worldwide/ireland_organisations.json'))
      add_response 'azerbaijan'
      add_response 'other'
      add_response 'ireland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_ireland_resident, :consular_cni_os_ireland_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_ireland_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #testing for uk resident variant
  context "ceremony in azerbaijan, resident in scotland, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      add_response 'azerbaijan'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :cni_at_local_register_office, :consular_cni_os_uk_resident_legalisation, :consular_cni_os_uk_resident_not_italy_or_portugal]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #testing for fee variant
  context "ceremony in armenia, resident in scotland, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('armenia', read_fixture_file('worldwide/armenia_organisations.json'))
      add_response 'armenia'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :cni_at_local_register_office, :consular_cni_os_uk_resident_legalisation, :consular_cni_os_uk_resident_not_italy_or_portugal]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_in_local_currency_ceremony_country_name]
    end
  end

  #France or french overseas territories outcome
  #testing for ceremony in french overseas territories
  context "ceremony in fot" do
    setup do
      worldwide_api_has_organisations_for_location('mayotte', read_fixture_file('worldwide/mayotte_organisations.json'))
      add_response 'mayotte'
    end
    should "go to marriage in france or fot outcome" do
      assert_current_node :outcome_os_france_or_fot
      assert_phrase_list :france_or_fot_os_outcome, [:fot_os_all]
    end
  end
  #testing for ceremony in france
  context "ceremony in france" do
    setup do
      worldwide_api_has_organisations_for_location('france', read_fixture_file('worldwide/france_organisations.json'))
      add_response 'france'
      add_response 'marriage'
    end
    should "go to france or fot marriage outcome" do
      assert_current_node :outcome_os_france_or_fot
    end
  end

  #tests for affirmation to marry outcomes
  #testing for ceremony in thailand, uk resident, partner other
  context "ceremony in thailand, resident in scotland, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('thailand', read_fixture_file('worldwide/thailand_organisations.json'))
      add_response 'thailand'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_uk_resident, :affirmation_os_all_what_you_need_to_do, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :affirmation_os_translation_in_local_language, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :affirmation_os_partner_not_british, :fee_table_affidavit_55, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  #testing for ceremony in egypt, local resident, partner british
  context "ceremony in egypt, resident in egypt, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('egypt', read_fixture_file('worldwide/egypt_organisations.json'))
      add_response 'egypt'
      add_response 'other'
      add_response 'egypt'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_local_resident, :affirmation_os_all_what_you_need_to_do, :what_you_need_to_do, :make_an_appointment, :embassies_data, :docs_decree_and_death_certificate, :change_of_name_evidence, :partner_declaration, :fee_table_45_55, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #testing for ceremony in lebanon, other resident, partner irish
  context "ceremony in lebanon, resident in poland, partner irish" do
    setup do
      worldwide_api_has_organisations_for_location('lebanon', read_fixture_file('worldwide/lebanon_organisations.json'))
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'lebanon'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_other_resident, :affirmation_os_all_what_you_need_to_do, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :affirmation_os_translation_in_local_language, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :affirmation_os_partner_not_british, :affirmation_os_all_fees_45_70, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #testing for ceremony in UAE, uk resident, partner other
  context "ceremony in UAE, resident in UAE, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('united-arab-emirates', read_fixture_file('worldwide/united-arab-emirates_organisations.json'))
      add_response 'united-arab-emirates'
      add_response 'other'
      add_response 'united-arab-emirates'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
    end
  end
  #testing for ceremony in Turkey, uk resident, partner british
  context "ceremony in Turkey, resident in Scotland, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('turkey', read_fixture_file('worldwide/turkey_organisations.json'))
      add_response 'turkey'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_uk_resident, :affirmation_os_all_what_you_need_to_do, :what_you_need_to_do, :appointment_for_affidavit_notary, :complete_affidavit, :download_affidavit, :affirmation_os_legalised, :documents_for_divorced_or_widowed, :affirmation_os_partner_not_british_turkey, :fee_table_affidavit_55, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #testing for ceremony in Turkey, local resident, partner other
  context "ceremony in Turkey, resident in Turkey, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('turkey', read_fixture_file('worldwide/turkey_organisations.json'))
      add_response 'turkey'
      add_response 'other'
      add_response 'turkey'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_local_resident, :affirmation_os_all_what_you_need_to_do, :what_you_need_to_do, :appointment_for_affidavit, :affirmation_appointment_book_at_following, :complete_affidavit, :download_affidavit, :affirmation_os_legalised_in_turkey, :documents_for_divorced_or_widowed, :affirmation_os_partner_not_british_turkey, :fee_table_affidavit_55, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  #tests for no cni or consular services
  #testing for dutch caribbean islands
  context "ceremony in aruba, resident in scotland, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('aruba', read_fixture_file('worldwide/aruba_organisations.json'))
      add_response 'aruba'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni_dutch_caribbean_islands, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :cni_at_local_register_office, :consular_cni_os_uk_resident_legalisation, :consular_cni_os_uk_resident_not_italy_or_portugal]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk]
    end
  end
  context "ceremony in aruba, resident in aruba, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('aruba', read_fixture_file('worldwide/aruba_organisations.json'))
      add_response 'aruba'
      add_response 'other'
      add_response 'aruba'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:no_cni_os_dutch_caribbean_islands, :no_cni_os_dutch_caribbean_islands_local_resident, :get_legal_advice, :cni_os_consular_facilities_unavailable]
    end
  end
  #testing for ceremony in aruba, other resident, partner irish
  context "ceremony in aruba, resident in poland, partner irish" do
    setup do
      worldwide_api_has_organisations_for_location('aruba', read_fixture_file('worldwide/aruba_organisations.json'))
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'aruba'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:no_cni_os_dutch_caribbean_islands, :no_cni_os_dutch_caribbean_other_resident, :get_legal_advice, :cni_os_consular_facilities_unavailable, :no_cni_os_naturalisation]
    end
  end
  #testing for ceremony in cote-d-ivoire, uk resident, partner british
  context "ceremony in cote-d-ivoire, uk resident, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('cote-d-ivoire', read_fixture_file('worldwide/cote-d-ivoire_organisations.json'))
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/cote-d-ivoire_organisations.json'))
      add_response 'cote-d-ivoire'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :cni_at_local_register_office, :consular_cni_os_uk_resident_legalisation, :consular_cni_os_uk_resident_not_italy_or_portugal]
      assert_phrase_list :consular_cni_os_remainder, [:partner_will_need_a_cni, :consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_fees_not_italy_not_uk]
      assert_state_variable :pay_by_cash_or_credit_card_no_cheque, nil
    end
  end
  #testing for ceremony in cote-d-ivoire, other resident, partner british
  context "ceremony in cote-d-ivoire, resident in poland, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('cote-d-ivoire', read_fixture_file('worldwide/cote-d-ivoire_organisations.json'))
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'cote-d-ivoire'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go os no cni outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:no_cni_os_not_dutch_caribbean_other_resident, :get_legal_advice, :cni_os_consular_facilities_unavailable]
    end
  end

  #testing for ceremony in monaco
  context "ceremony in monaco, maps to France, marriage" do
    setup do
      worldwide_api_has_organisations_for_location('monaco', read_fixture_file('worldwide/monaco_organisations.json'))
      add_response 'monaco'
      add_response 'marriage'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_france_or_fot
    end
  end
  context "ceremony in monaco, maps to France, pacs" do
    setup do
      worldwide_api_has_organisations_for_location('monaco', read_fixture_file('worldwide/monaco_organisations.json'))
      add_response 'monaco'
      add_response 'pacs'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_cp_france_pacs
    end
  end
  #testing for ceremony in usa
  context "ceremony in usa, resident in poland, partner irish" do
    setup do
      worldwide_api_has_organisations_for_location('usa', read_fixture_file('worldwide/usa_organisations.json'))
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'usa'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:no_cni_os_not_dutch_caribbean_other_resident, :get_legal_advice, :cni_os_consular_facilities_unavailable, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque, :no_cni_os_naturalisation]
    end
  end

  #testing for ceremony in argentina
  context "ceremony in argentina, resident in poland, partner irish" do
    setup do
      worldwide_api_has_organisations_for_location('argentina', read_fixture_file('worldwide/argentina_organisations.json'))
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'argentina'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:no_cni_os_not_dutch_caribbean_other_resident, :get_legal_advice, :cni_os_consular_facilities_unavailable, :no_cni_os_naturalisation]
    end
  end
  #testing for other countries
  #testing for burma
  context "ceremony in burma, resident in scotland, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('burma', read_fixture_file('worldwide/burma_organisations.json'))
      add_response 'burma'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_burma, :other_countries_os_burma_partner_local]
    end
  end
  context "ceremony in burundi, resident not in uk, partner anywhere" do
    setup do
      worldwide_api_has_organisations_for_location('burundi', read_fixture_file('worldwide/burundi_organisations.json'))
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'burundi'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:no_cni_os_not_dutch_caribbean_other_resident, :get_legal_advice, :cni_os_consular_facilities_unavailable, :no_cni_os_naturalisation]
    end
  end
  #testing for north korea
  context "ceremony in north korea, resident in scotland, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('north-korea', read_fixture_file('worldwide/north-korea_organisations.json'))
      add_response 'north-korea'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_north_korea, :other_countries_os_north_korea_partner_local]
    end
  end
  #testing for iran
  context "ceremony in iran, resident in scotland, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('iran', read_fixture_file('worldwide/iran_organisations.json'))
      add_response 'iran'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_iran_somalia_syria]
    end
  end
  #testing for yemen
  context "ceremony in yemen, resident in scotland, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('yemen', read_fixture_file('worldwide/yemen_organisations.json'))
      add_response 'yemen'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_yemen]
    end
  end
  #testing for saudi arabia, not local resident
  context "ceremony in saudi arabia, resident in scotland, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('saudi-arabia', read_fixture_file('worldwide/saudi-arabia_organisations.json'))
      add_response 'saudi-arabia'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_ceremony_saudia_arabia_not_local_resident]
    end
  end
  #testing for saudi arabia, local resident, partner irish
  context "ceremony in saudi arabia, resident in saudi arabia, partner irish" do
    setup do
      worldwide_api_has_organisations_for_location('saudi-arabia', read_fixture_file('worldwide/saudi-arabia_organisations.json'))
      add_response 'saudi-arabia'
      add_response 'other'
      add_response 'saudi-arabia'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_saudi_arabia_local_resident_partner_irish]
    end
  end
  #testing for saudi arabia, local resident, partner british
  context "ceremony in saudi arabia, resident in saudi arabia, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('saudi-arabia', read_fixture_file('worldwide/saudi-arabia_organisations.json'))
      add_response 'saudi-arabia'
      add_response 'other'
      add_response 'saudi-arabia'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_saudi_arabia_local_resident_partner_not_irish, :other_countries_os_saudi_arabia_local_resident_partner_not_irish_two]
    end
  end
  #testing for saudi arabia, local resident, partner other
  context "ceremony in saudi arabia, resident in saudi arabia, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('saudi-arabia', read_fixture_file('worldwide/saudi-arabia_organisations.json'))
      add_response 'saudi-arabia'
      add_response 'other'
      add_response 'saudi-arabia'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_saudi_arabia_local_resident_partner_not_irish, :other_countries_os_saudi_arabia_local_resident_partner_not_irish_or_british, :other_countries_os_saudi_arabia_local_resident_partner_not_irish_two]
    end
  end

  #testing for ceremony in spain, england resident, british partner
  context "ceremony in spain, resident in england, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('spain', read_fixture_file('worldwide/spain_organisations.json'))
      add_response 'spain'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to cp or equivalent outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :spain_os_consular_cni_same_sex, :spain_os_consular_civil_registry, :spain_os_consular_cni_not_local_resident, :consular_cni_all_what_you_need_to_do, :spain_os_consular_cni_two, :cni_at_local_register_office, :consular_cni_os_uk_resident_legalisation, :consular_cni_os_uk_resident_not_italy_or_portugal]
      assert_phrase_list :consular_cni_os_remainder, [:partner_will_need_a_cni, :consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_ceremony_spain, :consular_cni_os_ceremony_spain_partner_british, :consular_cni_os_ceremony_spain_two, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  #testing for CNI variant for russian-federation
  context "ceremony in russia, resident in russia, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('russia', read_fixture_file('worldwide/russia_organisations.json'))
      add_response 'russia'
      add_response 'other'
      add_response 'russia'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to russia CNI outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :russia_os_local_resident, :living_in_residence_country_3_days, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :display_notice_of_marriage_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :consular_cni_os_fees_russia]
    end
  end

  #testing for civil partnership in countries with CP or equivalent
  context "ceremony in denmark, resident in england, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('denmark', read_fixture_file('worldwide/denmark_organisations.json'))
      add_response 'denmark'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to cp or equivalent outcome" do
      assert_current_node :outcome_cp_cp_or_equivalent
      assert_phrase_list :cp_or_equivalent_cp_outcome, [:"cp_or_equivalent_cp_denmark", :cp_or_equivalent_cp_uk_resident, :cp_or_equivalent_cp_all_what_you_need_to_do, :cp_or_equivalent_cp_naturalisation, :cp_or_equivalent_cp_all_fees, :list_of_consular_fees , :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #testing for ceremony in czech republic, other resident, local partner
  context "ceremony in czech republic, resident in poland, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('czech-republic', read_fixture_file('worldwide/czech-republic_organisations.json'))
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'czech-republic'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to cp or equivalent outcome" do
      assert_current_node :outcome_cp_cp_or_equivalent
      assert_state_variable :country_name_lowercase_prefix, 'the Czech Republic'
      assert_phrase_list :cp_or_equivalent_cp_outcome, [:"cp_or_equivalent_cp_czech-republic", :cp_or_equivalent_cp_other_resident, :cp_or_equivalent_cp_all_what_you_need_to_do, :cp_or_equivalent_cp_naturalisation, :cp_or_equivalent_cp_all_fees]
      assert_state_variable :pay_by_cash_or_credit_card_no_cheque, nil
    end
  end
  #testing for ceremony in sweden, sweden resident, irish partner
  context "ceremony in sweden, resident in sweden, partner irish" do
    setup do
      worldwide_api_has_organisations_for_location('sweden', read_fixture_file('worldwide/sweden_organisations.json'))
      add_response 'sweden'
      add_response 'other'
      add_response 'sweden'
      add_response 'partner_irish'
      add_response 'same_sex'
    end
    should "go to cp or equivalent os outcome" do
      assert_current_node :outcome_cp_cp_or_equivalent
      assert_phrase_list :cp_or_equivalent_cp_outcome, [:cp_or_equivalent_cp_sweden, :cp_or_equivalent_cp_local_resident, :cp_or_equivalent_cp_all_what_you_need_to_do, :cp_or_equivalent_cp_naturalisation, :cp_or_equivalent_cp_all_fees, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #testing for civil partnership in France, or french overseas territories with PACS law
  #testing for ceremony in france, pacs
  context "ceremony in france, " do
    setup do
      worldwide_api_has_organisations_for_location('france', read_fixture_file('worldwide/france_organisations.json'))
      add_response 'france'
      add_response 'pacs'
    end
    should "go to fran ce ot fot PACS outcome" do
      assert_current_node :outcome_cp_france_pacs
    end
  end
  #testing for ceremony in wallis and futuna, pacs
  context "ceremony in wallis and futuna, pacs" do
    setup do
      worldwide_api_has_organisations_for_location('wallis-and-futuna', read_fixture_file('worldwide/wallis-and-futuna_organisations.json'))
      add_response 'wallis-and-futuna'
      add_response 'pacs'
    end
    should "go to france or fot pacs outcome" do
      assert_current_node :outcome_cp_france_pacs
      assert_phrase_list :france_pacs_law_cp_outcome, [:fot_cp_all]
    end
  end

  #testing for CP in countries where cni not required
  #testing for ceremony in united states, england resident, local partner
  context "ceremony in US, resident in ni, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('usa', read_fixture_file('worldwide/usa_organisations.json'))
      add_response 'usa'
      add_response 'uk'
      add_response 'uk_ni'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to cp no cni required outcome" do
      assert_current_node :outcome_cp_no_cni
      assert_state_variable :country_name_lowercase_prefix, 'the USA'
      assert_phrase_list :no_cni_required_cp_outcome, [:"no_cni_required_cp_usa", :no_cni_required_all_legal_advice, :no_cni_required_cp_ceremony_us, :no_cni_required_all_what_you_need_to_do, :no_cni_required_cp_not_dutch_islands_uk_resident, :no_cni_required_cp_all_consular_facilities, :no_cni_required_cp_naturalisation]
    end
  end
  #testing for ceremony in bonaire, england resident, other partner
  context "ceremony in bonaire, resident in scotland, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('bonaire-st-eustatius-saba', read_fixture_file('worldwide/bonaire-st-eustatius-saba_organisations.json'))
      add_response 'bonaire-st-eustatius-saba'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to cp no cni required outcome" do
      assert_current_node :outcome_cp_no_cni
      assert_phrase_list :no_cni_required_cp_outcome, [:"no_cni_required_cp_bonaire-st-eustatius-saba", :no_cni_required_all_legal_advice, :no_cni_required_all_what_you_need_to_do, :no_cni_required_cp_dutch_islands, :no_cni_required_cp_dutch_islands_uk_resident, :no_cni_required_cp_all_consular_facilities, :no_cni_required_cp_naturalisation]
    end
  end
  #testing for ceremony in bonaire, bonaire resident, british partner
  context "ceremony in bonaire, resident in bonaire, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('bonaire-st-eustatius-saba', read_fixture_file('worldwide/bonaire-st-eustatius-saba_organisations.json'))
      add_response 'bonaire-st-eustatius-saba'
      add_response 'other'
      add_response 'bonaire-st-eustatius-saba'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to cp no cni required outcome" do
      assert_current_node :outcome_cp_no_cni
      assert_phrase_list :no_cni_required_cp_outcome, [:"no_cni_required_cp_bonaire-st-eustatius-saba", :no_cni_required_all_legal_advice, :no_cni_required_all_what_you_need_to_do, :no_cni_required_cp_dutch_islands, :no_cni_required_cp_dutch_islands_local_resident, :no_cni_required_cp_all_consular_facilities]
    end
  end
  #testing for ceremony in bonaire, other resident, irish partner
  context "ceremony in bonaire, resident in mexico, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('bonaire-st-eustatius-saba', read_fixture_file('worldwide/bonaire-st-eustatius-saba_organisations.json'))
      worldwide_api_has_organisations_for_location('mexico', read_fixture_file('worldwide/mexico_organisations.json'))
      add_response 'bonaire-st-eustatius-saba'
      add_response 'other'
      add_response 'mexico'
      add_response 'partner_irish'
      add_response 'same_sex'
    end
    should "go to cp no cni required outcome" do
      assert_current_node :outcome_cp_no_cni
      assert_phrase_list :no_cni_required_cp_outcome, [:"no_cni_required_cp_bonaire-st-eustatius-saba", :no_cni_required_all_legal_advice, :no_cni_required_all_what_you_need_to_do, :no_cni_required_cp_dutch_islands, :no_cni_required_cp_dutch_islands_other_resident, :no_cni_required_cp_all_consular_facilities, :no_cni_required_cp_naturalisation]
    end
  end

  #testing for CP in commonwealth countries outcomes
  #testing for ceremony in canada, uk resident, other partner
  context "ceremony in canada, uk resident, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('canada', read_fixture_file('worldwide/canada_organisations.json'))
      add_response 'canada'
      add_response 'uk'
      add_response 'uk_ni'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to cp commonwealth countries outcome" do
      assert_current_node :outcome_cp_commonwealth_countries
      assert_phrase_list :commonwealth_countries_cp_outcome, [:commonwealth_countries_cp_canada, :commonwealth_countries_cp_uk_resident_two, :embassies_data, :commonwealth_countries_cp_naturalisation]
    end
  end

  #testing for CP in countries with consular cni (not australia)
  # testing for czech republic with non-local partner
  context "ceremony in czech-republic, uk resident, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('czech-republic', read_fixture_file('worldwide/czech-republic_organisations.json'))
      add_response 'czech-republic'
      add_response 'uk'
      add_response 'uk_wales'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to consular cni cp countries outcome" do
      assert_current_node :outcome_cp_cp_or_equivalent
      assert_phrase_list :cp_or_equivalent_cp_outcome, [:"cp_or_equivalent_cp_czech-republic", :cp_or_equivalent_cp_uk_resident, :cp_or_equivalent_cp_all_what_you_need_to_do, :cp_or_equivalent_cp_naturalisation, :cp_or_equivalent_cp_all_fees]
      assert_state_variable :pay_by_cash_or_credit_card_no_cheque, nil
    end
  end
  # testing for vietnam with local partner
  context "ceremony in vietnam, uk resident, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('vietnam', read_fixture_file('worldwide/vietnam_organisations.json'))
      add_response 'vietnam'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to all other countries outcome" do
      assert_current_node :outcome_ss_marriage_not_possible
    end
  end
  # testing for latvia, other resident, british partner
  context "ceremony in latvia, cyprus resident, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('latvia', read_fixture_file('worldwide/latvia_organisations.json'))
      worldwide_api_has_organisations_for_location('cyprus', read_fixture_file('worldwide/cyprus_organisations.json'))
      add_response 'latvia'
      add_response 'other'
      add_response 'cyprus'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to consular cni cp countries outcome" do
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage, :contact_embassy_or_consulate, :embassies_data, :documents_needed_ss_british, :what_to_do_ss_marriage, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage, :provide_two_witnesses_ss_marriage, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_alt, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  #testing for other countries outcome
  # testing for serbia, other resident, british partner
  context "ceremony in serbia, cyprus resident, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('serbia', read_fixture_file('worldwide/serbia_organisations.json'))
      worldwide_api_has_organisations_for_location('cyprus', read_fixture_file('worldwide/cyprus_organisations.json'))
      add_response 'serbia'
      add_response 'other'
      add_response 'cyprus'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to cp all other countries outcome" do
      assert_current_node :outcome_ss_marriage
    end
  end

  #testing for nicaragua
  context "ceremony in nicaragua, resident in poland, partner irish" do
    setup do
      worldwide_api_has_organisations_for_location('nicaragua', read_fixture_file('worldwide/nicaragua_organisations.json'))
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'nicaragua'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:no_cni_os_not_dutch_caribbean_other_resident, :get_legal_advice, :cni_os_consular_facilities_unavailable, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque, :no_cni_os_naturalisation]
    end
  end

  #testing for Iom and Ci residents
  context "ceremony in australia, resident in isle of man" do
    setup do
      worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
      add_response 'australia'
      add_response 'uk'
      add_response 'uk_iom'
      add_response 'partner_local'
      add_response "same_sex"
    end
    should "go to iom/ci os outcome" do
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_title, [:title_ss_marriage]
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage, :contact_embassy_or_consulate, :embassies_data, :documents_needed_ss_not_british, :what_to_do_ss_marriage, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage, :provide_two_witnesses_ss_marriage, :australia_ss_relationships, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_alt, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "australia opposite sex outcome" do
    should "bring you to australia os outcome" do
      worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
      add_response 'australia'
      add_response 'other'
      add_response 'australia'
      add_response 'partner_british'
      add_response 'same_sex'
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_title, [:title_ss_marriage]
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage, :contact_embassy_or_consulate, :embassies_data, :documents_needed_ss_british, :what_to_do_ss_marriage, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage, :provide_two_witnesses_ss_marriage, :australia_ss_relationships, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_alt, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "ceremony in italy, resident in channel islands" do
    setup do
      worldwide_api_has_organisations_for_location('italy', read_fixture_file('worldwide/italy_organisations.json'))
      add_response 'italy'
      add_response 'uk'
      add_response 'uk_ci'
    end
    should "go to iom/ci os outcome" do
      assert_current_node :outcome_os_iom_ci
      assert_phrase_list :iom_ci_os_outcome, [:iom_ci_os_all, :iom_ci_os_resident_of_ci, :iom_ci_os_ceremony_italy]
    end
  end
  #testing for china living outside uk
  context "ceremony in china, resident in china" do
    should "render multiple clickbooks" do
      worldwide_api_has_organisations_for_location('china', read_fixture_file('worldwide/china_organisations.json'))
      add_response 'china'
      add_response 'other'
      add_response 'china'
      add_response 'partner_local'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_local_resident, :affirmation_os_all_what_you_need_to_do, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :appointment_for_affidavit_china_addition, :affirmation_os_translation_in_local_language, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :affirmation_os_partner_not_british, :fee_table_affidavit_55, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #testing for japan
  context "ceremony in japan, resident in japan" do
    should "give os outcome with japan variants" do
      worldwide_api_has_organisations_for_location('japan', read_fixture_file('worldwide/japan_organisations.json'))
      add_response 'japan'
      add_response 'other'
      add_response 'japan'
      add_response 'partner_local'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :check_with_embassy_or_consulate, :japan_consular_cni_os_local_resident, :japan_consular_cni_os_local_resident_partner_local, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :display_notice_of_marriage_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:japan_consular_cni_os_local_resident_two, :consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "ceremony in japan, resident in japan" do
    should "give ss outcome with japan variants" do
      worldwide_api_has_organisations_for_location('japan', read_fixture_file('worldwide/japan_organisations.json'))
      add_response 'japan'
      add_response 'other'
      add_response 'japan'
      add_response 'partner_local'
      add_response 'same_sex'
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage_and_partnership, :consular_cp_japan, :what_to_do_ss_marriage_and_partnership, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage_and_partnership, :provide_two_witnesses_ss_marriage_and_partnership, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_and_partnership, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  #testing for vietnam
  context "testing that Vietnam is now affirmation to marry outcome" do
    should "give the outcome" do
      worldwide_api_has_organisations_for_location('vietnam', read_fixture_file('worldwide/vietnam_organisations.json'))
      add_response 'vietnam'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_local'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_affirmation
      assert_state_variable :ceremony_type_lowercase, 'marriage'
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_uk_resident, :affirmation_os_all_what_you_need_to_do, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :affirmation_os_translation_in_local_language, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :affirmation_os_partner_not_british, :fee_table_affidavit_55, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  #testing for switzerland variants
  context "ceremony in switzerland, resident in switzerland, partner opposite sex" do
    should "give swiss outcome with variants (gender variant)" do
      worldwide_api_has_organisations_for_location('switzerland', read_fixture_file('worldwide/switzerland_organisations.json'))
      add_response 'switzerland'
      add_response 'uk'
      add_response 'opposite_sex'
      assert_current_node :outcome_switzerland
      assert_state_variable :ceremony_type_lowercase, 'marriage'
      assert_phrase_list :switzerland_marriage_outcome, [:switzerland_os_variant, :what_you_need_to_do_switzerland_resident_uk, :switzerland_not_resident, :switzerland_os_not_resident, :switzerland_not_resident_two]
    end
  end
  context "ceremony in switzerland, resident in switzerland, partner same sex" do
    should "give swiss outcome with variants" do
      worldwide_api_has_organisations_for_location('switzerland', read_fixture_file('worldwide/switzerland_organisations.json'))
      add_response 'switzerland'
      add_response 'other'
      add_response 'switzerland'
      add_response 'same_sex'
      assert_current_node :outcome_switzerland
      assert_state_variable :ceremony_type_lowercase, 'civil partnership'
      assert_phrase_list :switzerland_marriage_outcome, [:switzerland_ss_variant]
    end
  end
  context "ceremony in switzerland, not resident in switzerland, partner opposite sex" do
    should "give swiss outcome with variants" do
      worldwide_api_has_organisations_for_location('switzerland', read_fixture_file('worldwide/switzerland_organisations.json'))
      add_response 'switzerland'
      add_response 'uk'
      add_response 'same_sex'
      assert_current_node :outcome_switzerland
      assert_state_variable :ceremony_type_lowercase, 'civil partnership'
      assert_phrase_list :switzerland_marriage_outcome, [:switzerland_ss_variant, :what_you_need_to_do_switzerland_resident_uk, :switzerland_not_resident, :switzerland_ss_not_resident, :switzerland_not_resident_two]
    end
  end
  context "ceremony in switzerland, not resident in switzerland, partner same sex" do
    should "give swiss outcome with variants" do
      worldwide_api_has_organisations_for_location('switzerland', read_fixture_file('worldwide/switzerland_organisations.json'))
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'switzerland'
      add_response 'other'
      add_response 'poland'
      add_response 'opposite_sex'
      assert_current_node :outcome_switzerland
      assert_state_variable :ceremony_type_lowercase, 'marriage'
      assert_phrase_list :switzerland_marriage_outcome, [:switzerland_os_variant, :switzerland_not_resident, :switzerland_os_not_resident, :switzerland_not_resident_two]
    end
  end
  context "peru outcome mapped to lebanon" do
    should "go to outcome cp all other countries" do
      worldwide_api_has_organisations_for_location('peru', read_fixture_file('worldwide/peru_organisations.json'))
      add_response 'peru'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'same_sex'
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage_and_partnership, :book_online_peru, :documents_needed_ss_british, :what_to_do_ss_marriage_and_partnership, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage_and_partnership, :provide_two_witnesses_ss_marriage_and_partnership, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_and_partnership, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "peru outcome mapped to lebanon" do
    should "go to outcome os affirmation" do
      worldwide_api_has_organisations_for_location('peru', read_fixture_file('worldwide/peru_organisations.json'))
      add_response 'peru'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_affirmation
    end
  end
  context "portugal has his own outcome" do
    should "go to portugal outcome" do
      worldwide_api_has_organisations_for_location('portugal', read_fixture_file('worldwide/portugal_organisations.json'))
      add_response 'portugal'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_portugal
    end
  end

  context "ceremony in finland, resident in the UK, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('finland', read_fixture_file('worldwide/finland_organisations.json'))
      add_response 'finland'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to cni outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_remainder, [:partner_will_need_a_cni, :consular_cni_os_all_names_but_germany, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_in_euros_or_visa_electron]
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :cni_at_local_register_office, :consular_cni_os_uk_legalisation_check_with_authorities, :consular_cni_os_uk_resident_not_italy_or_portugal]
     end
  end

  context "ceremony in finland, resident in the UK, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('finland', read_fixture_file('worldwide/finland_organisations.json'))
      add_response 'finland'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to cni outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_remainder, [:partner_will_need_a_cni, :consular_cni_os_all_names_but_germany, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_in_euros_or_visa_electron]
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :cni_at_local_register_office, :consular_cni_os_uk_legalisation_check_with_authorities, :consular_cni_os_uk_resident_not_italy_or_portugal]
     end
  end

  context "ceremony in finland, resident in Australia, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('finland', read_fixture_file('worldwide/finland_organisations.json'))
      worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
      add_response 'finland'
      add_response 'other'
      add_response 'australia'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to affirmation outcome with specific fee table" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_other_resident, :affirmation_os_all_what_you_need_to_do, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :clickbook_link, :affirmation_os_translation_in_local_language, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :affirmation_os_partner_not_british, :fee_table_affirmation_65, :list_of_consular_fees, :pay_in_euros_or_visa_electron]
    end
  end

  context "ceremony in finland, resident in the UK, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('finland', read_fixture_file('worldwide/finland_organisations.json'))
      add_response 'finland'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to outcome cni with specific fee table" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_remainder, [:callout_partner_equivalent_document, :consular_cni_os_all_names_but_germany, :consular_cni_os_naturalisation, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_in_euros_or_visa_electron]
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :cni_at_local_register_office, :consular_cni_os_uk_legalisation_check_with_authorities, :consular_cni_os_uk_resident_not_italy_or_portugal]
    end
  end

  context "ceremony in finland, resident in the UK, partner Irish OS" do
    setup do
      worldwide_api_has_organisations_for_location('finland', read_fixture_file('worldwide/finland_organisations.json'))
      worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
      add_response 'finland'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to affirmation outcome with specific fee table" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_uk_resident, :affirmation_os_all_what_you_need_to_do, :what_you_need_to_do_affidavit, :appointment_for_affidavit, :clickbook_link, :affidavit_os_translation_in_local_language, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :affirmation_os_partner_not_british, :fee_table_affidavit_65, :list_of_consular_fees, :pay_in_euros_or_visa_electron]
    end
  end

  context "ceremony in finland, resident in the UK, partner Irish SS" do
    setup do
      worldwide_api_has_organisations_for_location('finland', read_fixture_file('worldwide/finland_organisations.json'))
      worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
      add_response 'finland'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_irish'
      add_response 'same_sex'
    end
    should "go to affirmation outcome with specific fee table" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_uk_resident, :affirmation_os_all_what_you_need_to_do, :what_you_need_to_do_affidavit, :appointment_for_affidavit, :clickbook_link, :affidavit_os_translation_in_local_language, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :affirmation_os_partner_not_british, :fee_table_affidavit_65, :list_of_consular_fees, :pay_in_euros_or_visa_electron]
    end
  end

  context "south-korea new outcome" do
    should "go to outcome os affirmation with new korea phraselist" do
      worldwide_api_has_organisations_for_location('south-korea', read_fixture_file('worldwide/south-korea_organisations.json'))
      add_response 'south-korea'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_uk_resident, :affirmation_os_all_what_you_need_to_do, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :affirmation_os_translation_in_local_language, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :affirmation_os_partner_british, :fee_table_affidavit_55, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  #testing for ceremony in philippines, uk resident, partner other
  context "ceremony in philippines, uk resident, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('philippines', read_fixture_file('worldwide/philippines_organisations.json'))
      add_response 'philippines'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_uk_resident, :affirmation_os_all_what_you_need_to_do, :what_you_need_to_do_affirmation, :contact_for_affidavit, :make_appointment_online_philippines, :affirmation_os_translation_in_local_language, :affirmation_os_download_affidavit_philippines, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :affirmation_os_partner_not_british, :fee_table_55_70, :list_of_consular_fees, :pay_in_cash_or_manager_cheque]
    end
  end

  context "slovakia, no money phraselists" do
    should "" do
      worldwide_api_has_organisations_for_location('slovakia', read_fixture_file('worldwide/slovakia_organisations.json'))
      add_response 'slovakia'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:no_cni_os_not_dutch_caribbean_islands_uk_resident, :get_legal_advice, :cni_os_consular_facilities_unavailable]
    end
  end

  context "netherlands outcome" do
    should "bring you to netherlands outcome" do
      worldwide_api_has_organisations_for_location('netherlands', read_fixture_file('worldwide/netherlands_organisations.json'))
      add_response 'netherlands'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_netherlands
      assert_phrase_list :netherlands_phraselist, [:contact_local_authorities, :get_legal_advice, :partner_naturalisation_in_uk]
    end
  end

  context "indonesia opposite sex outcome" do
    should "bring you to indonesia os outcome" do
      worldwide_api_has_organisations_for_location('indonesia', read_fixture_file('worldwide/indonesia_organisations.json'))
      add_response 'indonesia'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_indonesia
      assert_phrase_list :indonesia_os_phraselist, [:appointment_for_affidavit, :complete_affidavit_with_download_link, :embassies_data, :documents_for_divorced_or_widowed, :partner_affidavit_needed, :fee_table_45_70_55]
    end
  end
  context "aruba opposite sex outcome" do
    should "bring you to aruba os outcome" do
      worldwide_api_has_organisations_for_location('aruba', read_fixture_file('worldwide/aruba_organisations.json'))
      add_response 'aruba'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_remainder, [:partner_will_need_a_cni, :consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_fees_not_italy_not_uk]
    end
  end
  context "ceremony in azerbaijan, resident in northern ireland, partner irish" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      add_response 'azerbaijan'
      add_response 'uk'
      add_response 'uk_ni'
      add_response 'partner_irish'
      add_response 'same_sex'
    end
    should "go to outcome_ss_marriage" do
      assert_current_node :outcome_ss_marriage
    end
  end
  context "uk resident, ceremony in estonia, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('estonia', read_fixture_file('worldwide/estonia_organisations.json'))
      add_response 'estonia'
      add_response 'uk'
      add_response 'uk_wales'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_title, [:title_ss_marriage]
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage, :contact_embassy_or_consulate, :embassies_data, :documents_needed_ss_british, :what_to_do_ss_marriage, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage, :provide_two_witnesses_ss_marriage, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_alt, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "ceremony in russia, lives in poland, same sex marriage, non british partner" do
    setup do
      worldwide_api_has_organisations_for_location('russia', read_fixture_file('worldwide/russia_organisations.json'))
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'russia'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to outcome_ss_marriage_not_possible" do
      assert_current_node :outcome_ss_marriage_not_possible
    end
  end
  context "ceremony in cambodia, lives in poland, same sex marriage, non british partner" do
    setup do
      worldwide_api_has_organisations_for_location('cambodia', read_fixture_file('worldwide/cambodia_organisations.json'))
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'cambodia'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to outcome_ss_marriage" do
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage_and_partnership, :contact_embassy_or_consulate, :embassies_data, :documents_needed_ss_not_british, :what_to_do_ss_marriage_and_partnership, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage_and_partnership, :provide_two_witnesses_ss_marriage_and_partnership, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_and_partnership, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "Marrying anywhere in the world > British National not living in the UK > Resident in Portugal > Partner of any nationality > Opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('portugal', read_fixture_file('worldwide/portugal_organisations.json'))
      worldwide_api_has_organisations_for_location('vietnam', read_fixture_file('worldwide/vietnam_organisations.json'))
      add_response 'vietnam'
      add_response 'other'
      add_response 'portugal'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to affirmation_os_outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_other_resident, :affirmation_os_all_what_you_need_to_do, :what_you_need_to_do_affirmation, :book_online_portugal, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :affirmation_os_partner_not_british, :fee_table_affidavit_55, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "kazakhstan should show its correct embassy page" do
    setup do
      worldwide_api_has_organisations_for_location('kazakhstan', read_fixture_file('worldwide/kazakhstan_organisations.json'))
      worldwide_api_has_organisations_for_location('american-samoa', read_fixture_file('worldwide/american-samoa_organisations.json'))
      add_response 'kazakhstan'
      add_response 'other'
      add_response 'american-samoa'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to affirmation_os_outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :consular_cni_os_foreign_resident_3_days, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :consular_cni_os_foreign_resident_ceremony_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident_kazakhstan, :pay_in_local_currency_ceremony_country_name]
    end
  end
  context "Marrying anywhere in the world > British National not living in the UK > Resident in Portugal > Partner of any nationality > Opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('portugal', read_fixture_file('worldwide/portugal_organisations.json'))
      worldwide_api_has_organisations_for_location('vietnam', read_fixture_file('worldwide/vietnam_organisations.json'))
      add_response 'portugal'
      add_response 'other'
      add_response 'vietnam'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to portugal outcome" do
      assert_current_node :outcome_portugal
      assert_phrase_list :portugal_title, [:marriage_title]
    end
  end
  context "Marrying anywhere in the world > British National not living in the UK > Resident in Portugal > Partner of any nationality > Opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('portugal', read_fixture_file('worldwide/portugal_organisations.json'))
      add_response 'portugal'
      add_response 'uk'
      add_response 'uk_iom'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to portugal outcome" do
      assert_current_node :outcome_portugal
      assert_phrase_list :portugal_title, [:marriage_title]
    end
  end
  context "Residency Country and ceremony country = Croatia" do
    setup do
      worldwide_api_has_organisations_for_location('croatia', read_fixture_file('worldwide/croatia_organisations.json'))
      add_response 'croatia'
      add_response 'other'
      add_response 'croatia'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to outcome_os_consular_cni and show specific phraselist" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :what_to_do_croatia, :consular_cni_os_local_resident_table, :make_appointment_online_croatia, :living_in_residence_country_3_days, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :display_notice_of_marriage_7_days]
    end
  end
  context "Marrying in Qatar > Resident in Qatar > Partner is British > Partner is opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('qatar', read_fixture_file('worldwide/croatia_organisations.json'))
      add_response 'qatar'
      add_response 'other'
      add_response 'qatar'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to outcome_os_consular_cni and show specific phraselist" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_local_resident, :gulf_states_os_consular_cni, :gulf_states_os_consular_cni_local_resident_partner_not_irish, :affirmation_os_all_what_you_need_to_do, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :affirmation_os_translation_in_local_language, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :affirmation_os_partner_not_british, :fee_table_45_70_55, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "Marrying in Qatar > Resident of anywhere in the world > Partner is of any nationality in the world > Partner is opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('qatar', read_fixture_file('worldwide/qatar_organisations.json'))
      worldwide_api_has_organisations_for_location('japan', read_fixture_file('worldwide/japan_organisations.json'))
      add_response 'qatar'
      add_response 'other'
      add_response 'japan'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to outcome_os_consular_cni and show specific phraselist" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_local_resident, :gulf_states_os_consular_cni, :gulf_states_os_consular_cni_local_resident_partner_not_irish, :affirmation_os_all_what_you_need_to_do, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :affirmation_os_translation_in_local_language, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :affirmation_os_partner_not_british, :fee_table_45_70_55, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "ceremony in Lithuania, partner same sex, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('lithuania', read_fixture_file('worldwide/lithuania_organisations.json'))
      add_response 'lithuania'
      add_response 'other'
      add_response 'lithuania'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to outcome_ss_marriage" do
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage, :contact_embassy_or_consulate, :embassies_data, :documents_needed_ss_british, :what_to_do_ss_marriage, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage, :provide_two_witnesses_ss_marriage, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  context "ceremony in Lithuania, partner same sex, partner not british" do
    setup do
      worldwide_api_has_organisations_for_location('lithuania', read_fixture_file('worldwide/lithuania_organisations.json'))
      add_response 'lithuania'
      add_response 'other'
      add_response 'lithuania'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to outcome 'no same sex marriage allowed' because partner is not british" do
      assert_current_node :outcome_cp_all_other_countries
    end
  end
  context "test Belarus' address box" do
    setup do
      worldwide_api_has_organisations_for_location('belarus', read_fixture_file('worldwide/belarus_organisations.json'))
      worldwide_api_has_organisations_for_location('armenia', read_fixture_file('worldwide/armenia_organisations.json'))
      add_response 'belarus'
      add_response 'other'
      add_response 'armenia'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to outcome_ss_marriage and show correct address box" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :consular_cni_os_foreign_resident_ceremony_country_not_germany, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :consular_cni_os_foreign_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
      assert_match /37, Karl Marx Street/, outcome_body
    end
  end

  context "test morocco specific phraselists, living in the UK" do
    setup do
      worldwide_api_has_organisations_for_location('morocco', read_fixture_file('worldwide/morocco_organisations.json'))
      add_response 'morocco'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_uk_resident_ceremony_in_morocco, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :affirmation_os_translation_in_local_language, :documents_for_divorced_or_widowed, :morocco_affidavit_length, :partner_equivalent_document, :fee_table_affirmation_55, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "test morocco specific phraselists, living in Armenia" do
    setup do
      worldwide_api_has_organisations_for_location('morocco', read_fixture_file('worldwide/morocco_organisations.json'))
      worldwide_api_has_organisations_for_location('armenia', read_fixture_file('worldwide/armenia_organisations.json'))
      add_response 'morocco'
      add_response 'other'
      add_response 'armenia'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_other_resident_ceremony_in_morocco, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :affirmation_os_translation_in_local_language, :documents_for_divorced_or_widowed, :morocco_affidavit_length, :partner_equivalent_document, :fee_table_affirmation_55, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "Marriage in Mexico, living in Germany, partner British, opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('mexico', read_fixture_file('worldwide/mexico_organisations.json'))
      worldwide_api_has_organisations_for_location('germany', read_fixture_file('worldwide/germany_organisations.json'))
      add_response 'mexico'
      add_response 'other'
      add_response 'germany'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "show same outcome of Albania" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :consular_cni_os_foreign_resident_3_days, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :consular_cni_os_foreign_resident_ceremony_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "Marriage in Albania, living in Germany, partner British, opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('albania', read_fixture_file('worldwide/albania_organisations.json'))
      worldwide_api_has_organisations_for_location('germany', read_fixture_file('worldwide/germany_organisations.json'))
      add_response 'albania'
      add_response 'other'
      add_response 'germany'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "show Albania outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :consular_cni_os_foreign_resident_ceremony_not_germany_italy, :consular_cni_os_foreign_resident_3_days, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_not_germany_or_spain, :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany, :consular_cni_os_foreign_resident_ceremony_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_fees_not_italy_not_uk, :consular_cni_os_fees_foreign_commonwealth_roi_resident, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "Marriage in Mexico, living in the UK, partner British, opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('mexico', read_fixture_file('worldwide/mexico_organisations.json'))
      add_response 'mexico'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "show the same content of Albania" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :cni_at_local_register_office, :consular_cni_os_uk_resident_legalisation, :consular_cni_os_uk_resident_not_italy_or_portugal]
      assert_phrase_list :consular_cni_os_remainder, [:partner_will_need_a_cni, :consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "Marriage in Albania, living in the UK, partner British, opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('albania', read_fixture_file('worldwide/albania_organisations.json'))
      add_response 'albania'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "show Albania outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :italy_os_consular_cni_ceremony_not_italy_or_spain, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ceremony_not_spain_or_italy, :cni_at_local_register_office, :consular_cni_os_uk_resident_legalisation, :consular_cni_os_uk_resident_not_italy_or_portugal]
      assert_phrase_list :consular_cni_os_remainder, [:partner_will_need_a_cni, :consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british, :consular_cni_os_all_names_but_germany, :consular_cni_os_fees_not_italy_not_uk, :list_of_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
end
