# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class MarriageOverseasTest < ActiveSupport::TestCase
	include FlowTestHelper
	
	setup do
		setup_for_testing_flow 'marriage-overseas'
  	end
  	
  	should "which country you want the ceremony to take place in" do
		assert_current_node :country_of_ceremony?
	end
	context "ceremony in ireland" do
		setup do
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
			end
		end
	end

	
	context "ceremony is outside ireland" do
		setup do
			add_response 'bahamas'
		end
		should "ask your country of residence" do
			assert_current_node :legal_residency?
			assert_state_variable :ceremony_country, 'bahamas'
			assert_state_variable :ceremony_country_name, 'Bahamas'
		end

		context "resident in UK" do
			setup do
				add_response 'uk'
			end
			should "go to uk residency region question" do
				assert_current_node :residency_uk?
				assert_state_variable :ceremony_country, 'bahamas'
				assert_state_variable :ceremony_country_name, 'Bahamas'
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
							assert_phrase_list :embassy_details, [:embassy_details_all]				
							assert_phrase_list :commonwealth_os_zimbabwe_variant, [:uk_resident_os_ceremony_not_zimbabwe]
						end
					end
					context "same sex partner" do
						setup do
							add_response 'same_sex'
						end
						should "give outcome same sex commonwealth" do
							assert_current_node :outcome_ss_commonwealth
							assert_phrase_list :embassy_details, [:embassy_details_all]
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
							assert_phrase_list :embassy_details, [:embassy_details_all]
							assert_phrase_list :commonwealth_os_zimbabwe_variant, [:other_resident_os_ceremony_not_zimbabwe]
							assert_phrase_list :commonwealth_os_naturalisation_variant, [:commonwealth_os_naturalisation]
						end
					end
					context "same sex partner" do
						setup do
							add_response 'same_sex'
						end
						should "give outcome same sex commonwealth" do
							assert_current_node :outcome_ss_commonwealth
							assert_phrase_list :embassy_details, [:embassy_details_all]				
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
			add_response 'australia'
			add_response 'other'
			add_response 'australia'
			add_response 'partner_british'
			add_response 'opposite_sex'
		end
		should "go to commonwealth os outcome" do
			assert_current_node :outcome_os_commonwealth
			assert_phrase_list :commonwealth_os_zimbabwe_variant, [:local_resident_os_ceremony_not_zimbabwe]
		end
	end
	context "uk resident but ceremony not in zimbabwe" do
		setup do
			add_response 'bahamas'
			add_response 'uk'
			add_response 'uk_england'
			add_response 'partner_british'
			add_response 'opposite_sex'
		end
		should "go to commonwealth os outcome" do
			assert_current_node :outcome_os_commonwealth
			assert_phrase_list :commonwealth_os_zimbabwe_variant, [:uk_resident_os_ceremony_not_zimbabwe]
		end
	end
	context "other resident but ceremony not in zimbabwe" do
		setup do
			add_response 'australia'
			add_response 'other'
			add_response 'canada'
			add_response 'partner_british'
			add_response 'opposite_sex'
		end
		should "go to commonwealth os outcome" do
			assert_current_node :outcome_os_commonwealth
			assert_phrase_list :commonwealth_os_zimbabwe_variant, [:other_resident_os_ceremony_not_zimbabwe]
		end
	end
	context "uk resident ceremony in zimbabwe" do
		setup do
			add_response 'zimbabwe'
			add_response 'uk'
			add_response 'uk_wales'
			add_response 'partner_british'
			add_response 'opposite_sex'
		end
		should "go to commonwealth os outcome" do
			assert_current_node :outcome_os_commonwealth
			assert_phrase_list :commonwealth_os_zimbabwe_variant, [:uk_resident_os_ceremony_zimbabwe]
		end
	end
