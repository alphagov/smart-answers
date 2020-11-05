module SmartAnswer::Calculators
  class UkVisaCalculator
    include ActiveModel::Model

    attr_writer :when_coming_to_uk_answer
    attr_writer :passport_country
    attr_writer :purpose_of_visit_answer
    attr_writer :travelling_to_cta_answer
    attr_writer :passing_through_uk_border_control_answer
    attr_writer :travel_document_type
    attr_writer :travelling_visiting_partner_family_member_answer

    def passport_country_in_eea?
      COUNTRY_GROUP_EEA.include?(@passport_country)
    end

    def passport_country_in_non_visa_national_list?
      COUNTRY_GROUP_NON_VISA_NATIONAL.include?(@passport_country)
    end

    def passport_country_in_visa_national_list?
      COUNTRY_GROUP_VISA_NATIONAL.include?(@passport_country)
    end

    def passport_country_in_ukot_list?
      COUNTRY_GROUP_UKOT.include?(@passport_country)
    end

    def passport_country_in_datv_list?
      COUNTRY_GROUP_DATV.include?(@passport_country)
    end

    def passport_country_in_youth_mobility_scheme_list?
      COUNTRY_GROUP_YOUTH_MOBILITY_SCHEME.include?(@passport_country)
    end

    def passport_country_in_electronic_visa_waiver_list?
      COUNTRY_GROUP_ELECTRONIC_VISA_WAIVER.include?(@passport_country)
    end

    def passport_country_in_epassport_gate_list?
      COUNTRY_GROUP_EPASSPORT_GATES.include?(@passport_country)
    end

    def passport_country_in_b1_b2_visa_exception_list?
      @passport_country == "syria"
    end

    def passport_country_is_israel?
      @passport_country == "israel"
    end

    def passport_country_is_taiwan?
      @passport_country == "taiwan"
    end

    def passport_country_is_venezuela?
      @passport_country == "venezuela"
    end

    def passport_country_is_croatia?
      @passport_country == "croatia"
    end

    def passport_country_is_china?
      @passport_country == "china"
    end

    def passport_country_is_estonia?
      @passport_country == "estonia" || @passport_country == "estonia-alien-passport"
    end

    def passport_country_is_hong_kong?
      @passport_country == "hong-kong"
    end

    def passport_country_is_ireland?
      @passport_country == "ireland"
    end

    def passport_country_is_latvia?
      @passport_country == "latvia" || @passport_country == "latvia-alien-passport"
    end

    def passport_country_is_macao?
      @passport_country == "macao"
    end

    def passport_country_is_turkey?
      @passport_country == "turkey"
    end

    def applicant_is_stateless_or_a_refugee?
      @passport_country == "stateless-or-refugee"
    end

    def travel_document?
      @travel_document_type == "travel_document"
    end

    def travelling_before_2021?
      @when_coming_to_uk_answer == "before_2021"
    end

    def tourism_visit?
      @purpose_of_visit_answer == "tourism"
    end

    def work_visit?
      @purpose_of_visit_answer == "work"
    end

    def study_visit?
      @purpose_of_visit_answer == "study"
    end

    def transit_visit?
      @purpose_of_visit_answer == "transit"
    end

    def family_visit?
      @purpose_of_visit_answer == "family"
    end

    def marriage_visit?
      @purpose_of_visit_answer == "marriage"
    end

    def school_visit?
      @purpose_of_visit_answer == "school"
    end

    def medical_visit?
      @purpose_of_visit_answer == "medical"
    end

    def diplomatic_visit?
      @purpose_of_visit_answer == "diplomatic"
    end

    def passing_through_uk_border_control?
      @passing_through_uk_border_control_answer == "yes"
    end

    def travelling_to_channel_islands_or_isle_of_man?
      @travelling_to_cta_answer == "channel_islands_or_isle_of_man"
    end

    def travelling_to_ireland?
      @travelling_to_cta_answer == "republic_of_ireland"
    end

    def travelling_to_elsewhere?
      @travelling_to_cta_answer == "somewhere_else"
    end

    def travelling_visiting_partner_family_member?
      @travelling_visiting_partner_family_member_answer == "yes"
    end

    EXCLUDE_COUNTRIES = %w[
      american-samoa
      british-antarctic-territory
      british-indian-ocean-territory
      french-guiana
      french-polynesia
      gibraltar
      guadeloupe
      holy-see
      martinique
      mayotte
      new-caledonia
      reunion
      st-pierre-and-miquelon
      the-occupied-palestinian-territories
      wallis-and-futuna
      western-sahara
    ].freeze

    COUNTRY_GROUP_UKOT = %w[
      anguilla
      bermuda
      british-dependent-territories-citizen
      british-overseas-citizen
      british-protected-person
      british-virgin-islands
      cayman-islands
      falkland-islands
      montserrat
      south-georgia-and-the-south-sandwich-islands
      st-helena-ascension-and-tristan-da-cunha
      turks-and-caicos-islands
    ].freeze

    COUNTRY_GROUP_NON_VISA_NATIONAL = %w(
      andorra
      antigua-and-barbuda
      argentina
      aruba
      australia
      bahamas
      barbados
      belize
      bonaire-st-eustatius-saba
      botswana
      brazil
      british-national-overseas
      brunei
      canada
      chile
      costa-rica
      curacao
      dominica
      el-salvador
      grenada
      guatemala
      honduras
      hong-kong
      hong-kong-(british-national-overseas)
      israel
      japan
      kiribati
      macao
      malaysia
      maldives
      marshall-islands
      mauritius
      mexico
      micronesia
      monaco
      namibia
      nauru
      new-zealand
      nicaragua
      palau
      panama
      papua-new-guinea
      paraguay
      pitcairn-island
      samoa
      san-marino
      seychelles
      singapore
      solomon-islands
      south-korea
      st-kitts-and-nevis
      st-lucia
      st-maarten
      st-vincent-and-the-grenadines
      timor-leste
      tonga
      trinidad-and-tobago
      tuvalu
      uruguay
      usa
      vanuatu
      vatican-city
    ).freeze

    COUNTRY_GROUP_VISA_NATIONAL = %w[
      armenia
      azerbaijan
      bahrain
      benin
      bhutan
      bolivia
      bosnia-and-herzegovina
      burkina-faso
      cambodia
      cape-verde
      central-african-republic
      chad
      colombia
      comoros
      cuba
      djibouti
      dominican-republic
      ecuador
      equatorial-guinea
      fiji
      gabon
      georgia
      guyana
      haiti
      indonesia
      jordan
      kazakhstan
      kuwait
      kyrgyzstan
      laos
      madagascar
      mali
      mauritania
      montenegro
      morocco
      mozambique
      niger
      north-korea
      oman
      peru
      philippines
      qatar
      russia
      sao-tome-and-principe
      saudi-arabia
      stateless-or-refugee
      suriname
      taiwan
      tajikistan
      thailand
      togo
      tunisia
      turkmenistan
      ukraine
      united-arab-emirates
      uzbekistan
      zambia
    ].freeze

    COUNTRY_GROUP_DATV = %w[
      afghanistan
      albania
      algeria
      angola
      bangladesh
      belarus
      burundi
      cameroon
      china
      congo
      cote-d-ivoire
      cyprus-north
      democratic-republic-of-the-congo
      egypt
      eritrea
      estonia-alien-passport
      eswatini
      ethiopia
      ghana
      guinea
      guinea-bissau
      india
      iran
      iraq
      israel-provisional-passport
      jamaica
      kenya
      kosovo
      latvia-alien-passport
      lebanon
      lesotho
      liberia
      libya
      malawi
      moldova
      mongolia
      myanmar
      nepal
      nigeria
      north-macedonia
      pakistan
      palestinian-territories
      rwanda
      senegal
      serbia
      sierra-leone
      somalia
      south-africa
      south-sudan
      sri-lanka
      sudan
      syria
      tanzania
      the-gambia
      turkey
      uganda
      venezuela
      vietnam
      yemen
      zimbabwe
    ].freeze

    COUNTRY_GROUP_EEA = %w[
      austria
      belgium
      bulgaria
      croatia
      cyprus
      czech-republic
      denmark
      estonia
      finland
      france
      germany
      greece
      hungary
      iceland
      ireland
      italy
      latvia
      liechtenstein
      lithuania
      luxembourg
      malta
      netherlands
      norway
      poland
      portugal
      romania
      saint-barthelemy
      slovakia
      slovenia
      spain
      st-martin
      sweden
      switzerland
    ].freeze

    COUNTRY_GROUP_YOUTH_MOBILITY_SCHEME = %w[
      australia
      canada
      hong-kong
      japan
      monaco
      new-zealand
      south-korea
      taiwan
    ].freeze

    COUNTRY_GROUP_ELECTRONIC_VISA_WAIVER = %w[
      kuwait
      oman
      qatar
      united-arab-emirates
    ].freeze

    COUNTRY_GROUP_EPASSPORT_GATES = %w[
      australia
      canada
      japan
      new-zealand
      singapore
      south-korea
      usa
    ].freeze
  end
end
