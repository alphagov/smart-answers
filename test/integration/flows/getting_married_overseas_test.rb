# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class GettingMarriedOverseasTest < ActiveSupport::TestCase
	include FlowTestHelper
	
	setup do
		setup_for_testing_flow 'getting-married-overseas'
  	end
  	#Q1
  	should "ask what sex is your partner?" do
		assert_current_node :partner_opposite_or_same_sex?
	end
	context "answer opposite sex" do
		setup do
			add_response 'marriage'
		end
		should "ask which country you want the ceremony to take place in" do
			assert_current_node :country_ceremony_to_take_place_in?
			assert_state_variable :marriage_type, 'marriage'
		end
		context "ceremony is in UK" do
			setup do
				add_response 'united-kingdom'
			end
			should "go to UK result" do
				assert_current_node :outcome_uk
			end
		end
		context "ceremony is outside UK" do
			setup do
				add_response 'australia'
			end
			should "ask your country of residence" do
				assert_current_node :where_are_you_legally_resident?
				assert_state_variable :country_ceremony, 'australia'
				assert_state_variable :country_name, 'Australia'
			end
		
			context "you are a UK resident" do
				setup do
					add_response 'uk_resident'
				end
				should "go to your partner's residency question" do
					assert_current_node :partner_citizenship?
					assert_state_variable :country_ceremony, 'australia'
					assert_state_variable :country_of_residence, 'uk_resident'
				end
				should "give outcome of commonwealth marriage with a local partner" do
					add_response 'partner_local'
					assert_phrase_list :commonwealth_residency, [:commonwealth_uk_resident]
					assert_state_variable :embassy_address, "British High Commission Canberra
Consular Section\nCommonwealth Avenue\nYarralumla\nACT 2600"
					assert_state_variable :embassy_details, "British High Commission Canberra
Consular Section\nCommonwealth Avenue\nYarralumla\nACT 2600\n(+61) (0) 2 6270 6666\nApr-Oct: 2300-0500 (GMT) 0900-1400 (Local)\nNov-Mar: 2200-0400 (GMT) 0900-1400 (Local)"
					assert_current_node :outcome_marriage_commonwealth
				end
			end	
			context "you are a local resident" do
				setup do
					add_response 'local_resident'
				end
				should "go to your partner's residency question" do
					assert_current_node :partner_citizenship?
					assert_state_variable :country_ceremony, 'australia'
					assert_state_variable :country_of_residence, 'local_resident'
				end
				should "give outcome of commonwealth marriage with a local partner" do
					add_response 'partner_local'
					assert_phrase_list :commonwealth_residency, [:commonwealth_local_resident]
          assert_state_variable :embassy_address, "British High Commission Canberra
Consular Section\nCommonwealth Avenue\nYarralumla\nACT 2600"
          assert_state_variable :embassy_details, "British High Commission Canberra
Consular Section\nCommonwealth Avenue\nYarralumla\nACT 2600\n(+61) (0) 2 6270 6666\nApr-Oct: 2300-0500 (GMT) 0900-1400 (Local)\nNov-Mar: 2200-0400 (GMT) 0900-1400 (Local)"
          assert_current_node :outcome_marriage_commonwealth
				end	
			end
			context "you are a resident of another country" do
				setup do
					add_response 'other_resident'
				end
				should "go to your partner's residency question" do
					assert_current_node :partner_citizenship?
					assert_state_variable :country_ceremony, 'australia'
					assert_state_variable :country_of_residence, 'other_resident'
				end
				should "give outcome of commonwealth marriage with a local partner" do
					add_response 'partner_irish'
					assert_phrase_list :commonwealth_residency, [:commonwealth_other_resident]
          assert_state_variable :embassy_address, "British High Commission Canberra
Consular Section\nCommonwealth Avenue\nYarralumla\nACT 2600"
          assert_state_variable :embassy_details, "British High Commission Canberra