# testing for other commonwealth countries
	context "uk resident ceremony in south-africa" do
		setup do
			add_response 'south-africa'
			add_response 'uk'
			add_response 'uk_wales'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to commonwealth os outcome" do
			assert_current_node :outcome_os_commonwealth
			assert_phrase_list :commonwealth_os_zimbabwe_variant, [:uk_resident_os_ceremony_not_zimbabwe]
			assert_phrase_list :commonwealth_os_other_countries_variant, [:commonwealth_os_other_countries_south_africe]
			assert_phrase_list :commonwealth_os_naturalisation_variant, [:commonwealth_os_naturalisation]
		end
	end
	context "resident in cyprus, ceremony in cyprus" do
		setup do
			add_response 'cyprus'
			add_response 'other'
			add_response 'cyprus'
			add_response 'partner_irish'
			add_response 'opposite_sex'
		end
		should "go to commonwealth os outcome" do
			assert_current_node :outcome_os_commonwealth
			assert_phrase_list :commonwealth_os_zimbabwe_variant, [:local_resident_os_ceremony_not_zimbabwe]
			assert_phrase_list :commonwealth_os_other_countries_variant, [:commonwealth_os_other_countries_cyprus]
			assert_phrase_list :commonwealth_os_naturalisation_variant, [:commonwealth_os_naturalisation]
		end
	end
# testing for british overseas territories
	context "uk resident ceremony in british indian ocean territory" do
		setup do
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
			add_response 'anguilla'
			add_response 'other'
			add_response 'anguilla'
			add_response 'partner_irish'
			add_response 'opposite_sex'
		end
		should "go to bos os outcome" do
			assert_current_node :outcome_os_bot
			assert_phrase_list :bot_outcome, [:bot_os_ceremony_non_biot, :bot_os_local_resident, :bot_os_naturalisation]
		end
	end
# testing for consular cni countries
	context "uk resident, ceremony in estonia, partner british" do
		setup do
			add_response 'estonia'
			add_response 'uk'
			add_response 'uk_wales'
			add_response 'partner_british'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:uk_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:uk_resident_os_consular_cni_two]
		end
	end
	context "resident in estonia, ceremony in estonia" do
		setup do
			add_response 'estonia'
			add_response 'other'
			add_response 'estonia'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:local_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
		end
	end
	context "resident in canada, ceremony in estonia" do
		setup do
			add_response 'estonia'
			add_response 'other'
			add_response 'canada'
			add_response 'partner_other'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
		end
	end
	context "local resident, ceremony in jordan, partner british" do
		setup do
			add_response 'jordan'
			add_response 'other'
			add_response 'jordan'
			add_response 'partner_british'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:local_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_gulf_states_variant, [:gulf_states_os_consular_cni]
			assert_phrase_list :consular_cni_os_gulf_states_local_resident_not_irish, [:gulf_states_os_consular_cni_local_resident_partner_not_irish]
		end
	end
