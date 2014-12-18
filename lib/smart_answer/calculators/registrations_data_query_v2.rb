module SmartAnswer::Calculators
  class RegistrationsDataQueryV2

    COMMONWEALTH_COUNTRIES = %w(anguilla australia bermuda british-indian-ocean-territory british-virgin-islands cayman-islands canada falkland-islands gibraltar ireland montserrat new-zealand pitcairn south-africa south-georgia-and-south-sandwich-islands st-helena-ascension-and-tristan-da-cunha turks-and-caicos-islands)

    COUNTRIES_WITH_HIGH_COMMISSIONS = %w(antigua-and-barbuda bangladesh barbados belize botswana brunei cameroon cyprus dominica fiji gambia ghana grenada guyana india jamaica kenya malawi malaysia maldives malta mauritius mozambique namibia nigeria pakistan papua-new-guinea seychelles sierra-leone singapore solomon-islands sri-lanka tanzania trinidad-and-tobago uganda)

    COUNTRIES_WITH_CONSULATES = %w(china colombia israel russia turkey)

    COUNTRIES_WITH_CONSULATE_GENERALS = %(brazil hong-kong turkey)

    CASH_ONLY_COUNTRIES = %w(armenia bosnia-and-herzegovina botswana brunei cambodia iceland kazakhstan laos latvia libya slovenia tunisia uganda)

    PAY_BY_BANK_DRAFT_COUNTRIES = %w(taiwan)

    CHEQUE_ONLY_COUNTRIES = %w(taiwan)

    EASTERN_CARIBBEAN_COUNTRIES = %w(antigua-and-barbuda barbados dominica st-kitts-and-nevis st-vincent-and-the-grenadines)

    NO_POSTAL_COUNTRIES = %w(barbados costa-rica malaysia papua-new-guinea sweden tanzania thailand)

    POST_ONLY_COUNTRIES = %w(czech-republic hungary new-caledonia philippines poland slovakia)

    COUNTRIES_WITH_TRADE_CULTURAL_OFFICES = %w(taiwan)

    MODIFIED_CARD_ONLY_COUNTRIES = %w(czech-republic slovakia hungary poland)

    CASH_AND_CARD_COUNTRIES = %w(estonia)

    FOOTNOTE_EXCLUSIONS = %w(afghanistan cambodia central-african-republic chad comoros dominican-republic east-timor eritrea haiti kosovo laos lesotho liberia madagascar montenegro north-korea paraguay samoa slovenia somalia swaziland taiwan tajikistan western-sahara)

    ORU_TRANSITIONED_COUNTRIES = %w(albania american-samoa andorra angola antigua-and-barbuda argentina armenia aruba austria bahamas bahrain barbados belarus belgium belize benin bolivia bonaire-st-eustatius-saba bosnia-and-herzegovina botswana brazil brunei bulgaria burkina-faso burma burundi cambodia cameroon cape-verde central-african-republic chad chile china comoros congo congo-(democratic-republic) costa-rica cote-d-ivoire croatia cuba curacao cyprus czech-republic denmark djibouti dominica dominican-republic egypt el-salvador equador equatorial-guinea eritrea estonia ethiopia fiji finland france french-guiana french-polynesia gabon gambia georgia ghana germany greece grenada guadeloupe guatemala guinea guinea-bissau guyana haiti honduras hong-kong hungary iceland indonesia iran israel italy jamaica japan jordan kazakhstan kiribati kosovo kuwait kyrgyzstan laos latvia lesotho liberia liechtenstein lithuania luxembourg macao macedonia madagascar malawi malaysia maldives mali malta marshall-islands martinique mauritania mauritius mayotte mexico micronesia moldova monaco mongolia montenegro morocco mozambique namibia nauru netherlands nicaragua niger north-korea norway oman palau panama papua-new-guinea paraguay peru poland portugal qatar reunion romania rwanda samoa san-marino sao-tome-and-principe saudi-arabia serbia seychelles singapore slovenia solomon-islands south-korea spain st-kitts-and-nevis st-maarten st-pierre-and-miquelon st-vincent-and-the-grenadines suriname swaziland sweden switzerland syria taiwan tajikistan tanzania thailand the-occupied-palestinian-territories timor-leste togo tonga trinidad-and-tobago tunisia turkey turkmenistan tuvalu ukraine united-arab-emirates usa uruguay uzbekistan vanuatu venezuela vietnam wallis-and-futuna western-sahara yemen zambia zimbabwe)

    ORU_TRANSITION_EXCEPTIONS = %w(north-korea)

    ORU_DOCUMENTS_VARIANT_COUNTRIES = %w(andorra belgium denmark finland france israel italy japan monaco morocco netherlands poland portugal south-korea spain sweden taiwan the-occupied-palestinian-territories turkey united-arab-emirates usa)

    ORU_DOCUMENTS_VARIANT_COUNTRIES_DEATH = %w(papua-new-guinea poland)

    ORU_COURIER_VARIANTS = %w(cambodia cameroon north-korea papua-new-guinea)

    attr_reader :data

    def initialize
      @data = self.class.registration_data
    end

    def commonwealth_country?(country_slug)
      COMMONWEALTH_COUNTRIES.include?(country_slug)
    end

    def responded_with_commonwealth_country?
      SmartAnswer::Predicate::RespondedWith.new(COMMONWEALTH_COUNTRIES, "commonwealth country")
    end

    def born_in_oru_transitioned_country?
      SmartAnswer::Predicate::VariableMatches.new(:country_of_birth, ORU_TRANSITIONED_COUNTRIES, "ORU transitioned country")
    end

    def died_in_oru_transitioned_country?
      SmartAnswer::Predicate::VariableMatches.new(:country_of_death, ORU_TRANSITIONED_COUNTRIES, "ORU transitioned country of death")
    end

    def clickbook(country_slug)
      data['clickbook'][country_slug]
    end

    def has_high_commission?(country_slug)
      COUNTRIES_WITH_HIGH_COMMISSIONS.include?(country_slug)
    end

    def has_consulate?(country_slug)
      COUNTRIES_WITH_CONSULATES.include?(country_slug)
    end

    def has_consulate_general?(country_slug)
      COUNTRIES_WITH_CONSULATE_GENERALS.include?(country_slug)
    end

    def has_trade_and_cultural_office?(country_slug)
      COUNTRIES_WITH_TRADE_CULTURAL_OFFICES.include?(country_slug)
    end

    def post_only_countries?(country_slug)
      POST_ONLY_COUNTRIES.include?(country_slug)
    end

    def eastern_caribbean_countries?(country_slug)
      EASTERN_CARIBBEAN_COUNTRIES.include?(country_slug)
    end

    def cash_only?(country_slug)
      CASH_ONLY_COUNTRIES.include?(country_slug)
    end

    def pay_by_bank_draft?(country_slug)
      PAY_BY_BANK_DRAFT_COUNTRIES.include?(country_slug)
    end

    def cheque_only?(country_slug)
      CHEQUE_ONLY_COUNTRIES.include?(country_slug)
    end
    def cash_and_card_only?(country_slug)
      CASH_AND_CARD_COUNTRIES.include?(country_slug)
    end

    def caribbean_alt_embassies?(country_slug)
      CARIBBEAN_ALT_EMBASSIES.include?(country_slug)
    end

    def modified_card_only_countries?(country_slug)
      MODIFIED_CARD_ONLY_COUNTRIES.include?(country_slug)
    end

    def postal_form(country_slug)
      data['postal_form'][country_slug]
    end

    def postal_return_form(country_slug)
      data['postal_return'][country_slug]
    end

    def register_death_by_post?(country_slug)
      postal_form(country_slug) or NO_POSTAL_COUNTRIES.include?(country_slug)
    end

    def registration_country_slug(country_slug)
      data['registration_country'][country_slug] || country_slug
    end

    def self.registration_data
      @embassy_data ||= YAML.load_file(Rails.root.join("lib", "data", "registrations.yml"))
    end
  end
end