Consular Section\nCommonwealth Avenue\nYarralumla\nACT 2600\n(+61) (0) 2 6270 6666\nApr-Oct: 2300-0500 (GMT) 0900-1400 (Local)\nNov-Mar: 2200-0400 (GMT) 0900-1400 (Local)"
          assert_current_node :outcome_marriage_commonwealth
				end	
			end			
		end
		context "ceremony is in cyprus and partner is a local" do
			setup do
				add_response 'cyprus'
			end
			should "go to output with variables" do
				add_response 'local_resident'
				add_response 'partner_irish'
				assert_current_node :outcome_marriage_commonwealth
				assert_state_variable :country_ceremony, 'cyprus'
        assert_state_variable :country_of_residence, 'local_resident'
        assert_state_variable :partner_citizen_of, 'partner_irish'
				assert_phrase_list :commonwealth_just_cyprus, [:commonwealth_cypus]
				assert_phrase_list :commonwealth_residency, [:commonwealth_local_resident]
				assert_phrase_list :commonwealth_naturalisation, [:commonwealth_partner_naturalisation]
			end
		end
		context "ceremony is in cyprus and partner is a uk resident" do
			setup do
				add_response 'cyprus'
			end
			should "go to output with variables" do
				add_response 'uk_resident'
				add_response 'partner_irish'
				assert_current_node :outcome_marriage_commonwealth
				assert_state_variable :country_ceremony, 'cyprus'
				assert_phrase_list :commonwealth_residency, [:commonwealth_uk_resident]
				assert_phrase_list :commonwealth_naturalisation, [:commonwealth_partner_naturalisation]
			end
		end
	end
	context "answer same sex" do
		setup do
			add_response 'cp'
		end
		should "ask which country you want the ceremony to take place in" do
			assert_current_node :country_ceremony_to_take_place_in?
			assert_state_variable :marriage_type, 'cp'
		end
		context "ceremony is in UK" do
			setup do
				add_response 'united-kingdom'
			end
			should "go to UK result" do
				assert_current_node :outcome_uk
			end
		end
		context "ceremony is outside UK" do
			setup do
				add_response 'australia'
			end
			should "ask your country of residence" do
				assert_current_node :where_are_you_legally_resident?
				assert_state_variable :country_ceremony, 'australia'
				assert_state_variable :country_name, 'Australia'
			end
			context "you are a UK resident" do
				setup do
					add_response 'uk_resident'
				end
				should "go to your partner's residency question" do
					assert_current_node :partner_citizenship?
					assert_state_variable :country_ceremony, 'australia'
					assert_state_variable :country_of_residence, 'uk_resident'
				end
				should "give outcome of commonwealth marriage with a local partner" do
					add_response 'partner_local'
					assert_phrase_list :australia_cp_naturalisation, [:australia_cp_partner_naturalisation]
					assert_current_node :outcome_cp_australia
				end
			end	
			context "you are a local resident" do
				setup do
					add_response 'local_resident'
				end
				should "go to your partner's residency question" do
					assert_current_node :partner_citizenship?
					assert_state_variable :country_ceremony, 'australia'
					assert_state_variable :country_of_residence, 'local_resident'
				end
				should "give outcome of commonwealth marriage with a local partner" do
					add_response 'partner_local'
					assert_phrase_list :australia_cp_naturalisation, [:australia_cp_partner_naturalisation]
          			assert_current_node :outcome_cp_australia
				end	
			end
			context "you are a resident of another country" do
				setup do
					add_response 'other_resident'
				end
				should "go to your partner's residency question" do
					assert_current_node :partner_citizenship?
					assert_state_variable :country_ceremony, 'australia'
					assert_state_variable :country_of_residence, 'other_resident'
				end
				should "give outcome of commonwealth marriage with a local partner" do
					add_response 'partner_irish'
					assert_phrase_list :australia_cp_naturalisation, [:australia_cp_partner_naturalisation]
          			assert_current_node :outcome_cp_australia
				end	
			end			
		end
	end