# variants for italy
	context "ceremony in italy, resident in commonwealth country" do
		setup do
			add_response 'italy'
			add_response 'other'
			add_response 'canada'
			add_response 'partner_british'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_italy_variant, [:consular_cni_os_italy_scenario_eight]
		end
	end
	context "ceremony in italy, resident in 'foreign' country, partner british" do
		setup do
			add_response 'italy'
			add_response 'other'
			add_response 'belgium'
			add_response 'partner_british'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_italy_variant, [:consular_cni_os_italy_scenario_six]
		end
	end
	context "ceremony in italy, resident in 'foreign' country, partner non-british" do
		setup do
			add_response 'italy'
			add_response 'other'
			add_response 'belgium'
			add_response 'partner_irish'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_italy_variant, [:consular_cni_os_italy_scenario_seven]
		end
	end
	context "ceremony in italy, resident in ireland, partner non-british" do
		setup do
			add_response 'italy'
			add_response 'other'
			add_response 'ireland'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_italy_variant, [:consular_cni_os_italy_scenario_nine]
		end
	end
	context "ceremony in italy, resident in uk, partner british" do
		setup do
			add_response 'italy'
			add_response 'uk'
			add_response 'uk_wales'
			add_response 'partner_british'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:uk_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:uk_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_italy_variant, [:consular_cni_os_italy_scenario_one]
		end
	end
	context "ceremony in italy, resident in uk, partner non-british" do
		setup do
			add_response 'italy'
			add_response 'uk'
			add_response 'uk_wales'
			add_response 'partner_other'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:uk_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:uk_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_italy_variant, [:consular_cni_os_italy_scenario_two_a]
		end
	end
	context "ceremony in italy, resident in uk (scotland), partner non-british" do
		setup do
			add_response 'italy'
			add_response 'uk'
			add_response 'uk_scotland'
			add_response 'partner_irish'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:uk_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:uk_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_italy_variant, [:consular_cni_os_italy_scenario_two_b]
		end
	end
	context "ceremony in italy, resident in italy, partner british" do
		setup do
			add_response 'italy'
			add_response 'other'
			add_response 'italy'
			add_response 'partner_british'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:local_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_italy_variant, [:consular_cni_os_italy_scenario_three]		
		end
	end
	context "ceremony in italy, resident in italy, partner non-british" do
		setup do
			add_response 'italy'
			add_response 'other'
			add_response 'italy'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:local_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_italy_variant, [:consular_cni_os_italy_scenario_four]		
		end
	end
	context "ceremony in italy, resident in denmark, partner non-british" do
		setup do
			add_response 'italy'
			add_response 'other'
			add_response 'italy'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:local_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
		end
	end
#variants for denmark
	context "ceremony in denmark, resident in canada, partner irish" do
		setup do
			add_response 'denmark'
			add_response 'other'
			add_response 'canada'
			add_response 'partner_irish'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_denmark_variant, [:consular_cni_os_denmark]		
		end
	end
#variants for germany
	context "ceremony in germany, resident in germany, partner irish" do
		setup do
			add_response 'germany'
			add_response 'other'
			add_response 'germany'
			add_response 'partner_irish'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:local_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_germany_local_residency_variant, [:consular_cni_os_german_resident]		
		end
	end
#variants for italy (again)
	context "ceremony in italy, resident in isle of man, partner non-british" do
		setup do
			add_response 'italy'
			add_response 'uk'
			add_response 'uk_iom'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:uk_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:uk_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_italy_variant_two,[:consular_cni_os_italy_iom_ci_partner_not_irish]
		end
	end
#variants for uk residency (again)
	context "ceremony in turkey, resident in isle of man, partner non-irish" do
		setup do
			add_response 'turkey'
			add_response 'uk'
			add_response 'uk_iom'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:uk_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:uk_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_residency_variant_three, [:uk_resident_partner_not_irish_os_consular_cni_three]
		end
	end
	context "ceremony in turkey, resident in northern ireland, partner irish" do
		setup do
			add_response 'turkey'
			add_response 'uk'
			add_response 'uk_ni'
			add_response 'partner_irish'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:uk_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:uk_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_residency_variant_three, [:scotland_ni_resident_partner_irish_os_consular_cni_three]
		end
	end
#variants for italy, uk regions
	context "ceremony in italy, resident in northern ireland, partner irish" do
		setup do
			add_response 'italy'
			add_response 'uk'
			add_response 'uk_ni'
			add_response 'partner_irish'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:uk_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:uk_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_residency_variant_three, [:scotland_ni_resident_partner_irish_os_consular_cni_three]
			assert_phrase_list :consular_cni_os_italy_variant_three, [:consular_cni_os_scotland_or_ni_partner_irish_or_partner_not_irish_three]
		end
	end
	context "ceremony in italy, resident in northern ireland, partner local" do
		setup do
			add_response 'italy'
			add_response 'uk'
			add_response 'uk_england'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:uk_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:uk_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_residency_variant_three, [:uk_resident_partner_not_irish_os_consular_cni_three]
			assert_phrase_list :consular_cni_os_italy_variant_three, [:consular_cni_os_scotland_or_ni_partner_irish_or_partner_not_irish_three]
		end
	end
	context "ceremony in italy, resident in ci, partner irish" do
		setup do
			add_response 'italy'
			add_response 'uk'
			add_response 'uk_ci'
			add_response 'partner_irish'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:uk_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:uk_resident_os_consular_cni_two]
		end
	end
