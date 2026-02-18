module CheckUkVisaFlowTestHelper
  def test_estonia_latvia_alien_outcome_guidance
    %w[estonia latvia].each do |country|
      should "render visa country guidance when an alien #{country} passport is held" do
        add_responses what_passport_do_you_have?: country,
                      dual_british_or_irish_citizenship?: "no",
                      what_sort_of_passport?: "alien"
        assert_rendered_outcome text: "You must apply for your visa from the country you’re currently living in."
      end
    end
  end

  def test_visa_count(passport_country, expected_count)
    should "render outcome of #{expected_count} visas available with correct plural form for passport country #{passport_country}" do
      plural_form = "visa".pluralize(expected_count)

      add_responses what_passport_do_you_have?: passport_country,
                    dual_british_or_irish_citizenship?: "no"
      assert_rendered_outcome text: "Based on your answers, you might be eligible for #{expected_count} #{plural_form}."
    end
  end

  def test_stateless_or_refugee_outcome_guidance
    should "render visa country guidance when passport country is stateless-or-refugee" do
      add_responses what_passport_do_you_have?: "stateless-or-refugee",
                    dual_british_or_irish_citizenship?: "no"
      assert_rendered_outcome text: "You must apply for your visa from the country you’re originally from or currently living in."
    end
  end

  def test_bno_outcome_guidance
    should "render visa country guidance when passport country is in the BNO list" do
      add_responses what_passport_do_you_have?: "british-national-overseas",
                    dual_british_or_irish_citizenship?: "no"
      assert_rendered_outcome text: "If you have British national (overseas) status"
    end
  end

  def test_country_in_youth_mobility_outcome_guidance
    should "render visa country guidance when passport country is in the Youth Mobility scheme" do
      add_responses what_passport_do_you_have?: "canada",
                    dual_british_or_irish_citizenship?: "no"
      assert_rendered_outcome text: "If you’re aged 18 to 30"
    end
  end

  def test_country_in_uk_ancestry_visa
    should "render visa country guidance when passport country is in the UK Ancestry Visa list" do
      add_responses what_passport_do_you_have?: "canada",
                    dual_british_or_irish_citizenship?: "no"
      assert_rendered_outcome text: "If one of your grandparents was born in the UK"
    end
  end

  def test_country_in_uk_ancestry_visa_with_business_information
    should "render visa country guidance with business information when passport country is in the UK Ancestry Visa list" do
      add_responses what_passport_do_you_have?: "canada",
                    dual_british_or_irish_citizenship?: "no"
      assert_rendered_outcome text: "If one of your grandparents was born in the UK"
      assert_rendered_outcome text: "start a business"
    end
  end

  def test_india_young_professionals_visa_guidance
    should "render visa guidance when passport country is India" do
      add_responses what_passport_do_you_have?: "india",
                    dual_british_or_irish_citizenship?: "no"
      assert_rendered_outcome text: "India Young Professionals Scheme visa"
    end
  end

  def test_shared_purpose_of_visit_next_nodes
    should "have a next node of staying_for_how_long? for a 'study' response" do
      assert_next_node :staying_for_how_long?, for_response: "study"
    end

    should "have a next node of staying_for_how_long? for a 'work' response" do
      assert_next_node :staying_for_how_long?, for_response: "work"
    end

    should "have a next node of staying_for_how_long? for a 'diplomatic' response" do
      assert_next_node :outcome_diplomatic_business, for_response: "diplomatic"
    end

    context "for a 'school' response" do
      should "have a next node of outcome_school_electronic_travel_authorisation for electronic travel authorisation country passport" do
        add_responses what_passport_do_you_have?: @electronic_travel_authorisation_country
        assert_next_node :outcome_school_electronic_travel_authorisation, for_response: "school"
      end

      should "have a next node of outcome_school_electronic_travel_authorisation for a Taiwan passport" do
        add_responses what_passport_do_you_have?: "taiwan"
        assert_next_node :outcome_school_electronic_travel_authorisation, for_response: "school"
      end

      should "have a next node of outcome_school_n for a non-visa national passport" do
        add_responses what_passport_do_you_have?: @non_visa_national_country
        assert_next_node :outcome_school_n, for_response: "school"
      end

      should "have a next node of outcome_school_n for a British overseas territory passport" do
        add_responses what_passport_do_you_have?: @british_overseas_territory_country
        assert_next_node :outcome_school_n, for_response: "school"
      end

      should "have a next node of outcome_school_electronic_travel_authorisation for an EEA passport" do
        add_responses what_passport_do_you_have?: @eea_country
        assert_next_node :outcome_school_electronic_travel_authorisation, for_response: "school"
      end

      should "have a next node of outcome_school_y for other passports" do
        add_responses what_passport_do_you_have?: @visa_national_country
        assert_next_node :outcome_school_y, for_response: "school"
      end
    end

    context "for a 'medical' response" do
      should "have a next node of outcome_medical_electronic_travel_authorisation for a electronic travel authorisation country passport" do
        add_responses what_passport_do_you_have?: @electronic_travel_authorisation_country
        assert_next_node :outcome_medical_electronic_travel_authorisation, for_response: "medical"
      end

      should "have a next node of outcome_medical_electronic_travel_authorisation for a Taiwan passport" do
        add_responses what_passport_do_you_have?: "taiwan"
        assert_next_node :outcome_medical_electronic_travel_authorisation, for_response: "medical"
      end

      should "have a next node of outcome_medical_n for a non-visa national passport" do
        add_responses what_passport_do_you_have?: @non_visa_national_country
        assert_next_node :outcome_medical_n, for_response: "medical"
      end

      should "have a next node of outcome_medical_n for a British overseas territory passport" do
        add_responses what_passport_do_you_have?: @british_overseas_territory_country
        assert_next_node :outcome_medical_n, for_response: "medical"
      end

      should "have a next node of outcome_medical_electronic_travel_authorisation for an EEA passport" do
        add_responses what_passport_do_you_have?: @eea_country
        assert_next_node :outcome_medical_electronic_travel_authorisation, for_response: "medical"
      end

      should "have a next node of outcome_medical_y for other passports" do
        add_responses what_passport_do_you_have?: @visa_national_country
        assert_next_node :outcome_medical_y, for_response: "medical"
      end
    end

    context "for a 'tourism' response" do
      should "have a next node of outcome_tourism_requires_electronic_travel_authorisation for electronic travel authorisation country passport" do
        add_responses what_passport_do_you_have?: @electronic_travel_authorisation_country
        assert_next_node :outcome_tourism_electronic_travel_authorisation, for_response: "tourism"
      end

      should "have a next node of outcome_tourism_requires_electronic_travel_authorisation for a Taiwan passport" do
        add_responses what_passport_do_you_have?: "taiwan"
        assert_next_node :outcome_tourism_electronic_travel_authorisation, for_response: "tourism"
      end

      should "have a next node of outcome_tourism_n for a non-visa national passport" do
        add_responses what_passport_do_you_have?: @non_visa_national_country
        assert_next_node :outcome_tourism_n, for_response: "tourism"
      end

      should "have a next node of outcome_tourism_requires_electronic_travel_authorisation for an EEA passport" do
        add_responses what_passport_do_you_have?: @eea_country
        assert_next_node :outcome_tourism_electronic_travel_authorisation, for_response: "tourism"
      end

      should "have a next node of outcome_tourism_n for a British overseas territory passport" do
        add_responses what_passport_do_you_have?: @british_overseas_territory_country
        assert_next_node :outcome_tourism_n, for_response: "tourism"
      end

      should "have a next node of outcome_tourism_electronic_travel_authorisation for a travel document country with a passport" do
        add_responses what_passport_do_you_have?: @travel_document_country,
                      what_sort_of_travel_document?: "passport"
        assert_next_node :outcome_tourism_electronic_travel_authorisation, for_response: "tourism"
      end

      should "have a next node of travelling_visiting_partner_family_member? for other passports" do
        add_responses what_passport_do_you_have?: @visa_national_country
        assert_next_node :travelling_visiting_partner_family_member?, for_response: "tourism"
      end
    end

    context "for a 'marriage' response" do
      should "have a next node of outcome_marriage_nvn for an EEA passport" do
        add_responses what_passport_do_you_have?: @eea_country
        assert_next_node :outcome_marriage_nvn, for_response: "marriage"
      end

      should "have a next node of :outcome_marriage_nvn for a non-visa national passport" do
        add_responses what_passport_do_you_have?: @non_visa_national_country
        assert_next_node :outcome_marriage_nvn, for_response: "marriage"
      end

      should "have a next node of :outcome_marriage_nvn for a British overseas " \
             "territory passport" do
        add_responses what_passport_do_you_have?: @british_overseas_territory_country
        assert_next_node :outcome_marriage_nvn, for_response: "marriage"
      end

      should "have a next node of outcome_marriage_nvn for an electronic travel authorisation country passport" do
        add_responses what_passport_do_you_have?: @electronic_travel_authorisation_country
        assert_next_node :outcome_marriage_nvn, for_response: "marriage"
      end

      should "have a next node of outcome_marriage_taiwan for a Taiwan passport" do
        add_responses what_passport_do_you_have?: "taiwan"
        assert_next_node :outcome_marriage_taiwan, for_response: "marriage"
      end

      should "have a next node of outcome_marriage_visa_nat_direct_airside_transit_visa for a direct airside " \
             "transit visa country" do
        add_responses what_passport_do_you_have?: @direct_airside_transit_visa_country
        assert_next_node :outcome_marriage_visa_nat_direct_airside_transit_visa, for_response: "marriage"
      end

      should "have a next node of outcome_marriage_visa_nat_direct_airside_transit_visa for a visa national country" do
        add_responses what_passport_do_you_have?: @visa_national_country
        assert_next_node :outcome_marriage_visa_nat_direct_airside_transit_visa, for_response: "marriage"
      end
    end

    context "for a 'family' response" do
      should "have a next node of outcome_joining_family_nvm for a British overseas territory passport" do
        add_responses what_passport_do_you_have?: @british_overseas_territory_country
        assert_next_node :outcome_joining_family_nvn, for_response: "family"
      end

      should "have a next node of outcome_joining_family_nvn for a non-visa national passport" do
        add_responses what_passport_do_you_have?: @non_visa_national_country
        assert_next_node :outcome_joining_family_nvn, for_response: "family"
      end

      should "have a next node of outcome_joining_family_nvn for an EEA passport" do
        add_responses what_passport_do_you_have?: @eea_country
        assert_next_node :outcome_joining_family_nvn, for_response: "family"
      end

      should "have a next node of partner_family_british_citizen? for other passports" do
        add_responses what_passport_do_you_have?: @visa_national_country
        assert_next_node :partner_family_british_citizen?, for_response: "family"
      end
    end
  end
end
