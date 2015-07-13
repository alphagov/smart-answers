require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'

require 'smart_answer_flows/marriage-abroad'

class MarriageAbroadTest < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide

  def self.translations
    @translations ||= YAML.load_file("lib/smart_answer_flows/locales/en/marriage-abroad.yml")
  end

  OS_COUNTRIES_WITH_APPOINTMENTS = translations["en-GB"]["flow"]["marriage-abroad"]["phrases"]["appointment_links"]["opposite_sex"].keys
  SS_COUNTRIES_WITH_APPOINTMENTS = translations["en-GB"]["flow"]["marriage-abroad"]["phrases"]["appointment_links"]["same_sex"].keys

  setup do
    @location_slugs = (OS_COUNTRIES_WITH_APPOINTMENTS + SS_COUNTRIES_WITH_APPOINTMENTS + %w(albania american-samoa anguilla argentina armenia aruba australia austria azerbaijan bahamas belarus belgium bonaire-st-eustatius-saba brazil british-indian-ocean-territory burma burundi cambodia canada china costa-rica cote-d-ivoire croatia colombia cyprus czech-republic denmark ecuador egypt estonia finland france germany greece hong-kong indonesia iran ireland italy japan jordan kazakhstan kosovo laos latvia lebanon lithuania macedonia malta mayotte mexico monaco morocco netherlands nicaragua north-korea oman guatemala paraguay peru philippines poland portugal qatar russia rwanda saint-barthelemy san-marino saudi-arabia serbia seychelles slovakia south-africa st-maarten st-martin south-korea spain sweden switzerland thailand turkey turkmenistan united-arab-emirates usa uzbekistan vietnam wallis-and-futuna yemen zimbabwe)).uniq
    worldwide_api_has_locations(@location_slugs)
    setup_for_testing_flow SmartAnswer::MarriageAbroadFlow
  end

  should "which country you want the ceremony to take place in" do
    assert_current_node :country_of_ceremony?
  end

  context "newly added country that has no logic to handle opposite sex marriages" do
    setup do
      worldwide_api_has_locations(['narnia'])
      worldwide_api_has_no_organisations_for_location('narnia')
      add_response 'ceremony_country'
      add_response 'partner_local'
      assert_raises(SmartAnswer::Question::Base::NextNodeUndefined) do
        add_response 'opposite_sex'
      end
    end
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
      end
    end
    context "partner is same sex" do
      setup do
        add_response 'same_sex'
      end
      should "give outcome ireland ss" do
        assert_current_node :outcome_ireland
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

      should "go to partner nationality question" do
        assert_current_node :what_is_your_partners_nationality?
        assert_state_variable :ceremony_country, 'bahamas'
        assert_state_variable :ceremony_country_name, 'Bahamas'
        assert_state_variable :country_name_lowercase_prefix, "the Bahamas"
        assert_state_variable :resident_of, 'uk'
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
            assert_phrase_list :commonwealth_os_outcome, [:contact_high_comission_of_ceremony_country_in_uk, :get_legal_and_travel_advice, :cant_issue_cni_for_commonwealth]
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

    context "resident in the ceremony country" do
      setup do
        add_response 'ceremony_country'
      end

      should "go to partner's nationality question" do
        assert_current_node :what_is_your_partners_nationality?
        assert_state_variable :resident_of, 'ceremony_country'
        assert_state_variable :ceremony_country, 'bahamas'
        assert_state_variable :ceremony_country_name, 'Bahamas'
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
            assert_phrase_list :commonwealth_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :cant_issue_cni_for_commonwealth, :partner_naturalisation_in_uk]
            expected_location = WorldLocation.find('bahamas')
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

    context "resident in 3rd country" do
      setup do
        add_response 'third_country'
      end

      should "go to partner's nationality question" do
        assert_current_node :what_is_your_partners_nationality?
        assert_state_variable :resident_of, 'third_country'
        assert_state_variable :ceremony_country, 'bahamas'
        assert_state_variable :ceremony_country_name, 'Bahamas'
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
            assert_phrase_list :commonwealth_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :cant_issue_cni_for_commonwealth, :partner_naturalisation_in_uk]
            expected_location = WorldLocation.find('bahamas')
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

  context "local resident but ceremony not in zimbabwe" do
    setup do
      worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
      add_response 'australia'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :cant_issue_cni_for_commonwealth]
      expected_location = WorldLocation.find('australia')
      assert_state_variable :location, expected_location
    end
  end

  context "uk resident but ceremony not in zimbabwe" do
    setup do
      worldwide_api_has_organisations_for_location('bahamas', read_fixture_file('worldwide/bahamas_organisations.json'))
      add_response 'bahamas'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:contact_high_comission_of_ceremony_country_in_uk, :get_legal_and_travel_advice, :cant_issue_cni_for_commonwealth]
      expected_location = WorldLocation.find('bahamas')
      assert_state_variable :location, expected_location
    end
  end

  context "other resident but ceremony not in zimbabwe" do
    setup do
      worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
      add_response 'australia'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :cant_issue_cni_for_commonwealth]
    end
  end

  context "ceremony in zimbabwe" do
    setup do
      worldwide_api_has_organisations_for_location('zimbabwe', read_fixture_file('worldwide/zimbabwe_organisations.json'))
      add_response 'zimbabwe'
    end
    should "go to commonwealth os outcome for uk resident " do
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:contact_zimbabwean_embassy_in_uk, :get_legal_and_travel_advice, :cant_issue_cni_for_zimbabwe]
    end
    should "go to commonwealth os outcome for non-uk resident" do
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :cant_issue_cni_for_zimbabwe, :partner_naturalisation_in_uk]
    end
  end

  context "uk resident ceremony in south-africa" do
    setup do
      worldwide_api_has_organisations_for_location('south-africa', read_fixture_file('worldwide/south-africa_organisations.json'))
      add_response 'south-africa'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:contact_high_comission_of_ceremony_country_in_uk, :get_legal_and_travel_advice, :cant_issue_cni_for_commonwealth, :commonwealth_os_marriage_subtleties_in_south_africa, :partner_naturalisation_in_uk]
    end
  end

  context "resident in cyprus, ceremony in cyprus" do
    setup do
      worldwide_api_has_organisations_for_location('cyprus', read_fixture_file('worldwide/cyprus_organisations.json'))
      add_response 'cyprus'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :cant_issue_cni_for_commonwealth, :commonwealth_os_marriage_subtleties_in_cyprus, :partner_naturalisation_in_uk]
    end
  end

  context "resident in england, ceremony in cyprus, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('cyprus', read_fixture_file('worldwide/cyprus_organisations.json'))
      add_response 'cyprus'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to consular cp outcome" do
      assert_current_node :outcome_cp_consular
      assert_state_variable :institution_name, "High Commission"
      assert_phrase_list :consular_cp_outcome, [:cp_may_be_possible, :contact_to_make_appointment, :embassies_data, :documents_needed_7_days_residency, :documents_for_both_partners_cp, :additional_non_british_partner_documents_cp, :consular_cp_what_you_need_to_do, :partner_naturalisation_in_uk, :consular_cp_standard_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "uk resident ceremony in british indian ocean territory" do
    setup do
      worldwide_api_has_organisations_for_location('british-indian-ocean-territory', read_fixture_file('worldwide/british-indian-ocean-territory_organisations.json'))
      add_response 'british-indian-ocean-territory'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to bot os outcome" do
      assert_current_node :outcome_os_bot
      assert_phrase_list :bot_outcome, [:bot_os_ceremony_biot, :embassies_data]
    end
  end

  context "resident in anguilla, ceremony in anguilla" do
    setup do
      worldwide_api_has_organisations_for_location('anguilla', read_fixture_file('worldwide/anguilla_organisations.json'))
      add_response 'anguilla'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to bos os outcome" do
      assert_current_node :outcome_os_bot
      assert_phrase_list :bot_outcome, [:bot_os_ceremony_non_biot, :embassies_data, :get_legal_advice, :partner_naturalisation_in_uk]
    end
  end

  context "uk resident, ceremony in estonia, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('estonia', read_fixture_file('worldwide/estonia_organisations.json'))
      add_response 'estonia'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :cni_at_local_register_office, :cni_issued_locally_validity, :legisation_and_translation_intro_uk, :legalise_translate_and_check_with_authorities]
      assert_phrase_list :consular_cni_os_remainder, [:same_cni_process_and_fees_for_partner, :names_on_documents_must_match, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "resident in estonia, ceremony in estonia" do
    setup do
      worldwide_api_has_organisations_for_location('estonia', read_fixture_file('worldwide/estonia_organisations.json'))
      add_response 'estonia'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :consular_cni_os_giving_notice_in_ceremony_country, :living_in_ceremony_country_3_days, :cni_exception_for_permanent_residents_estonia, "appointment_links.opposite_sex.estonia", :required_supporting_documents_notary_public, :consular_cni_os_not_uk_resident_ceremony_not_germany, :evidence_if_divorced_outside_uk, :download_and_fill_notice_and_affidavit_but_not_sign, :consular_cni_os_foreign_resident_ceremony_notary_public]
      assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match, :check_if_cni_needs_to_be_legalised, :no_need_to_stay_after_posting_notice, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in Estonia, lives in 3rd country" do
    setup do
      worldwide_api_has_organisations_for_location('estonia', read_fixture_file('worldwide/estonia_organisations.json'))
      add_response 'estonia'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to outcome_consular_cni_os_residing_in_third_country" do
      assert_current_node :outcome_consular_cni_os_residing_in_third_country
      assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :standard_ways_to_get_cni_in_third_country]
      assert_state_variable :ceremony_country_residence_outcome_path, "/marriage-abroad/y/estonia/ceremony_country/partner_british/opposite_sex"
      assert_state_variable :uk_residence_outcome_path, "/marriage-abroad/y/estonia/uk/partner_british/opposite_sex"
    end
  end

  context "local resident, ceremony in jordan, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('jordan', read_fixture_file('worldwide/jordan_organisations.json'))
      add_response 'jordan'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_local_authorities_in_country_marriage, :gulf_states_os_consular_cni, :gulf_states_os_consular_cni_local_resident, :get_legal_advice, :what_you_need_to_do, :consular_cni_os_foreign_resident_21_days_jordan, :consular_cni_os_giving_notice_in_ceremony_country, :embassies_data, :required_supporting_documents_incl_birth_cert, :documents_must_be_originals_when_in_sharia_court, :consular_cni_os_not_uk_resident_ceremony_jordan, :evidence_if_divorced_outside_uk, :download_and_fill_notice_and_affidavit_but_not_sign, :display_notice_of_marriage_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:same_cni_process_and_fees_for_partner, :names_on_documents_must_match, :check_if_cni_needs_to_be_legalised, :no_need_to_stay_after_posting_notice, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  # variants for italy
  context "ceremony in italy, resident in england, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('italy', read_fixture_file('worldwide/italy_organisations.json'))
      add_response 'italy'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:italy_os_consular_cni_ceremony_italy, :what_you_need_to_do, :get_cni_from_uk, :partner_cni_requirements_the_same, :cni_at_local_register_office, :cni_issued_locally_validity, :getting_statutory_declaration_for_italy_partner_british, :bilingual_statutory_declaration_download_for_italy, :legalising_italian_statutory_declaration]
      assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match]
    end
  end

  context "ceremony in italy, resident in italy, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('italy', read_fixture_file('worldwide/italy_organisations.json'))
      add_response 'italy'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:italy_os_consular_cni_ceremony_italy, :what_you_need_to_do, :nulla_osta_requirement, "appointment_links.opposite_sex.italy", :consular_cni_os_local_resident_italy, :italy_consular_cni_os_partner_not_british, :consular_cni_os_not_uk_resident_ceremony_not_germany, :consular_cni_os_other_resident_ceremony_italy, :wait_300_days_before_remarrying, :download_and_fill_notice_and_affidavit_but_not_sign, :issuing_cni_in_italy]
      assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match, :no_need_to_stay_after_posting_notice, :partner_naturalisation_in_uk, :list_of_consular_fees_italy, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in italy, lives in 3rd country, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('italy', read_fixture_file('worldwide/italy_organisations.json'))
      add_response 'italy'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to outcome_consular_cni_os_residing_in_third_country" do
      assert_current_node :outcome_consular_cni_os_residing_in_third_country
      assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :standard_ways_to_get_cni_in_third_country]
      assert_state_variable :ceremony_country_residence_outcome_path, "/marriage-abroad/y/italy/ceremony_country/partner_other/opposite_sex"
      assert_state_variable :uk_residence_outcome_path, "/marriage-abroad/y/italy/uk/partner_other/opposite_sex"
    end
  end

  #variants for germany
  context "ceremony in germany, resident in germany, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('germany', read_fixture_file('worldwide/germany_organisations.json'))
      add_response 'germany'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do, :consular_cni_requirements_in_germany]
      assert_phrase_list :consular_cni_os_remainder, [:no_need_to_stay_after_posting_notice, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in germany, partner german, same sex" do
    setup do
      worldwide_api_has_organisations_for_location('germany', read_fixture_file('worldwide/germany_organisations.json'))
      add_response 'germany'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to cp or equivalent outcome" do
      assert_current_node :outcome_cp_or_equivalent
      assert_phrase_list :cp_or_equivalent_cp_outcome, [:synonyms_of_cp_in_germany, :contact_local_authorities_in_country_cp, :cp_or_equivalent_cp_what_you_need_to_do, :embassies_data, :partner_naturalisation_in_uk, :standard_cni_fee_for_cp, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in germany, partner not german, same sex" do
    setup do
      worldwide_api_has_organisations_for_location('germany', read_fixture_file('worldwide/germany_organisations.json'))
      add_response 'germany'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to ss marriage" do
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage, :contact_british_embassy_or_consulate_berlin, :embassies_data, :documents_needed_21_days_residency, :documents_needed_ss_not_british_germany_same_sex, :what_to_do_ss_marriage, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage, :provide_two_witnesses_ss_marriage, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque, :convert_cc_to_ss_marriage]
    end
  end
  #variants for uk residency (again)
  context "ceremony in azerbaijan, resident in UK, partner non-irish" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      add_response 'azerbaijan'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :cni_at_local_register_office, :cni_issued_locally_validity, :legisation_and_translation_intro_uk, :legalise_translate_and_check_with_authorities]
      assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in azerbaijan, resident in the UK, opposite sex non-local partner" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      add_response 'azerbaijan'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :cni_at_local_register_office, :cni_issued_locally_validity, :legisation_and_translation_intro_uk, :legalise_translate_and_check_with_authorities]
      assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #variant for uk resident, ceremony not in italy
  context "ceremony in guatemala, resident in wales, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('guatemala', read_fixture_file('worldwide/guatemala_organisations.json'))
      add_response 'guatemala'
      add_response 'uk'
      add_response 'partner_other'
    end
    should "go to consular cni os outcome for opposite sex marriage" do
      add_response 'opposite_sex'
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :cni_at_local_register_office, :cni_issued_locally_validity, :legisation_and_translation_intro_uk, :legalise_translate_and_check_with_authorities]
      assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end

    should "go to outcome_cp_consular outcome for same sex marriage" do
      add_response 'same_sex'
      assert_current_node :outcome_cp_consular
      assert_state_variable :institution_name, "British embassy or consulate"
    end
  end
  #variant for local resident, ceremony not in italy or germany
  context "ceremony in azerbaijan, resident in azerbaijan, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      add_response 'azerbaijan'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :consular_cni_os_giving_notice_in_ceremony_country, :living_in_ceremony_country_3_days, "appointment_links.opposite_sex.azerbaijan", :required_supporting_documents_notary_public, :consular_cni_os_not_uk_resident_ceremony_not_germany, :evidence_if_divorced_outside_uk, :download_and_fill_notice_and_affidavit_but_not_sign, :consular_cni_os_foreign_resident_ceremony_notary_public]
      assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match, :check_if_cni_needs_to_be_legalised, :no_need_to_stay_after_posting_notice, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in denmark, lives in 3rd country, partner opposite sex british" do
    setup do
      worldwide_api_has_organisations_for_location('denmark', read_fixture_file('worldwide/denmark_organisations.json'))
      add_response 'denmark'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to outcome_consular_cni_os_residing_in_third_country" do
      assert_current_node :outcome_consular_cni_os_residing_in_third_country
      assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :standard_ways_to_get_cni_in_third_country]
      assert_state_variable :ceremony_country_residence_outcome_path, "/marriage-abroad/y/denmark/ceremony_country/partner_british/opposite_sex"
      assert_state_variable :uk_residence_outcome_path, "/marriage-abroad/y/denmark/uk/partner_british/opposite_sex"
    end
  end

  #variant for local residents (not germany or spain)
  context "ceremony in denmark, resident in denmark, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('denmark', read_fixture_file('worldwide/denmark_organisations.json'))
      add_response 'denmark'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :consular_cni_os_denmark, :consular_cni_os_giving_notice_in_ceremony_country, :living_in_ceremony_country_3_days, "appointment_links.opposite_sex.denmark", :required_supporting_documents, :consular_cni_os_not_uk_resident_ceremony_not_germany, :evidence_if_divorced_outside_uk, :download_and_fill_notice_and_affidavit_but_not_sign, :display_notice_of_marriage_7_days]
      assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match, :check_if_cni_needs_to_be_legalised, :no_need_to_stay_after_posting_notice, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "Spain" do
    setup do
      worldwide_api_has_organisations_for_location('spain', read_fixture_file('worldwide/spain_organisations.json'))
      add_response 'spain'
    end

    context "resident in uk, partner british, opposite sex" do
      setup do
        add_response 'uk'
        add_response 'partner_british'
        add_response 'opposite_sex'
      end
      should "go to outcome_spain with UK/OS specific phrases" do
        assert_current_node :outcome_spain
        assert_phrase_list :body, [:civil_weddings_in_spain, :get_legal_and_travel_advice, :legal_restrictions_for_non_residents_spain, :what_you_need_to_do, :cni_maritial_status_certificate_spain, :what_you_need_to_do_spain, :get_cni_in_uk_for_spain_title, :cni_at_local_register_office, :get_cni_in_uk_for_spain, :get_maritial_status_certificate_spain, :other_requirements_in_spain_intro, :other_requirements_in_spain, :names_on_documents_must_match, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_visas_or_mastercard]
      end
    end

    context "resident in spain, partner local" do
      setup do
        add_response 'ceremony_country'
        add_response 'partner_local'
        add_response 'opposite_sex'
      end
      should "go to outcome_spain with ceremony country OS specific phrases" do
        assert_current_node :outcome_spain
        assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :civil_weddings_in_spain, :get_legal_advice, :what_you_need_to_do, :cni_maritial_status_certificate_spain, :what_you_need_to_do_spain, :get_cni_in_spain, :get_maritial_status_certificate_spain, :other_requirements_in_spain_for_residents_intro, :other_requirements_in_spain, :names_on_documents_must_match, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_visas_or_mastercard]
      end
    end

    context "lives elsewhere, partner opposite sex other" do
      setup do
        add_response 'third_country'
        add_response 'partner_other'
        add_response 'opposite_sex'
      end

      should "go to outcome_spain with third country OS specific phrases" do
        assert_current_node :outcome_spain
        assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :legal_restrictions_for_non_residents_spain, :what_you_need_to_do, :cni_maritial_status_certificate_spain, :what_you_need_to_do_spain_third_country]
        assert_state_variable :ceremony_country_residence_outcome_path, "/marriage-abroad/y/spain/ceremony_country/partner_other/opposite_sex"
        assert_state_variable :uk_residence_outcome_path, "/marriage-abroad/y/spain/uk/partner_other/opposite_sex"
      end
    end

    context "resident in england, partner british, same sex" do
      setup do
        add_response 'uk'
        add_response 'partner_british'
        add_response 'same_sex'
      end

      should "go to outcome_spain with UK/SS specific phrases" do
        assert_current_node :outcome_spain
        assert_phrase_list :body, [:ss_process_in_spain, :get_legal_and_travel_advice, :legal_restrictions_for_non_residents_spain, :what_you_need_to_do, :cni_maritial_status_certificate_spain, :what_you_need_to_do_spain, :get_cni_in_uk_for_spain_title, :cni_at_local_register_office, :get_cni_in_uk_for_spain, :get_maritial_status_certificate_spain, :other_requirements_in_spain_intro, :other_requirements_in_spain, :names_on_documents_must_match, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_visas_or_mastercard]
      end
    end

    context "lives elsewhere, partner same sex other" do
      setup do
        add_response 'third_country'
        add_response 'partner_other'
        add_response 'same_sex'
      end

      should "go to outcome_spain with third country SS specific phrases" do
        assert_current_node :outcome_spain
        assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :ss_process_in_spain, :get_legal_and_travel_advice, :legal_restrictions_for_non_residents_spain, :what_you_need_to_do, :cni_maritial_status_certificate_spain, :what_you_need_to_do_spain_third_country]
        assert_state_variable :ceremony_country_residence_outcome_path, "/marriage-abroad/y/spain/ceremony_country/partner_other/same_sex"
        assert_state_variable :uk_residence_outcome_path, "/marriage-abroad/y/spain/uk/partner_other/same_sex"
      end
    end
  end

  context "ceremony in poland, lives elsewhere, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'poland'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :consular_cni_os_giving_notice_in_ceremony_country, :living_in_ceremony_country_3_days, "appointment_links.opposite_sex.poland", :required_supporting_documents_notary_public, :consular_cni_os_not_uk_resident_ceremony_not_germany, :evidence_if_divorced_outside_uk, :download_and_fill_notice_and_affidavit_but_not_sign, :consular_cni_os_foreign_resident_ceremony_notary_public]
      assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match, :check_if_cni_needs_to_be_legalised, :no_need_to_stay_after_posting_notice, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in azerbaijan, resident in azerbaijan, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      add_response 'azerbaijan'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :consular_cni_os_giving_notice_in_ceremony_country, :living_in_ceremony_country_3_days, "appointment_links.opposite_sex.azerbaijan", :required_supporting_documents_notary_public, :consular_cni_os_not_uk_resident_ceremony_not_germany, :evidence_if_divorced_outside_uk, :download_and_fill_notice_and_affidavit_but_not_sign, :consular_cni_os_foreign_resident_ceremony_notary_public]
      assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match, :check_if_cni_needs_to_be_legalised, :no_need_to_stay_after_posting_notice, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end
  #variant for foreign resident, ceremony not in italy
  context "ceremony in azerbaijan, lives elsewhere, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      add_response 'azerbaijan'
      add_response 'third_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to outcome_consular_cni_os_residing_in_third_country" do
      assert_current_node :outcome_consular_cni_os_residing_in_third_country
      assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :standard_ways_to_get_cni_in_third_country]
      assert_state_variable :ceremony_country_residence_outcome_path, "/marriage-abroad/y/azerbaijan/ceremony_country/partner_local/opposite_sex"
      assert_state_variable :uk_residence_outcome_path, "/marriage-abroad/y/azerbaijan/uk/partner_local/opposite_sex"
    end
  end

  context "ceremony in poland, lives in 3rd country, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('poland', read_fixture_file('worldwide/poland_organisations.json'))
      add_response 'poland'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to outcome_consular_cni_os_residing_in_third_country" do
      assert_current_node :outcome_consular_cni_os_residing_in_third_country
      assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :standard_ways_to_get_cni_in_third_country]
      assert_state_variable :ceremony_country_residence_outcome_path, "/marriage-abroad/y/poland/ceremony_country/partner_british/opposite_sex"
      assert_state_variable :uk_residence_outcome_path, "/marriage-abroad/y/poland/uk/partner_british/opposite_sex"
    end
  end

  context "ceremony in belgium, lives in 3rd country, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('belgium', read_fixture_file('worldwide/belgium_organisations.json'))
      add_response 'belgium'
    end

    should "go to outcome_os_affirmation for opposite sex marriages" do
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do_affirmation, :appointment_for_affidavit, "appointment_links.opposite_sex.belgium", :complete_affirmation_or_affidavit_forms, :download_and_fill_but_not_sign, :download_affidavit_and_affirmation_belgium, :partner_needs_affirmation, :required_supporting_documents, :documents_guidance_belgium, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :callout_partner_equivalent_document, :names_on_documents_must_match, :partner_naturalisation_in_uk, :fee_table_affirmation_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end

    should "go to outcome_ss_affirmation for same sex marriages for residents in a third country" do
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'same_sex'
      assert_current_node :outcome_ss_affirmation
      assert_phrase_list :body, [:synonyms_of_cp_in_belgium, :contact_local_authorities_in_country_cp, :get_legal_and_travel_advice, :what_you_need_to_do_affirmation, :appointment_for_affidavit, "appointment_links.same_sex.belgium", :complete_affirmation_or_affidavit_forms, :download_and_fill_but_not_sign, :download_affidavit_and_affirmation_belgium, :partner_needs_affirmation, :required_supporting_documents, :documents_guidance_belgium, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :divorce_proof_cp, :names_on_documents_must_match, :partner_probably_needs_affirmation, :fee_table_affirmation_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end

    should "go to outcome_ss_affirmation for same sex marriages for residents in Belgium" do
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'same_sex'
      assert_current_node :outcome_ss_affirmation
      assert_phrase_list :body, [:synonyms_of_cp_in_belgium, :contact_local_authorities_in_country_cp, :get_legal_advice, :what_you_need_to_do_affirmation, :appointment_for_affidavit, "appointment_links.same_sex.belgium", :complete_affirmation_or_affidavit_forms, :download_and_fill_but_not_sign, :download_affidavit_and_affirmation_belgium, :partner_needs_affirmation, :required_supporting_documents, :documents_guidance_belgium, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :divorce_proof_cp, :names_on_documents_must_match, :partner_probably_needs_affirmation, :fee_table_affirmation_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in armenia, resident in the UK, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('armenia', read_fixture_file('worldwide/armenia_organisations.json'))
      add_response 'armenia'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :cni_at_local_register_office, :cni_issued_locally_validity, :legisation_and_translation_intro_uk, :legalise_translate_and_check_with_authorities]
      assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_in_local_currency_ceremony_country_name]
    end
  end

  #France or french overseas territories outcome
  context "ceremony in fot" do
    setup do
      worldwide_api_has_organisations_for_location('mayotte', read_fixture_file('worldwide/mayotte_organisations.json'))
      add_response 'mayotte'
    end
    should "go to marriage in france or fot outcome" do
      assert_current_node :outcome_os_france_or_fot
      assert_phrase_list :france_or_fot_os_outcome, [:fot_os_rules_similar_to_france]
    end
  end

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
  context "ceremony in thailand, resident in the UK, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('thailand', read_fixture_file('worldwide/thailand_organisations.json'))
      add_response 'thailand'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do_affirmation, :appointment_for_affidavit, "appointment_links.opposite_sex.thailand", :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :callout_partner_equivalent_document, :partner_naturalisation_in_uk, :fee_table_affidavit_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in colombia, partner colombian national, opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('colombia', read_fixture_file('worldwide/colombia_organisations.json'))
      add_response 'colombia'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_colombia
      assert_phrase_list :colombia_os_phraselist, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do_affirmation, :make_an_appointment_bring_passport_and_pay_55_colombia, "appointment_links.opposite_sex.colombia", :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :documents_for_divorced_or_widowed_china_colombia, :change_of_name_evidence, :names_on_documents_must_match, :partner_naturalisation_in_uk]
    end
  end

  context "ceremony in Egypt, resident in egypt, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('egypt', read_fixture_file('worldwide/egypt_organisations.json'))
      add_response 'egypt'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do, :make_an_appointment, "appointment_links.opposite_sex.egypt", :required_supporting_documents_egypt, :docs_decree_and_death_certificate, :change_of_name_evidence, :partner_declaration, :fee_table_55_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in lebanon, lives elsewhere, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('lebanon', read_fixture_file('worldwide/lebanon_organisations.json'))
      add_response 'lebanon'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do_affirmation, :appointment_for_affidavit, "appointment_links.opposite_sex.lebanon", :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :callout_partner_equivalent_document, :partner_naturalisation_in_uk, :affirmation_os_all_fees_45_70, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in UAE, resident in UAE, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('united-arab-emirates', read_fixture_file('worldwide/united-arab-emirates_organisations.json'))
      add_response 'united-arab-emirates'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :affirmation_os_uae, :what_you_need_to_do_affirmation_21_days, :appointment_for_affidavit, :embassies_data, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :callout_partner_equivalent_document, :partner_naturalisation_in_uk, :affirmation_os_all_fees_45_70, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in Oman, resident in Oman, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('oman', read_fixture_file('worldwide/oman_organisations.json'))
      add_response 'oman'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_local_authorities_in_country_marriage, :gulf_states_os_consular_cni, :gulf_states_os_consular_cni_local_resident, :get_legal_advice, :what_you_need_to_do, :consular_cni_os_ceremony_21_day_requirement, :you_may_be_asked_for_cni, :consular_cni_os_giving_notice_in_ceremony_country, :embassies_data, :required_supporting_documents_incl_birth_cert, :consular_cni_os_not_uk_resident_ceremony_not_germany, :evidence_if_divorced_outside_uk, :download_and_fill_notice_and_affidavit_but_not_sign, :display_notice_of_marriage_7_days]
    end
  end

  context "ceremony in Turkey, resident in the UK, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('turkey', read_fixture_file('worldwide/turkey_organisations.json'))
      add_response 'turkey'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :appointment_for_affidavit_notary, :complete_affidavit, :download_affidavit, :affirmation_os_legalised, :documents_for_divorced_or_widowed, :callout_partner_equivalent_document, :check_legalised_document, :fee_table_affidavit_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in Turkey, resident in Turkey, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('turkey', read_fixture_file('worldwide/turkey_organisations.json'))
      add_response 'turkey'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do, :appointment_for_affidavit, "appointment_links.opposite_sex.turkey", :complete_affidavit, :download_affidavit, :affirmation_os_legalised_in_turkey, :documents_for_divorced_or_widowed, :callout_partner_equivalent_document, :check_legalised_document, :fee_table_affidavit_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in Ecuador, resident in Ecuador, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('ecuador', read_fixture_file('worldwide/ecuador_organisations.json'))
      add_response 'ecuador'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_local_authorities_in_country_marriage, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :embassies_data, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :documents_for_divorced_or_widowed_ecuador, :callout_partner_equivalent_document, :names_on_documents_must_match, :partner_naturalisation_in_uk, :fee_table_affirmation_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in Cambodia" do
    setup do
      worldwide_api_has_organisations_for_location('cambodia', read_fixture_file('worldwide/cambodia_organisations.json'))
      add_response 'cambodia'
    end

    context "resident in Cambodia, partner other" do
      setup do
        add_response 'ceremony_country'
        add_response 'partner_other'
        add_response 'opposite_sex'
      end
      should "go to os affirmation outcome" do
        assert_current_node :outcome_os_affirmation
        assert_phrase_list :affirmation_os_outcome, [:contact_local_authorities_in_country_marriage, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :embassies_data, :fee_and_required_supporting_documents_for_appointment, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :documents_for_divorced_or_widowed_cambodia, :change_of_name_evidence, :callout_partner_equivalent_document, :names_on_documents_must_match, :partner_naturalisation_in_uk, :fee_table_affirmation_55, :pay_by_cash_or_us_dollars_only]
      end
    end

    context "lives elsewhere, same sex marriage, non british partner" do
      setup do
        add_response 'third_country'
        add_response 'partner_other'
        add_response 'same_sex'
      end
      should "go to outcome_ss_marriage" do
        assert_current_node :outcome_ss_marriage
        assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage_and_partnership, :contact_embassy_or_consulate, :embassies_data, :documents_needed_21_days_residency, :documents_needed_ss_not_british, :what_to_do_ss_marriage_and_partnership, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage_and_partnership, :provide_two_witnesses_ss_marriage_and_partnership, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_and_partnership, :pay_by_cash_or_us_dollars_only]
      end
    end
  end

  #tests for no cni or consular services
  context "ceremony in aruba, resident in the UK, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('aruba', read_fixture_file('worldwide/aruba_organisations.json'))
      add_response 'aruba'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_dutch_embassy_for_dutch_caribbean_islands, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :cni_at_local_register_office, :cni_issued_locally_validity, :legisation_and_translation_intro_uk, :legalise_translate_and_check_with_authorities]
      assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter]
    end
  end

  context "ceremony in aruba, resident in aruba, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('aruba', read_fixture_file('worldwide/aruba_organisations.json'))
      add_response 'aruba'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:country_is_dutch_caribbean_island, :contact_local_authorities_in_country_marriage, :get_legal_advice, :cni_os_consular_facilities_unavailable]
    end
  end

  context "ceremony in aruba, lives elsewhere, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('aruba', read_fixture_file('worldwide/aruba_organisations.json'))
      add_response 'aruba'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:country_is_dutch_caribbean_island, :contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :cni_os_consular_facilities_unavailable, :partner_naturalisation_in_uk]
    end
  end

  context "ceremony in cote-d-ivoire, uk resident, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('cote-d-ivoire', read_fixture_file('worldwide/cote-d-ivoire_organisations.json'))
      add_response 'cote-d-ivoire'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :cni_at_local_register_office, :cni_issued_locally_validity, :legisation_and_translation_intro_uk, :legalise_translate_and_check_with_authorities]
      assert_phrase_list :consular_cni_os_remainder, [:same_cni_process_and_fees_for_partner, :names_on_documents_must_match, :consular_cni_os_fees_incl_null_osta_oath_consular_letter]
      assert_state_variable :pay_by_cash_or_credit_card_no_cheque, nil
    end
  end

  context "ceremony in cote-d-ivoire, lives elsewhere, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('cote-d-ivoire', read_fixture_file('worldwide/cote-d-ivoire_organisations.json'))
      add_response 'cote-d-ivoire'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go os no cni outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :cni_os_consular_facilities_unavailable]
    end
  end

  context "ceremony in monaco, maps to France, marriage" do
    setup do
      worldwide_api_has_organisations_for_location('monaco', read_fixture_file('worldwide/monaco_organisations.json'))
      add_response 'monaco'
      add_response 'marriage'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_monaco
      assert_phrase_list :monaco_phraselist, [:monaco_marriage]
    end
  end

  context "ceremony in monaco, maps to France, pacs" do
    setup do
      worldwide_api_has_organisations_for_location('monaco', read_fixture_file('worldwide/monaco_organisations.json'))
      add_response 'monaco'
      add_response 'pacs'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_monaco
      assert_phrase_list :monaco_phraselist, [:monaco_pacs]
    end
  end

  context "user lives in 3rd country, ceremony in macedonia, partner os (any nationality)" do
    setup do
      worldwide_api_has_organisations_for_location('macedonia', read_fixture_file('worldwide/macedonia_organisations.json'))
      add_response 'macedonia'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to outcome_consular_cni_os_residing_in_third_country" do
      assert_current_node :outcome_consular_cni_os_residing_in_third_country
      assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :standard_ways_to_get_cni_in_third_country]
      assert_state_variable :ceremony_country_residence_outcome_path, "/marriage-abroad/y/macedonia/ceremony_country/partner_other/opposite_sex"
      assert_state_variable :uk_residence_outcome_path, "/marriage-abroad/y/macedonia/uk/partner_other/opposite_sex"
    end
  end

  context "user lives in macedonia, ceremony in macedonia" do
    setup do
      worldwide_api_has_organisations_for_location('macedonia', read_fixture_file('worldwide/macedonia_organisations.json'))
      add_response 'macedonia'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :living_in_ceremony_country_3_days, :consular_cni_os_foreign_resident_3_days_macedonia, :required_supporting_documents_notary_public, :consular_cni_os_not_uk_resident_ceremony_not_germany, :evidence_if_divorced_outside_uk, :download_and_fill_notice_and_affidavit_but_not_sign, :display_notice_of_marriage_7_days]
    end
  end

  context "ceremony in usa, lives elsewhere, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('usa', read_fixture_file('worldwide/usa_organisations.json'))
      add_response 'usa'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :cni_os_consular_facilities_unavailable, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque, :partner_naturalisation_in_uk]
    end
  end

  context "ceremony in argentina, lives elsewhere, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('argentina', read_fixture_file('worldwide/argentina_organisations.json'))
      add_response 'argentina'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :cni_os_consular_facilities_unavailable, :partner_naturalisation_in_uk]
    end
  end

  context "ceremony in burma, resident in the UK, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('burma', read_fixture_file('worldwide/burma_organisations.json'))
      add_response 'burma'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:embassy_in_burma_doesnt_register_marriages, :cant_marry_burmese_citizen]
    end
  end

  context "ceremony in burundi, resident in 3rd country, partner anywhere" do
    setup do
      worldwide_api_has_organisations_for_location('burundi', read_fixture_file('worldwide/burundi_organisations.json'))
      add_response 'burundi'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :cni_os_consular_facilities_unavailable, :partner_naturalisation_in_uk]
    end
  end

  context "ceremony in north korea, resident in the UK, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('north-korea', read_fixture_file('worldwide/north-korea_organisations.json'))
      add_response 'north-korea'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:marriage_in_north_korea_unlikely, :cant_marry_north_korean_citizen]
    end
  end

  context "ceremony in iran, resident in the UK, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('iran', read_fixture_file('worldwide/iran_organisations.json'))
      add_response 'iran'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:no_consular_services_contact_embassy]
    end
  end

  context "ceremony in yemen, resident in the UK, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('yemen', read_fixture_file('worldwide/yemen_organisations.json'))
      add_response 'yemen'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to outcome_os_other_countries" do # Consular services in Yemen are temporarily ceased. Normal outcome: consular cni os outcome
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:limited_consular_services_contact_embassy]
    end
  end

  context "ceremony in saudi arabia, resident in the UK, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('saudi-arabia', read_fixture_file('worldwide/saudi-arabia_organisations.json'))
      add_response 'saudi-arabia'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:saudi_arabia_requirements_for_foreigners, :embassies_data]
    end
  end

  context "ceremony in saudi arabia, resident in saudi arabia, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('saudi-arabia', read_fixture_file('worldwide/saudi-arabia_organisations.json'))
      add_response 'saudi-arabia'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:saudi_arabia_requirements_for_residents, :fees_table_and_payment_instructions_saudi_arabia]
    end
  end

  context "ceremony in saudi arabia, resident in saudi arabia, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('saudi-arabia', read_fixture_file('worldwide/saudi-arabia_organisations.json'))
      add_response 'saudi-arabia'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:saudi_arabia_requirements_for_residents, :partner_naturalisation_in_uk, :fees_table_and_payment_instructions_saudi_arabia]
    end
  end

  context "ceremony in russia, resident in russia, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('russia', read_fixture_file('worldwide/russia_organisations.json'))
      add_response 'russia'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to russia CNI outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :russia_os_local_resident, "appointment_links.opposite_sex.russia", :required_supporting_documents_notary_public, :consular_cni_os_not_uk_resident_ceremony_not_germany, :evidence_if_divorced_outside_uk, :download_and_fill_notice_and_affidavit_but_not_sign, :consular_cni_os_foreign_resident_ceremony_notary_public]
      assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match, :check_if_cni_needs_to_be_legalised, :no_need_to_stay_after_posting_notice, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_mastercard_or_visa]
    end
  end

  context "ceremony in denmark, resident in england, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('denmark', read_fixture_file('worldwide/denmark_organisations.json'))
      add_response 'denmark'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to cp or equivalent outcome" do
      assert_current_node :outcome_cp_or_equivalent
      assert_phrase_list :cp_or_equivalent_cp_outcome, [:synonyms_of_cp_in_denmark, :contact_embassy_of_ceremony_country_in_uk_cp, :also_check_travel_advice, :cp_or_equivalent_cp_what_you_need_to_do, :embassies_data, :partner_naturalisation_in_uk, :standard_cni_fee_for_cp, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in czech republic, lives elsewhere, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('czech-republic', read_fixture_file('worldwide/czech-republic_organisations.json'))
      add_response 'czech-republic'
      add_response 'third_country'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to cp or equivalent outcome" do
      assert_current_node :outcome_cp_or_equivalent
      assert_state_variable :country_name_lowercase_prefix, 'the Czech Republic'
      assert_phrase_list :cp_or_equivalent_cp_outcome, [:"synonyms_of_cp_in_czech-republic", :contact_local_authorities_in_country_cp, :also_check_travel_advice, :partner_naturalisation_in_uk]
      assert_state_variable :pay_by_cash_or_credit_card_no_cheque, nil
    end
  end

  context "ceremony in sweden, resident in sweden, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('sweden', read_fixture_file('worldwide/sweden_organisations.json'))
      add_response 'sweden'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to cp or equivalent os outcome" do
      assert_current_node :outcome_cp_or_equivalent
      assert_phrase_list :cp_or_equivalent_cp_outcome, [:synonyms_of_cp_in_sweden, :contact_local_authorities_in_country_cp, :cp_or_equivalent_cp_what_you_need_to_do, :embassies_data, :partner_naturalisation_in_uk, :standard_cni_fee_for_cp, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

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

  context "ceremony in US, same sex local partner" do
    setup do
      worldwide_api_has_organisations_for_location('usa', read_fixture_file('worldwide/usa_organisations.json'))
      add_response 'usa'
    end

    should "go to cp no cni required outcome and suggest both legal and travel advice to a UK resident" do
      add_response 'uk'
      add_response 'partner_local'
      add_response 'same_sex'
      assert_current_node :outcome_cp_no_cni
      assert_state_variable :country_name_lowercase_prefix, 'the USA'
      assert_phrase_list :no_cni_required_cp_outcome, [:synonyms_of_cp_in_usa, :get_legal_and_travel_advice, :what_you_need_to_do, :contact_embassy_or_consulate_representing_ceremony_country_in_uk_cp, :no_consular_facilities_to_register_ss, :partner_naturalisation_in_uk]
    end

    should "go to cp no cni required outcome and suggest legal advice to a US resident" do
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'same_sex'
      assert_current_node :outcome_cp_no_cni
      assert_state_variable :country_name_lowercase_prefix, 'the USA'
      assert_phrase_list :no_cni_required_cp_outcome, [:synonyms_of_cp_in_usa, :get_legal_advice, :what_you_need_to_do, :contact_local_authorities_in_country_cp, :no_consular_facilities_to_register_ss, :partner_naturalisation_in_uk]
    end
  end

  context "ceremony in bonaire, resident in the UK, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('bonaire-st-eustatius-saba', read_fixture_file('worldwide/bonaire-st-eustatius-saba_organisations.json'))
      add_response 'bonaire-st-eustatius-saba'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to cp no cni required outcome" do
      assert_current_node :outcome_cp_no_cni
      assert_phrase_list :no_cni_required_cp_outcome, [:"synonyms_of_cp_in_bonaire-st-eustatius-saba", :get_legal_and_travel_advice, :what_you_need_to_do, :country_is_dutch_caribbean_island, :contact_dutch_embassy_in_uk_cp, :no_consular_facilities_to_register_ss, :partner_naturalisation_in_uk]
    end
  end

  context "ceremony in bonaire, resident in bonaire, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('bonaire-st-eustatius-saba', read_fixture_file('worldwide/bonaire-st-eustatius-saba_organisations.json'))
      add_response 'bonaire-st-eustatius-saba'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to cp no cni required outcome" do
      assert_current_node :outcome_cp_no_cni
      assert_phrase_list :no_cni_required_cp_outcome, [:"synonyms_of_cp_in_bonaire-st-eustatius-saba", :get_legal_advice, :what_you_need_to_do, :country_is_dutch_caribbean_island, :contact_local_authorities_in_country_cp, :no_consular_facilities_to_register_ss]
    end
  end

  context "ceremony in bonaire, resident in third country, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('bonaire-st-eustatius-saba', read_fixture_file('worldwide/bonaire-st-eustatius-saba_organisations.json'))
      add_response 'bonaire-st-eustatius-saba'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to cp no cni required outcome" do
      assert_current_node :outcome_cp_no_cni
      assert_phrase_list :no_cni_required_cp_outcome, [:"synonyms_of_cp_in_bonaire-st-eustatius-saba", :get_legal_and_travel_advice, :what_you_need_to_do, :country_is_dutch_caribbean_island, :contact_local_authorities_in_country_cp, :no_consular_facilities_to_register_ss, :partner_naturalisation_in_uk]
    end
  end

  context "ceremony in canada, UK resident, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('canada', read_fixture_file('worldwide/canada_organisations.json'))
      add_response 'canada'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to cp commonwealth countries outcome" do
      assert_current_node :outcome_cp_commonwealth_countries
      assert_phrase_list :commonwealth_countries_cp_outcome, [:synonyms_of_cp_in_canada, :contact_high_comission_of_ceremony_country_in_uk_cp, :get_legal_and_travel_advice, :embassies_data, :partner_naturalisation_in_uk]
    end
  end

  context "ceremony in czech-republic, uk resident, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('czech-republic', read_fixture_file('worldwide/czech-republic_organisations.json'))
      add_response 'czech-republic'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to consular cni cp countries outcome" do
      assert_current_node :outcome_cp_or_equivalent
      assert_phrase_list :cp_or_equivalent_cp_outcome, [:"synonyms_of_cp_in_czech-republic", :contact_embassy_of_ceremony_country_in_uk_cp, :also_check_travel_advice, :partner_naturalisation_in_uk]
      assert_state_variable :pay_by_cash_or_credit_card_no_cheque, nil
    end
  end

  context "ceremony in vietnam, uk resident, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('vietnam', read_fixture_file('worldwide/vietnam_organisations.json'))
      add_response 'vietnam'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to all other countries outcome" do
      assert_current_node :outcome_ss_marriage_not_possible
    end
  end

  context "ceremony in turkmenistan" do
    setup do
      worldwide_api_has_organisations_for_location('turkmenistan', read_fixture_file('worldwide/turkmenistan_organisations.json'))
      add_response 'turkmenistan'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to all other countries outcome" do
      assert_current_node :outcome_cp_all_other_countries
    end
  end

  context "ceremony in latvia, lives elsewhere, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('latvia', read_fixture_file('worldwide/latvia_organisations.json'))
      add_response 'latvia'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to consular cni cp countries outcome" do
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage, :contact_embassy_or_consulate, :embassies_data, :documents_needed_21_days_residency, :documents_needed_ss_british, :what_to_do_ss_marriage, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage, :provide_two_witnesses_ss_marriage, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_alt, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in serbia, lives elsewhere, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('serbia', read_fixture_file('worldwide/serbia_organisations.json'))
      add_response 'serbia'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to cp all other countries outcome" do
      assert_current_node :outcome_ss_marriage
    end
  end

  context "ceremony in Nicaragua" do
    setup do
      worldwide_api_has_organisations_for_location('nicaragua', read_fixture_file('worldwide/nicaragua_organisations.json'))
      add_response 'nicaragua'
    end

    should "go to consular cni os outcome when user resides in Nicaragua and show address of the Embassy in Costa Rica" do
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :arrange_cni_via_costa_rica, :embassies_data, :required_supporting_documents_incl_birth_cert, :consular_cni_os_not_uk_resident_ceremony_not_germany, :evidence_if_divorced_outside_uk, :download_and_fill_notice_and_affidavit_but_not_sign, :display_notice_of_marriage_7_days]
      assert_equal "British Embassy San Jose", current_state.organisation.title
    end

    should "go to outcome_consular_cni_os_residing_in_third_country and suggest arranging CNI through the Embassy in Costa Rica" do
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
      assert_current_node :outcome_consular_cni_os_residing_in_third_country
      assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :cni_os_consular_facilities_unavailable, :what_you_need_to_do, :you_may_be_asked_for_cni, :getting_cni_from_costa_rica_when_in_third_country]
    end
  end

  context "ceremony in australia, resident in the UK" do
    setup do
      worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
      add_response 'australia'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to outcome_ss_marriage" do
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_title, [:title_ss_marriage]
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage, "appointment_links.same_sex.australia", :documents_needed_21_days_residency, :documents_needed_ss_not_british, :what_to_do_ss_marriage, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage, :provide_two_witnesses_ss_marriage, :australia_ss_relationships, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_alt, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque, :convert_cc_to_ss_marriage]
    end
  end

  context "australia opposite sex outcome" do
    should "bring you to australia os outcome" do
      worldwide_api_has_organisations_for_location('australia', read_fixture_file('worldwide/australia_organisations.json'))
      add_response 'australia'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'same_sex'
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_title, [:title_ss_marriage]
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage, "appointment_links.same_sex.australia", :documents_needed_21_days_residency, :documents_needed_ss_british, :what_to_do_ss_marriage, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage, :provide_two_witnesses_ss_marriage, :australia_ss_relationships, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_alt, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque, :convert_cc_to_ss_marriage]
    end
  end

  context "ceremony in china, partner is not from china, opposite sex" do
    should "render address from API" do
      worldwide_api_has_organisations_for_location('china', read_fixture_file('worldwide/china_organisations.json'))
      add_response 'china'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :book_online_china_non_local_prelude, "appointment_links.opposite_sex.china", :book_online_china_affirmation_affidavit, :documents_for_divorced_or_widowed_china_colombia, :change_of_name_evidence, :partner_probably_needs_affirmation_or_affidavit, :affirmation_os_all_fees_45_70, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in china, partner is not from china, same sex" do
    should "render address from API" do
      worldwide_api_has_organisations_for_location('china', read_fixture_file('worldwide/china_organisations.json'))
      add_response 'china'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'same_sex'
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage, :contact_embassy_or_consulate, :embassies_data, :documents_needed_21_days_residency, :documents_needed_ss_not_british, :what_to_do_ss_marriage, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage, :provide_two_witnesses_ss_marriage, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_alt, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in china, partner is national of china" do
    should "render address from API" do
      worldwide_api_has_organisations_for_location('china', read_fixture_file('worldwide/china_organisations.json'))
      add_response 'china'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do, :book_online_china_local_prelude, "appointment_links.opposite_sex.china", :book_online_china_affirmation_affidavit, :documents_for_divorced_or_widowed_china_colombia, :change_of_name_evidence, :callout_partner_equivalent_document, :partner_naturalisation_in_uk, :affirmation_os_all_fees_45_70, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in Japan" do
    setup do
      worldwide_api_has_organisations_for_location('japan', read_fixture_file('worldwide/japan_organisations.json'))
      add_response 'japan'
    end

    context "resident of Japan with a local resident" do
      setup do
        add_response 'ceremony_country'
        add_response 'partner_local'
      end

      should "give a japan-specific outcome" do
        add_response 'opposite_sex'
        assert_current_node :outcome_os_local_japan
        assert_phrase_list :japan_os_local_phraselist, [:contact_local_authorities_in_country_marriage, :japan_legal_advice, :what_you_need_to_do, :what_to_do_os_local_japan, :consular_cni_os_not_uk_resident_ceremony_not_germany, :what_happens_next_os_local_japan, :names_on_documents_must_match, :partner_naturalisation_in_uk, :fee_table_oath_declaration_55, :link_to_consular_fees, :payment_methods_japan]
      end
      should "give ss outcome with japan variants" do
        add_response 'same_sex'
        assert_current_node :outcome_ss_marriage
        assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage_and_partnership, :contact_to_make_appointment, :embassies_data, :documents_needed_21_days_residency, :documents_needed_ss_british, :what_to_do_ss_marriage_and_partnership, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage_and_partnership, :provide_two_witnesses_ss_marriage_and_partnership, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_and_partnership, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque, :convert_cc_to_ss_marriage]
      end
    end

    context "opposite sex UK residents" do
      setup do
        add_response 'uk'
        add_response 'partner_british'
        add_response 'opposite_sex'
      end

      should "have a japan-specific intro" do
        assert_current_node :outcome_os_consular_cni
        assert_phrase_list :consular_cni_os_start, [:japan_intro, :what_you_need_to_do, :you_may_be_asked_for_cni, :cni_at_local_register_office, :cni_issued_locally_validity, :legisation_and_translation_intro_uk, :legalise_translate_and_check_with_authorities]
      end
    end

    context "resident of Japan with an opposite sex partner from anywhere" do
      setup do
        add_response 'ceremony_country'
        add_response 'partner_other'
        add_response 'opposite_sex'
      end

      should "give CNI outcome when marrying to an opposite sex non-local partner" do
        assert_current_node :outcome_os_consular_cni
        assert_phrase_list :consular_cni_os_start, [:japan_intro, :what_you_need_to_do, :you_may_be_asked_for_cni, :consular_cni_os_giving_notice_in_ceremony_country, :embassies_data, :japan_consular_cni_os_local_resident, :consular_cni_os_not_uk_resident_ceremony_not_germany, :evidence_if_divorced_outside_uk, :download_and_fill_notice_and_affidavit_but_not_sign, :consular_cni_os_foreign_resident_ceremony_notary_public]
        assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match, :check_if_cni_needs_to_be_legalised, :no_need_to_stay_after_posting_notice, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
      end
    end
  end

  context "testing that Vietnam is now affirmation to marry outcome" do
    should "give the outcome" do
      worldwide_api_has_organisations_for_location('vietnam', read_fixture_file('worldwide/vietnam_organisations.json'))
      add_response 'vietnam'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_affirmation
      assert_state_variable :ceremony_type_lowercase, 'marriage'
      assert_phrase_list :affirmation_os_outcome, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :embassies_data, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :callout_partner_equivalent_document, :partner_naturalisation_in_uk, :fee_table_affidavit_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in switzerland, resident in switzerland, partner opposite sex" do
    should "give swiss outcome with variants (gender variant)" do
      worldwide_api_has_organisations_for_location('switzerland', read_fixture_file('worldwide/switzerland_organisations.json'))
      add_response 'switzerland'
      add_response 'uk'
      add_response 'opposite_sex'
      assert_current_node :outcome_switzerland
      assert_state_variable :ceremony_type_lowercase, 'marriage'
    end
  end

  context "ceremony in switzerland, resident in switzerland, partner same sex" do
    should "give swiss outcome with variants" do
      worldwide_api_has_organisations_for_location('switzerland', read_fixture_file('worldwide/switzerland_organisations.json'))
      add_response 'switzerland'
      add_response 'ceremony_country'
      add_response 'same_sex'
      assert_current_node :outcome_switzerland
      assert_state_variable :ceremony_type_lowercase, 'civil partnership'
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
    end
  end

  context "ceremony in switzerland, not resident in switzerland, partner same sex" do
    should "give swiss outcome with variants" do
      worldwide_api_has_organisations_for_location('switzerland', read_fixture_file('worldwide/switzerland_organisations.json'))
      add_response 'switzerland'
      add_response 'third_country'
      add_response 'opposite_sex'
      assert_current_node :outcome_switzerland
      assert_state_variable :ceremony_type_lowercase, 'marriage'
    end
  end

  context "peru outcome mapped to lebanon for same sex" do
    should "go to outcome cp all other countries" do
      worldwide_api_has_organisations_for_location('peru', read_fixture_file('worldwide/peru_organisations.json'))
      add_response 'peru'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'same_sex'
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage_and_partnership, :contact_embassy_or_consulate, :embassies_data, :documents_needed_21_days_residency, :documents_needed_ss_british, :what_to_do_ss_marriage_and_partnership, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage_and_partnership, :provide_two_witnesses_ss_marriage_and_partnership, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_and_partnership, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "peru outcome mapped to lebanon for opposite sex" do
    should "go to outcome os affirmation" do
      worldwide_api_has_organisations_for_location('peru', read_fixture_file('worldwide/peru_organisations.json'))
      add_response 'peru'
      add_response 'uk'
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
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to cni outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_in_euros_or_visa_electron]
      assert_phrase_list :consular_cni_os_start, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :cni_at_local_register_office, :cni_issued_locally_validity, :legalisation_and_translation_check_with_authorities, :legalise_translate_and_check_with_authorities]
     end
  end

  context "ceremony in finland, resident in the UK, partner local" do
    setup do
      worldwide_api_has_organisations_for_location('finland', read_fixture_file('worldwide/finland_organisations.json'))
      add_response 'finland'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to cni outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_remainder, [:names_on_documents_must_match, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_in_euros_or_visa_electron]
      assert_phrase_list :consular_cni_os_start, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :cni_at_local_register_office, :cni_issued_locally_validity, :legalisation_and_translation_check_with_authorities, :legalise_translate_and_check_with_authorities]
     end
  end

  context "ceremony in finland, resident in Australia, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('finland', read_fixture_file('worldwide/finland_organisations.json'))
      add_response 'finland'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to affirmation outcome with specific fee table" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :embassies_data, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :callout_partner_equivalent_document, :partner_naturalisation_in_uk, :fee_table_affirmation_65, :link_to_consular_fees, :pay_in_euros_or_visa_electron]
    end
  end

  context "ceremony in finland, resident in the UK, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('finland', read_fixture_file('worldwide/finland_organisations.json'))
      add_response 'finland'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to outcome cni with specific fee table" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_remainder, [:callout_partner_equivalent_document, :names_on_documents_must_match, :partner_naturalisation_in_uk, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_in_euros_or_visa_electron]
      assert_phrase_list :consular_cni_os_start, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :cni_at_local_register_office, :cni_issued_locally_validity, :legalisation_and_translation_check_with_authorities, :legalise_translate_and_check_with_authorities]
    end
  end

  context "ceremony in finland, resident in the UK, partner other, SS" do
    setup do
      worldwide_api_has_organisations_for_location('finland', read_fixture_file('worldwide/finland_organisations.json'))
      add_response 'finland'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to affirmation outcome with specific fee table" do
      assert_current_node :outcome_cp_or_equivalent
      assert_phrase_list :cp_or_equivalent_cp_outcome, [:synonyms_of_cp_in_finland, :contact_embassy_of_ceremony_country_in_uk_cp, :also_check_travel_advice, :cp_or_equivalent_cp_what_you_need_to_do, :embassies_data, :partner_naturalisation_in_uk, :standard_cni_fee_for_cp, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "south-korea new outcome" do
    should "go to outcome os affirmation with new korea phraselist" do
      worldwide_api_has_organisations_for_location('south-korea', read_fixture_file('worldwide/south-korea_organisations.json'))
      add_response 'south-korea'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :embassies_data, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :partner_probably_needs_affirmation, :fee_table_affidavit_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in philippines, uk resident, partner other" do
    setup do
      worldwide_api_has_organisations_for_location('philippines', read_fixture_file('worldwide/philippines_organisations.json'))
      add_response 'philippines'
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_phrase_list :affirmation_os_outcome, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do_affirmation, :contact_for_affidavit, "appointment_links.opposite_sex.philippines", :required_supporting_documents_philippines, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :affirmation_os_download_affidavit_philippines, :documents_for_divorced_or_widowed_philippines, :callout_partner_equivalent_document, :partner_naturalisation_in_uk, :fee_table_55_70, :link_to_consular_fees, :pay_in_cash_only]
    end
  end

  context "slovakia, no money phraselists" do
    should "" do
      worldwide_api_has_organisations_for_location('slovakia', read_fixture_file('worldwide/slovakia_organisations.json'))
      add_response 'slovakia'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:contact_embassy_or_consulate_representing_ceremony_country_in_uk, :get_legal_and_travel_advice, :cni_os_consular_facilities_unavailable]
    end
  end

  context "netherlands outcome" do
    should "bring you to netherlands outcome" do
      worldwide_api_has_organisations_for_location('netherlands', read_fixture_file('worldwide/netherlands_organisations.json'))
      add_response 'netherlands'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_netherlands
    end
  end

  context "Indonesia, opposite sex outcome" do
    setup do
      worldwide_api_has_organisations_for_location('indonesia', read_fixture_file('worldwide/indonesia_organisations.json'))
      add_response 'indonesia'
    end

    should "bring you to the custom Indonesia os outcome for uk residents" do
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_indonesia
    end

    should "bring you to the custom Indonesia os outcome for third country residents" do
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_indonesia
    end
  end

  context "aruba opposite sex outcome" do
    should "bring you to aruba os outcome" do
      worldwide_api_has_organisations_for_location('aruba', read_fixture_file('worldwide/aruba_organisations.json'))
      add_response 'aruba'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_remainder, [:same_cni_process_and_fees_for_partner, :names_on_documents_must_match, :consular_cni_os_fees_incl_null_osta_oath_consular_letter]
    end
  end

  context "ceremony in azerbaijan, resident in the UK, same sex non-local partner" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      add_response 'azerbaijan'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to outcome_ss_marriage" do
      assert_current_node :outcome_ss_marriage
    end
  end

  context "uk resident, ceremony in estonia, partner same sex british" do
    setup do
      worldwide_api_has_organisations_for_location('estonia', read_fixture_file('worldwide/estonia_organisations.json'))
      add_response 'estonia'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to ss outcome" do
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_title, [:title_ss_marriage]
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage, :contact_embassy_or_consulate, :embassies_data, :documents_needed_21_days_residency, :documents_needed_ss_british, :what_to_do_ss_marriage, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage, :provide_two_witnesses_ss_marriage, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_alt, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in russia, lives elsewhere, same sex marriage, non british partner" do
    setup do
      worldwide_api_has_organisations_for_location('russia', read_fixture_file('worldwide/russia_organisations.json'))
      add_response 'russia'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to outcome_ss_marriage_not_possible" do
      assert_current_node :outcome_ss_marriage_not_possible
    end
  end

  context "Marrying anywhere in the world > British National living in third country > Partner of any nationality > Opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('vietnam', read_fixture_file('worldwide/vietnam_organisations.json'))
      add_response 'vietnam'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to affirmation_os_outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do_affirmation, :appointment_for_affidavit, :embassies_data, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :callout_partner_equivalent_document, :partner_naturalisation_in_uk, :fee_table_affidavit_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "kazakhstan should show its correct embassy page" do
    setup do
      worldwide_api_has_organisations_for_location('kazakhstan', read_fixture_file('worldwide/kazakhstan_organisations.json'))
      add_response 'kazakhstan'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to outcome_consular_cni_os_residing_in_third_country" do
      assert_current_node :outcome_consular_cni_os_residing_in_third_country
      assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :standard_ways_to_get_cni_in_third_country]
      assert_state_variable :ceremony_country_residence_outcome_path, "/marriage-abroad/y/kazakhstan/ceremony_country/partner_british/opposite_sex"
      assert_state_variable :uk_residence_outcome_path, "/marriage-abroad/y/kazakhstan/uk/partner_british/opposite_sex"
    end
  end

  context "Marrying in Portugal > British National not living in the UK > Resident anywhere > Partner of any nationality > Opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('portugal', read_fixture_file('worldwide/portugal_organisations.json'))
      add_response 'portugal'
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to portugal outcome" do
      assert_current_node :outcome_portugal
    end
  end

  context "Marrying in Portugal > British National living in the UK > Partner of any nationality > Opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('portugal', read_fixture_file('worldwide/portugal_organisations.json'))
      add_response 'portugal'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to portugal outcome" do
      assert_current_node :outcome_portugal
    end
  end

  context "Residency Country and ceremony country = Croatia" do
    setup do
      worldwide_api_has_organisations_for_location('croatia', read_fixture_file('worldwide/croatia_organisations.json'))
      add_response 'croatia'
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to outcome_os_consular_cni and show specific phraselist" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do, :what_to_do_croatia, :consular_cni_os_local_resident_table, "appointment_links.opposite_sex.croatia", :required_supporting_documents_notary_public, :consular_cni_os_not_uk_resident_ceremony_not_germany, :evidence_if_divorced_outside_uk, :download_and_fill_notice_and_affidavit_but_not_sign, :consular_cni_os_foreign_resident_ceremony_notary_public]
    end
  end

  context "Marrying in Qatar" do
    setup do
      worldwide_api_has_organisations_for_location('qatar', read_fixture_file('worldwide/croatia_organisations.json'))
      add_response 'qatar'
    end
    should "go to outcome_os_consular_cni and show specific phraselist for OS marriage of local residents" do
      add_response 'ceremony_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_local_authorities_in_country_marriage, :gulf_states_os_consular_cni, :gulf_states_os_consular_cni_local_resident, :get_legal_advice, :what_you_need_to_do_affirmation_21_days, :appointment_for_affidavit, :embassies_data, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :callout_partner_equivalent_document, :partner_naturalisation_in_uk, :fee_table_45_70_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end

    should "go to outcome_os_consular_cni and show specific phraselist for OS marriage of residents in a 3rd country" do
      add_response 'third_country'
      add_response 'partner_other'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_local_authorities_in_country_marriage, :gulf_states_os_consular_cni, :gulf_states_os_consular_cni_local_resident, :get_legal_and_travel_advice, :what_you_need_to_do_affirmation_21_days, :appointment_for_affidavit, :embassies_data, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :callout_partner_equivalent_document, :partner_naturalisation_in_uk, :fee_table_45_70_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in Lithuania, partner same sex, partner british" do
    setup do
      worldwide_api_has_organisations_for_location('lithuania', read_fixture_file('worldwide/lithuania_organisations.json'))
      add_response 'lithuania'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to outcome_ss_marriage" do
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage, :contact_embassy_or_consulate, :embassies_data, :documents_needed_21_days_residency, :documents_needed_ss_british, :what_to_do_ss_marriage, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage, :provide_two_witnesses_ss_marriage, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "ceremony in Lithuania, partner same sex, partner not british" do
    setup do
      worldwide_api_has_organisations_for_location('lithuania', read_fixture_file('worldwide/lithuania_organisations.json'))
      add_response 'lithuania'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to outcome 'no same sex marriage allowed' because partner is not british" do
      assert_current_node :outcome_cp_all_other_countries
    end
  end

  context "Ceremony in Belarus" do
    setup do
      worldwide_api_has_organisations_for_location('belarus', read_fixture_file('worldwide/belarus_organisations.json'))
      add_response 'belarus'
    end
    should "go to outcome_os_consular_cni and show correct address box for resident in Belarus country, opposite sex marriage" do
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_consular_cni
      assert_match /37, Karl Marx Street/, outcome_body
    end

    should "go to outcome_consular_cni_os_residing_in_third_country when in third country" do
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_consular_cni_os_residing_in_third_country
      assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :standard_ways_to_get_cni_in_third_country]
      assert_state_variable :ceremony_country_residence_outcome_path, "/marriage-abroad/y/belarus/ceremony_country/partner_british/opposite_sex"
      assert_state_variable :uk_residence_outcome_path, "/marriage-abroad/y/belarus/uk/partner_british/opposite_sex"
    end
  end

  context "test morocco specific phraselists, living in the UK" do
    setup do
      worldwide_api_has_organisations_for_location('morocco', read_fixture_file('worldwide/morocco_organisations.json'))
      add_response 'morocco'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_embassy_of_ceremony_country_in_uk_marriage, :contact_laadoul, :get_legal_and_travel_advice, :what_you_need_to_do_affirmation, :appointment_for_affidavit, "appointment_links.opposite_sex.morocco", :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :documents_for_divorced_or_widowed, :morocco_affidavit_length, :partner_equivalent_document, :fee_table_affirmation_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "test morocco specific phraselists, living elsewhere" do
    setup do
      worldwide_api_has_organisations_for_location('morocco', read_fixture_file('worldwide/morocco_organisations.json'))
      add_response 'morocco'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to os affirmation outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_local_authorities_in_country_marriage, :contact_laadoul, :get_legal_and_travel_advice, :what_you_need_to_do_affirmation, :appointment_for_affidavit, "appointment_links.opposite_sex.morocco", :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :documents_for_divorced_or_widowed, :morocco_affidavit_length, :partner_equivalent_document, :fee_table_affirmation_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "Mexico" do
    setup do
      worldwide_api_has_organisations_for_location('mexico', read_fixture_file('worldwide/mexico_organisations.json'))
      add_response 'mexico'
    end

    should "go to outcome_consular_cni_os_residing_in_third_country" do
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_consular_cni_os_residing_in_third_country
      assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :standard_ways_to_get_cni_in_third_country]
      assert_state_variable :ceremony_country_residence_outcome_path, "/marriage-abroad/y/mexico/ceremony_country/partner_british/opposite_sex"
      assert_state_variable :uk_residence_outcome_path, "/marriage-abroad/y/mexico/uk/partner_british/opposite_sex"
    end

    should "show outcome_os_consular_cni when partner is local" do
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_consular_cni
    end

    should "show outcome_os_consular_cni when partner is british" do
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_consular_cni
    end
  end

  context "Marriage in Albania, living elsewhere, partner British, opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('albania', read_fixture_file('worldwide/albania_organisations.json'))
      add_response 'albania'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "lead to outcome_consular_cni_os_residing_in_third_country" do
      assert_current_node :outcome_consular_cni_os_residing_in_third_country
      assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :standard_ways_to_get_cni_in_third_country]
      assert_state_variable :ceremony_country_residence_outcome_path, "/marriage-abroad/y/albania/ceremony_country/partner_british/opposite_sex"
      assert_state_variable :uk_residence_outcome_path, "/marriage-abroad/y/albania/uk/partner_british/opposite_sex"
    end
  end

  context "Marriage in Democratic Republic of Congo, living elsewhere, partner British, opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('democratic-republic-of-congo', read_fixture_file('worldwide/democratic-republic-of-congo_organisations.json'))
      add_response 'democratic-republic-of-congo'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "lead to outcome_consular_cni_os_residing_in_third_country" do
      assert_current_node :outcome_consular_cni_os_residing_in_third_country
      assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :standard_ways_to_get_cni_in_third_country]
      assert_state_variable :ceremony_country_residence_outcome_path, "/marriage-abroad/y/democratic-republic-of-congo/ceremony_country/partner_british/opposite_sex"
      assert_state_variable :uk_residence_outcome_path, "/marriage-abroad/y/democratic-republic-of-congo/uk/partner_british/opposite_sex"
    end
  end

  context "Marriage in Mexico, living in the UK, partner British, opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('mexico', read_fixture_file('worldwide/mexico_organisations.json'))
      add_response 'mexico'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "show outcome_os_consular_cni" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :cni_at_local_register_office, :cni_issued_locally_validity, :legisation_and_translation_intro_uk, :legalise_translate_and_check_with_authorities]
      assert_phrase_list :consular_cni_os_remainder, [:same_cni_process_and_fees_for_partner, :names_on_documents_must_match, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "Marriage in Albania, living in the UK, partner British, opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('albania', read_fixture_file('worldwide/albania_organisations.json'))
      add_response 'albania'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "show outcome_os_consular_cni" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :cni_at_local_register_office, :cni_issued_locally_validity, :legisation_and_translation_intro_uk, :legalise_translate_and_check_with_authorities]
      assert_phrase_list :consular_cni_os_remainder, [:same_cni_process_and_fees_for_partner, :names_on_documents_must_match, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  #Marriage that requires a 7 day notice to be given
  context "Marriage in Canada, living elsewhere" do
    setup do
      worldwide_api_has_organisations_for_location('canada', read_fixture_file('worldwide/canada_organisations.json'))
      add_response 'canada'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "show 7 day notice" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :cant_issue_cni_for_commonwealth]
    end
  end

  context "Marriage in Rwanda, living elsewhere" do
    setup do
      worldwide_api_has_organisations_for_location('rwanda', read_fixture_file('worldwide/rwanda_organisations.json'))
      add_response 'rwanda'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "show 7 day notice" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :cni_os_consular_facilities_unavailable, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque, :display_notice_of_marriage_7_days]
    end
  end

  context "same sex marriage in San Marino is not allowed" do
    setup do
      worldwide_api_has_organisations_for_location('san-marino', read_fixture_file('worldwide/san-marino_organisations.json'))
      add_response 'san-marino'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "do not allow marriage" do
      assert_current_node :outcome_ss_marriage_not_possible
    end
  end

  context "same sex marriage in Malta" do
    setup do
      worldwide_api_has_organisations_for_location('malta', read_fixture_file('worldwide/malta_organisations.json'))
      add_response 'malta'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "do not allow marriage" do
      assert_current_node :outcome_ss_marriage_malta
      assert_phrase_list :ss_body, [:able_to_ss_marriage_and_partnership_hc, :contact_to_make_appointment, :embassies_data, :documents_needed_21_days_residency, :documents_needed_ss_british, :what_to_do_ss_marriage_and_partnership_hc, :will_display_in_14_days_hc, :no_objection_in_14_days_ss_marriage_and_partnership, :provide_two_witnesses_ss_marriage_and_partnership, :ss_marriage_footnote_hc, :partner_naturalisation_in_uk, :fees_table_ss_marriage_and_partnership, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque, :convert_cc_to_ss_marriage]
    end
  end

  context "opposite sex marriage in Malta" do
    setup do
      worldwide_api_has_organisations_for_location('malta', read_fixture_file('worldwide/malta_organisations.json'))
      add_response 'malta'
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "do not allow marriage" do
      assert_current_node :outcome_os_commonwealth
    end
  end

  context "opposite sex marriage in Brazil with local partner" do
    setup do
      worldwide_api_has_organisations_for_location('brazil', read_fixture_file('worldwide/brazil_organisations.json'))
      add_response 'brazil'
    end

    should "divert to the correct download link for the Affidavit for Marriage document when in a third country" do
      add_response 'third_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
      assert_current_node :outcome_brazil_not_living_in_the_uk
      assert_phrase_list :brazil_phraselist_not_in_the_uk, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :make_an_appointment_bring_passport_and_pay_55_brazil, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque, :embassies_data, :download_affidavit_forms_but_do_not_sign, :download_affidavit_brazil, :documents_for_divorced_or_widowed]
    end

    should "suggest to swear affidavit in front of notary public when in ceremony country" do
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'
      assert_current_node :outcome_brazil_not_living_in_the_uk
      assert_phrase_list :brazil_phraselist_not_in_the_uk, [:contact_local_authorities, :get_legal_advice, :consular_cni_os_download_affidavit_notary_public, :notary_public_will_charge_a_fee, :names_on_documents_must_match, :partner_naturalisation_in_uk]
    end
  end

  context "ceremony in Greece" do
    setup do
      worldwide_api_has_organisations_for_location('greece', read_fixture_file('worldwide/greece_organisations.json'))
      add_response 'greece'
    end

    context "lives in 3rd country, all opposite-sex outcomes" do
      setup do
        add_response 'third_country'
        add_response 'partner_other'
        add_response 'opposite_sex'
      end

      should "leads to outcome_consular_cni_os_residing_in_third_country" do
        assert_current_node :outcome_consular_cni_os_residing_in_third_country
        assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :standard_ways_to_get_cni_in_third_country]
        assert_state_variable :ceremony_country_residence_outcome_path, "/marriage-abroad/y/greece/ceremony_country/partner_other/opposite_sex"
        assert_state_variable :uk_residence_outcome_path, "/marriage-abroad/y/greece/uk/partner_other/opposite_sex"
      end
    end

    context "resident in Greece, all opposite-sex outcomes" do
      setup do
        add_response 'ceremony_country'
        add_response 'partner_other'
        add_response 'opposite_sex'
      end
      should "lead to outcome_os_consular_cni with Greece-specific appoitnment link and document requirements" do
        assert_current_node :outcome_os_consular_cni
        assert_phrase_list :consular_cni_os_start, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :consular_cni_os_giving_notice_in_ceremony_country, :living_in_ceremony_country_3_days, "appointment_links.opposite_sex.greece", :required_supporting_documents_greece, :consular_cni_os_not_uk_resident_ceremony_not_germany, :evidence_if_divorced_outside_uk, :download_and_fill_notice_and_affidavit_but_not_sign, :consular_cni_os_foreign_resident_ceremony_notary_public_greece]
      end
    end
  end

  context "ceremony in Uzbekistan, resident in the UK, partner from anywhere, opposite sex" do
    setup do
      worldwide_api_has_organisations_for_location('uzbekistan', read_fixture_file('worldwide/uzbekistan_organisations.json'))
      add_response 'uzbekistan'
      add_response 'uk'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "not include the links to download documents" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :cni_at_local_register_office, :cni_issued_locally_validity, :legisation_and_translation_intro_uk, :legalise_translate_and_check_with_authorities]
    end
  end

  context "ceremony in Laos" do
    setup do
      worldwide_api_has_organisations_for_location('laos', read_fixture_file('worldwide/laos_organisations.json'))
      add_response 'laos'
    end

    context "resident in the UK, opposite sex partner from Laos" do
      setup do
        add_response 'uk'
        add_response 'partner_local'
        add_response 'opposite_sex'
      end
      should "lead to outcome_os_laos" do
        assert_current_node :outcome_os_laos
      end
    end

    context "resident in 3rd country, opposite sex partner from Laos" do
      setup do
        add_response 'third_country'
        add_response 'partner_local'
        add_response 'opposite_sex'
      end
      should "lead to outcome_os_laos" do
        assert_current_node :outcome_os_laos
      end
    end

    context "resident in Laos, opposite sex partner from Laos" do
      setup do
        add_response 'ceremony_country'
        add_response 'partner_local'
        add_response 'opposite_sex'
      end
      should "lead to outcome_os_laos" do
        assert_current_node :outcome_os_laos
      end
    end

    context "opposite sex partner, no Laos nationals" do
      setup do
        add_response 'uk'
        add_response 'partner_other'
        add_response 'opposite_sex'
      end
      should "lead to outcome_os_marriage_impossible_no_laos_locals" do
        assert_current_node :outcome_os_marriage_impossible_no_laos_locals
      end
    end
  end

  context "Albania" do
    should "allow same sex marriage and civil partnership conversion to marriage, has custom appointment booking link" do
      worldwide_api_has_organisations_for_location('albania', read_fixture_file('worldwide/albania_organisations.json'))
      add_response 'albania'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'same_sex'

      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage_and_partnership, "appointment_links.same_sex.albania", :documents_needed_21_days_residency, :documents_needed_ss_not_british, :what_to_do_ss_marriage_and_partnership, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage_and_partnership, :provide_two_witnesses_ss_marriage_and_partnership, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_and_partnership, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque, :convert_cc_to_ss_marriage]
    end
  end

  context "Costa Rica" do
    should "indicate that same sex marriage or civil partnership is not recognised anymore" do
      worldwide_api_has_organisations_for_location('costa-rica', read_fixture_file('worldwide/costa-rica_organisations.json'))
      add_response 'costa-rica'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'same_sex'

      assert_current_node :outcome_cp_all_other_countries
    end
  end

  context "Kosovo" do
    setup do
      worldwide_api_has_organisations_for_location('kosovo', read_fixture_file('worldwide/kosovo_organisations.json'))
      add_response 'kosovo'
    end

    should "lead to outcome_consular_cni_os_residing_in_third_country if in third country" do
      add_response 'third_country'
      add_response 'partner_local'
      add_response 'opposite_sex'

      assert_current_node :outcome_consular_cni_os_residing_in_third_country
    end

    should "lead to a outcome_os_kosovo with uk resident phraselist when residing in the UK" do
      add_response 'uk'
      add_response 'partner_local'
      add_response 'opposite_sex'

      assert_current_node :outcome_os_kosovo
      assert_phrase_list :kosovo_os_phraselist, [:kosovo_uk_resident]
    end

    should "lead to a outcome_os_kosovo with local resident phraselist when residing in Kosovo" do
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'opposite_sex'

      assert_current_node :outcome_os_kosovo
      assert_phrase_list :kosovo_os_phraselist, [:kosovo_local_resident]
    end
  end

  context "Montenegro" do
    setup do
      worldwide_api_has_organisations_for_location('montenegro', read_fixture_file('worldwide/montenegro_organisations.json'))
      add_response 'montenegro'
      add_response 'ceremony_country'
    end

    should "lead to outcome_ss_marriage when both partners are same sex british" do
      add_response 'partner_british'
      add_response 'same_sex'
      assert_current_node :outcome_ss_marriage
    end

    should "lead to outcome_ss_marriage_not_possible when both partners are same sex not british" do
      add_response 'partner_local'
      add_response 'same_sex'
      assert_current_node :outcome_ss_marriage_not_possible
    end
  end

  context "Saint-Barthélemy" do
    setup do
      worldwide_api_has_no_organisations_for_location('st-martin')
      worldwide_api_has_no_organisations_for_location('saint-barthelemy')
      add_response 'saint-barthelemy'
      add_response 'third_country'
      add_response 'partner_british'
    end

    should "suggest to contact local authorities even if the user is in third country for OS (because they don't have many embassies)" do
      add_response 'opposite_sex'

      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :cni_os_consular_facilities_unavailable]
    end

    should "suggest to contact local authorities even if the user is in third country for SS (because they don't have many embassies)" do
      add_response 'same_sex'

      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :cni_os_consular_facilities_unavailable]
    end
  end

  context "St Martin" do
    setup do
      worldwide_api_has_no_organisations_for_location('st-martin')
      worldwide_api_has_no_organisations_for_location('saint-barthelemy')
      add_response 'st-martin'
      add_response 'third_country'
      add_response 'partner_british'
    end

    should "suggest to contact local authorities even if the user is in third country for OS (because they don't have many embassies)" do
      add_response 'opposite_sex'

      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :cni_os_consular_facilities_unavailable]
    end

    should "suggest to contact local authorities even if the user is in third country for SS (because they don't have many embassies)" do
      add_response 'same_sex'

      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :cni_os_consular_facilities_unavailable]
    end
  end

  context "Macao" do
    should "lead to an affirmation outcome for opposite sex marriages directing users to Hong Kong" do
      worldwide_api_has_no_organisations_for_location('macao')
      add_response 'macao'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'

      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do_affirmation, :appointment_for_affidavit_in_hong_kong, "appointment_links.opposite_sex.macao", :complete_affirmation_or_affidavit_forms, :download_and_fill_but_not_sign, :download_affidavit_and_affirmation_macao, :required_supporting_documents_macao, :partner_probably_needs_affirmation, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :partner_probably_needs_affirmation, :fee_table_affirmation_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end

    should "lead to an affirmation outcome for opposite sex marriages directing users to Hong Kong with an intro about residency" do
      worldwide_api_has_no_organisations_for_location('macao')
      add_response 'macao'
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'

      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:one_must_be_a_resident, :contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do_affirmation, :appointment_for_affidavit_in_hong_kong, "appointment_links.opposite_sex.macao", :complete_affirmation_or_affidavit_forms, :download_and_fill_but_not_sign, :download_affidavit_and_affirmation_macao, :required_supporting_documents_macao, :partner_probably_needs_affirmation, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :partner_probably_needs_affirmation, :fee_table_affirmation_55, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "Hong Kong" do
    should "lead to the custom outcome directing users to the local Immigration Department for opposite sex marriages" do
      worldwide_api_has_no_organisations_for_location('hong-kong')
      add_response 'hong-kong'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'

      assert_current_node :outcome_os_hong_kong
    end
  end

  context "Norway" do
    setup do
      worldwide_api_has_organisations_for_location('norway', read_fixture_file('worldwide/norway_organisations.json'))
      add_response 'norway'
    end

    should "lead to the affirmation outcome when in Norway" do
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do_affirmation, :appointment_for_affidavit_norway, "appointment_links.opposite_sex.norway", :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :docs_decree_and_death_certificate, :divorced_or_widowed_evidences, :change_of_name_evidence, :partner_probably_needs_affirmation, :fee_table_affirmation_55, :link_to_consular_fees, :pay_by_visas_or_mastercard]
    end

    should "lead to the CNI outcome for opposite sex marriages for UK residents" do
      add_response 'uk'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:contact_embassy_of_ceremony_country_in_uk_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :cni_at_local_register_office, :cni_issued_locally_validity, :legisation_and_translation_intro_uk, :legalise_translate_and_check_with_authorities]
      assert_phrase_list :consular_cni_os_remainder, [:same_cni_process_and_fees_for_partner, :names_on_documents_must_match, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end

    should "lead to a custom CNI third country outcome when in a thiord country" do
      add_response 'third_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_consular_cni_os_residing_in_third_country
      assert_phrase_list :body, [:contact_local_authorities_in_country_marriage, :get_legal_and_travel_advice, :what_you_need_to_do, :what_you_need_to_do_to_marry_in_norway_when_in_third_country]
    end

    should "lead to SS affirmation outcome" do
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'same_sex'

      assert_current_node :outcome_ss_affirmation
      assert_phrase_list :body, [:synonyms_of_cp_in_norway, :contact_local_authorities_in_country_cp, :get_legal_advice, :what_you_need_to_do_affirmation, :appointment_for_affidavit_norway, "appointment_links.same_sex.norway", :partner_needs_affirmation, :legalisation_and_translation, :affirmation_os_translation_in_local_language_text, :divorce_proof_cp, :partner_probably_needs_affirmation, :fee_table_affirmation_55, :link_to_consular_fees, :pay_by_visas_or_mastercard]
    end
  end

  context "Seychelles" do
    should "lead to outcome_ss_marriage for same sex marriages" do
      worldwide_api_has_organisations_for_location('seychelles', read_fixture_file('worldwide/seychelles_organisations.json'))
      add_response 'seychelles'
      add_response 'ceremony_country'
      add_response 'partner_local'
      add_response 'same_sex'
      assert_current_node :outcome_ss_marriage
      assert_phrase_list :ss_ceremony_body, [:able_to_ss_marriage, :contact_embassy_or_consulate, :embassies_data, :documents_needed_21_days_residency, :documents_needed_ss_not_british, :what_to_do_ss_marriage, :will_display_in_14_days, :no_objection_in_14_days_ss_marriage, :provide_two_witnesses_ss_marriage, :ss_marriage_footnote, :partner_naturalisation_in_uk, :fees_table_ss_marriage_alt, :link_to_consular_fees, :pay_by_cash_or_credit_card_no_cheque]
    end
  end

  context "Kyrgyzstan" do
    should "lead to the CNI outcome with a suggestion to post notice in Almaty, Kazakhstan" do
      worldwide_api_has_no_organisations_for_location('kyrgyzstan')
      add_response 'kyrgyzstan'
      add_response 'ceremony_country'
      add_response 'partner_british'
      add_response 'opposite_sex'
      assert_current_node :outcome_os_consular_cni

      assert_phrase_list :consular_cni_os_start,  [:contact_local_authorities_in_country_marriage, :get_legal_advice, :what_you_need_to_do, :you_may_be_asked_for_cni, :consular_cni_os_giving_notice_in_ceremony_country, :living_in_ceremony_country_3_days, :kazakhstan_os_local_resident, "appointment_links.opposite_sex.kyrgyzstan", :required_supporting_documents_notary_public, :consular_cni_os_not_uk_resident_ceremony_not_germany, :evidence_if_divorced_outside_uk, :download_and_fill_notice_and_affidavit_but_not_sign, :consular_cni_os_foreign_resident_ceremony_notary_public]
      assert_phrase_list :consular_cni_os_remainder, [:same_cni_process_and_fees_for_partner, :names_on_documents_must_match, :check_if_cni_needs_to_be_legalised, :no_need_to_stay_after_posting_notice, :consular_cni_os_fees_incl_null_osta_oath_consular_letter, :list_of_consular_kazakhstan, :pay_in_local_currency_ceremony_in_kazakhstan]
    end
  end

  context "when appointment links for opposite sex marriage exist" do
    # Kosovo is excluded, because it has a custom outcome
    (OS_COUNTRIES_WITH_APPOINTMENTS - ['kosovo', 'laos']).each do |country|
      should "countain an appointment link in the outcome for #{country.titleize}" do
        worldwide_api_has_no_organisations_for_location(country)
        add_response country
        add_response 'ceremony_country'
        add_response 'partner_local'
        add_response 'opposite_sex'

        assert current_state.current_node.to_s.include?('outcome'), "Expected to have reached an outcome node, but is at #{current_state.current_node}"
        assert_phrase_lists_include "appointment_links.opposite_sex.#{country}"
      end
    end
  end

  context "when appointment links for same sex marriage exist" do
    SS_COUNTRIES_WITH_APPOINTMENTS.each do |country|
      should "countain an appointment link in the outcome for #{country.titleize}" do
        worldwide_api_has_no_organisations_for_location(country)
        add_response country
        add_response 'ceremony_country'
        add_response 'partner_british'
        add_response 'same_sex'

        assert current_state.current_node.to_s.include?('outcome'), "Expected to have reached an outcome node, but is at #{current_state.current_node}"
        assert_phrase_lists_include "appointment_links.same_sex.#{country}"
      end
    end
  end
end