#variant for england and wales, irish partner - ceremony not italy
	context "ceremony in peru, resident in wales, partner irish" do
		setup do
			add_response 'peru'
			add_response 'uk'
			add_response 'uk_wales'
			add_response 'partner_irish'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:uk_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:uk_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_uk_residency_not_italy_variant, [:consular_cni_os_england_or_wales_resident_not_italy]
		end
	end
#variant for uk resident, ceremony not in italy
	context "ceremony in peru, resident in wales, partner other" do
		setup do
			add_response 'peru'
			add_response 'uk'
			add_response 'uk_wales'
			add_response 'partner_other'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:uk_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:uk_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_residency_variant_three, [:uk_resident_partner_not_irish_os_consular_cni_three]
			assert_phrase_list :consular_cni_os_uk_residency_not_italy_variant_two, [:consular_cni_os_uk_resident_not_italy_two]
		end
	end
#variant for local resident, ceremony not in italy or germany
	context "ceremony in turkey, resident in turkey, partner other" do
		setup do
			add_response 'turkey'
			add_response 'other'
			add_response 'turkey'
			add_response 'partner_other'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:local_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_local_resident_not_italy_or_germany_variant, [:consular_cni_os_local_resident_not_italy_germany, :clickbook_link]

		end
	end
	context "ceremony in portugal, resident in portugal, partner other" do
		setup do
			add_response 'portugal'
			add_response 'other'
			add_response 'portugal'
			add_response 'partner_other'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:local_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_local_resident_not_italy_or_germany_variant, [:consular_cni_os_local_resident_not_italy_germany, :clickbook_links]

		end
	end

#variant for local resident, italy
	context "ceremony in italy, resident in italy, partner other" do
		setup do
			add_response 'italy'
			add_response 'other'
			add_response 'italy'
			add_response 'partner_other'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:local_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_local_resident_italy_variant, [:consular_cni_os_local_resident_italy]
		end
	end
#variant for foreign or commonwealth resident
	context "ceremony in italy, resident in poland, partner other" do
		setup do
			add_response 'italy'
			add_response 'other'
			add_response 'poland'
			add_response 'partner_other'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_foreign_or_commonwealth_resident_variant, [:consular_cni_os_foreign_resident]
		end
	end
	context "ceremony in italy, resident in canada, partner other" do
		setup do
			add_response 'italy'
			add_response 'other'
			add_response 'canada'
			add_response 'partner_other'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_foreign_or_commonwealth_resident_variant, [:consular_cni_os_commonwealth_resident]
		end
	end
#variant for commonwealth resident and british partner
	context "ceremony in switzerland, resident in canada, partner british" do
		setup do
			add_response 'switzerland'
			add_response 'other'
			add_response 'canada'
			add_response 'partner_british'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_foreign_or_commonwealth_resident_variant, [:consular_cni_os_commonwealth_resident]
			assert_phrase_list :consular_cni_os_commonwealth_resident_partner_british_variant, [:consular_cni_os_commonwealth_resident_british_partner]
		end
	end
#variants for commonwealth or ireland resident
	context "ceremony in switzerland, resident in canada, partner british" do
		setup do
			add_response 'switzerland'
			add_response 'other'
			add_response 'canada'
			add_response 'partner_british'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_foreign_or_commonwealth_resident_variant, [:consular_cni_os_commonwealth_resident]
			assert_phrase_list :consular_cni_os_commonwealth_resident_partner_british_variant, [:consular_cni_os_commonwealth_resident_british_partner]
			assert_phrase_list :consular_cni_os_commowealth_or_ireland_resident_variable, [:consular_cni_os_commonwealth_resident_two]
		end
	end
	context "ceremony in switzerland, resident in ireland, partner british" do
		setup do
			add_response 'switzerland'
			add_response 'other'
			add_response 'ireland'
			add_response 'partner_british'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_commowealth_or_ireland_resident_variable, [:consular_cni_os_ireland_resident]
		end
	end