#Test for country-specific outcomes

  context "marriage in south africa" do
    should "give south africa outcome" do
      add_response 'marriage'
      add_response 'south-africa'
      add_response 'uk_resident'
      add_response 'partner_other'
      assert_state_variable :country_ceremony, 'south-africa'
      assert_state_variable :country_of_residence, 'uk_resident'
      assert_phrase_list :commonwealth_country_variants, [:commonwealth_south_africa]
      assert_phrase_list :commonwealth_naturalisation, [:commonwealth_partner_naturalisation]
      assert_current_node :outcome_marriage_commonwealth
    end
  end
  context "marriage in india" do
    should "give india outcome" do
      add_response 'marriage'
      add_response 'india'
      add_response 'uk_resident'
      add_response 'partner_irish'
      assert_state_variable :country_ceremony, 'india'
      assert_state_variable :country_of_residence, 'uk_resident'
      assert_phrase_list :commonwealth_country_variants, [:commonwealth_india]
      assert_phrase_list :commonwealth_naturalisation, [:commonwealth_partner_naturalisation]
      assert_current_node :outcome_marriage_commonwealth
    end
  end
  context "marriage in malaysia" do
    should "give malaysia outcome" do
      add_response 'marriage'
      add_response 'malaysia'
      add_response 'uk_resident'
      add_response 'partner_british'
      assert_state_variable :country_ceremony, 'malaysia'
      assert_state_variable :country_of_residence, 'uk_resident'
      assert_phrase_list :commonwealth_country_variants, [:commonwealth_malaysia]
      assert_current_node :outcome_marriage_commonwealth
    end
  end
  context "marriage in malta" do
    should "give malta outcome" do
      add_response 'marriage'
      add_response 'malta'
      add_response 'local_resident'
      add_response 'partner_irish'
      assert_state_variable :country_ceremony, 'malta'
      assert_state_variable :country_of_residence, 'local_resident'
      assert_phrase_list :commonwealth_country_variants, [:commonwealth_malta]
      assert_phrase_list :commonwealth_naturalisation, [:commonwealth_partner_naturalisation]
      assert_current_node :outcome_marriage_commonwealth
    end
  end
  context "marriage in new zealand" do
    should "give new zealand outcome" do
      add_response 'marriage'
      add_response 'new-zealand'
      add_response 'other_resident'
      add_response 'partner_local'
      assert_state_variable :country_ceremony, 'new-zealand'
      assert_state_variable :country_of_residence, 'other_resident'
      assert_phrase_list :commonwealth_country_variants, [:commonwealth_new_zealand]
      assert_phrase_list :commonwealth_naturalisation, [:commonwealth_partner_naturalisation]
      assert_current_node :outcome_marriage_commonwealth
    end
  end
  context "marriage in sinapore" do
    should "give singapore outcome" do
      add_response 'marriage'
      add_response 'singapore'
      add_response 'local_resident'
      add_response 'partner_local'
      assert_state_variable :country_ceremony, 'singapore'
      assert_state_variable :country_of_residence, 'local_resident'
      assert_phrase_list :commonwealth_country_variants, [:commonwealth_singapore]
      assert_phrase_list :commonwealth_naturalisation, [:commonwealth_partner_naturalisation]
      assert_current_node :outcome_marriage_commonwealth
    end
  end
  context "marriage in brunei" do
    should "give brunei outcome" do
      add_response 'marriage'
      add_response 'brunei'
      add_response 'uk_resident'
      add_response 'partner_other'
      assert_state_variable :country_ceremony, 'brunei'
      assert_state_variable :country_of_residence, 'uk_resident'
      assert_phrase_list :commonwealth_country_variants, [:commonwealth_brunei]
      assert_current_node :outcome_marriage_commonwealth
    end
  end
  context "marriage in british overseas territory" do
    should "give anguilla outcome" do
      add_response 'marriage'
      add_response 'anguilla'
      add_response 'uk_resident'
      add_response 'partner_irish'
      assert_state_variable :country_ceremony, 'anguilla'
      assert_state_variable :country_of_residence, 'uk_resident'
      assert_phrase_list :british_overseas_territory_marriage_variant, [:british_overseas_territory_text]
      assert_phrase_list :british_overseas_territory_residency_variant, [:british_overseas_territory_not_local_resident]
      assert_phrase_list :british_overseas_territory_naturalisation, [:british_overseas_territory_partner_naturalisation]
      assert_current_node :outcome_marriage_bot
    end
  end

end