#variants for ireland residents
	context "ceremony in switzerland, resident in ireland, partner british" do
		setup do
			add_response 'switzerland'
			add_response 'other'
			add_response 'ireland'
			add_response 'partner_british'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_commowealth_or_ireland_resident_variable, [:consular_cni_os_ireland_resident]
			assert_phrase_list :consular_cni_os_ireland_resident_partner_british_variant, [:consular_cni_os_ireland_resident_british_partner]
		end
	end
	context "ceremony in switzerland, resident in ireland, partner other" do
		setup do
			add_response 'switzerland'
			add_response 'other'
			add_response 'ireland'
			add_response 'partner_other'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_commowealth_or_ireland_resident_variable, [:consular_cni_os_ireland_resident]
			assert_phrase_list :consular_cni_os_ireland_residency_variant, [:consular_cni_os_ireland_resident]
		end
	end
#variants for commonwealth or ireland residents
	context "ceremony in switzerland, resident in australia, partner british" do
		setup do
			add_response 'switzerland'
			add_response 'other'
			add_response 'australia'
			add_response 'partner_british'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_commowealth_or_ireland_resident_variable, [:consular_cni_os_commonwealth_resident_two]
			assert_phrase_list :consular_cni_os_commonwealth_ireland_resident_british_partner_variant, [:consular_cni_os_commonwealth_or_ireland_resident_british_partner]
		end
	end
	context "ceremony in switzerland, resident in australia, partner other" do
		setup do
			add_response 'switzerland'
			add_response 'other'
			add_response 'australia'
			add_response 'partner_other'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_commowealth_or_ireland_resident_variable, [:consular_cni_os_commonwealth_resident_two]
			assert_phrase_list :consular_cni_os_commonwealth_ireland_resident_british_partner_variant, [:consular_cni_os_commonwealth_or_ireland_resident_non_british_partner]
		end
	end
#variant for local residents (not germany or spain)
	context "ceremony in switzerland, resident in switzerland, partner other" do
		setup do
			add_response 'switzerland'
			add_response 'other'
			add_response 'switzerland'
			add_response 'partner_other'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:local_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_local_foreign_residency_spain_germany_variant, [:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident]
		end
	end
#variant for foreign resident
	context "ceremony in turkey, resident in switzerland, partner other" do
		setup do
			add_response 'turkey'
			add_response 'other'
			add_response 'switzerland'
			add_response 'partner_other'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_local_foreign_residency_spain_germany_variant, [:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident]
		end
	end
#variant for local resident - spain
	context "ceremony in spain, resident in spain, partner other" do
		setup do
			add_response 'spain'
			add_response 'other'
			add_response 'spain'
			add_response 'partner_other'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:local_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_spain_variant, [:spain_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_local_foreign_residency_spain_germany_variant, [:consular_cni_variant_local_resident_spain]
		end
	end
#variant for local residents (not germany or spain) again
	context "ceremony in poland, resident in poland, partner local" do
		setup do
			add_response 'poland'
			add_response 'other'
			add_response 'poland'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:local_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_local_foreign_residency_spain_germany_variant, [:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident]
			assert_phrase_list :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residents_variant, [:consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency]
		end
	end
#variant for local resident (not germany or spain) or foreign residents
	context "ceremony in turkey, resident in switzerland, partner local" do
		setup do
			add_response 'turkey'
			add_response 'other'
			add_response 'switzerland'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_local_foreign_residency_spain_germany_variant, [:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident]
			assert_phrase_list :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residents_variant, [:consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency]
			assert_phrase_list :consular_cni_os_local_foreign_residency_spain_germany_variant_two, [:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two]
		end
	end
	context "ceremony in turkey, resident in turkey, partner local" do
		setup do
			add_response 'turkey'
			add_response 'other'
			add_response 'turkey'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:local_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_local_foreign_residency_spain_germany_variant, [:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident]
			assert_phrase_list :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residents_variant, [:consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency]
			assert_phrase_list :consular_cni_os_local_foreign_residency_spain_germany_variant_two, [:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two]
		end
	end
#variant for foreign resident, ceremony not in italy AND foreign resident, ceremony in italy
	context "ceremony in turkey, resident in poland, partner local" do
		setup do
			add_response 'turkey'
			add_response 'other'
			add_response 'poland'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_local_foreign_residency_spain_germany_variant, [:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident]
			assert_phrase_list :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residents_variant, [:consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency]
			assert_phrase_list :consular_cni_os_local_foreign_residency_spain_germany_variant_two, [:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two]
		end
	end
	context "ceremony in italy, resident in poland, partner local" do
		setup do
			add_response 'italy'
			add_response 'other'
			add_response 'poland'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_local_foreign_residency_spain_germany_variant, [:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident]
			assert_phrase_list :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residents_variant, [:consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency]
			assert_phrase_list :consular_cni_os_local_foreign_residency_spain_germany_variant_two, [:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two]
			assert_phrase_list :consular_cni_os_foreign_resident_not_italy_variant, [:consular_cni_os_foreign_resident_ceremony_italy]
		end
	end
#variant for commonwealth resident, ceremony not in italy AND ireland resident , ceremony not in italy
	context "ceremony in turkey, resident in canada, partner local" do
		setup do
			add_response 'turkey'
			add_response 'other'
			add_response 'canada'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residents_variant, [:consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency]
			assert_phrase_list :consular_cni_os_foreign_resident_not_italy_variant, [:consular_cni_os_foreign_resident_ceremony_not_italy]
			assert_phrase_list :consular_cni_os_commonwealth_resident_ceremony_not_italy_variant, [:consular_cni_os_commonwealth_resident_ceremony_not_italy] 
		end
	end
	context "ceremony in turkey, resident in ireland, partner local" do
		setup do
			add_response 'turkey'
			add_response 'other'
			add_response 'ireland'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_local_foreign_residency_spain_germany_variant, [:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident]
			assert_phrase_list :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residents_variant, [:consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency]
			assert_phrase_list :consular_cni_os_local_foreign_residency_spain_germany_variant_two, [:consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two]
			assert_phrase_list :consular_cni_os_foreign_resident_not_italy_variant, [:consular_cni_os_foreign_resident_ceremony_not_italy]
			assert_phrase_list :consular_cni_os_commonwealth_resident_ceremony_not_italy_variant, [:consular_cni_os_ireland_resident_ceremony_not_italy] 
		end
	end
#testing for commonwealth resident and ceremony in italy
	context "ceremony in italy, resident in canada, partner local" do
		setup do
			add_response 'italy'
			add_response 'other'
			add_response 'canada'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residents_variant, [:consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency]
			assert_phrase_list :counsular_cni_os_remainder, [:consular_cni_os_commonwealth_resident_ceremony_italy, :consular_cni_os_ceremony_italy]
		end
	end
#testing for ireland resident and ceremony in italy
	context "ceremony in italy, resident in canada, partner local" do
		setup do
			add_response 'italy'
			add_response 'other'
			add_response 'ireland'
			add_response 'partner_local'
			add_response 'opposite_sex'
		end
		should "go to consular cni os outcome" do
			assert_current_node :outcome_os_consular_cni
			assert_phrase_list :consular_cni_os_residency_variant, [:other_resident_os_consular_cni]
			assert_phrase_list :consular_cni_os_residency_variant_two, [:other_resident_os_consular_cni_two]
			assert_phrase_list :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residents_variant, [:consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency]
			assert_phrase_list :counsular_cni_os_remainder, [:consular_cni_os_ireland_resident_ceremony_italy, :consular_cni_os_ceremony_italy]
		end
	end





end