module SmartAnswer::Calculators
  class RegistrationsDataQuery

    COMMONWEALTH_COUNTRIES = %w(anguilla australia bermuda british-indian-ocean-territory british-virgin-islands cayman-islands canada falkland-islands gibraltar ireland montserrat new-zealand pitcairn south-africa south-georgia-and-south-sandwich-islands st-helena-ascension-and-tristan-da-cunha turks-and-caicos-islands)

    COUNTRIES_WITH_HIGH_COMMISSIONS = %w(antigua-and-barbuda bangladesh barbados belize botswana brunei cameroon cyprus dominica fiji gambia ghana grenada guyana india jamaica kenya malawi malaysia maldives malta mauritius mozambique namibia nigeria pakistan papua-new-guinea seychelles sierra-leone singapore solomon-islands sri-lanka tanzania trinidad-and-tobago uganda)

    COUNTRIES_WITH_CONSULATES = %w(china colombia israel russia turkey)

    COUNTRIES_WITH_CONSULATE_GENERALS = %w(brazil hong-kong turkey)

    COUNTRIES_WITH_BIRTH_REGISTRATION_EXCEPTION = %w(afghanistan iraq jordan kuwait oman pakistan qatar saudi-arabia united-arab-emirates)

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

    ORU_TRANSITIONED_COUNTRIES = %w(afghanistan albania algeria american-samoa andorra angola antigua-and-barbuda argentina armenia aruba austria azerbaijan bahamas bahrain bangladesh barbados belarus belgium belize benin bhutan bolivia bonaire-st-eustatius-saba bosnia-and-herzegovina botswana brazil brunei bulgaria burkina-faso burma burundi cambodia cameroon cape-verde central-african-republic chad chile china colombia comoros congo costa-rica cote-d-ivoire croatia cuba curacao cyprus czech-republic democratic-republic-of-congo denmark djibouti dominica dominican-republic ecuador egypt el-salvador equatorial-guinea eritrea estonia ethiopia fiji finland france french-guiana french-polynesia gabon gambia georgia germany ghana greece grenada guadeloupe guatemala guinea guinea-bissau guyana haiti honduras hong-kong hungary iceland india indonesia iran iraq israel italy jamaica japan jordan kazakhstan kenya kiribati kosovo kuwait kyrgyzstan laos latvia lebanon lesotho liberia libya liechtenstein lithuania luxembourg macao macedonia madagascar malawi malaysia maldives mali malta marshall-islands martinique mauritania mauritius mayotte mexico micronesia moldova monaco mongolia montenegro morocco mozambique namibia nauru nepal netherlands new-caledonia nicaragua niger nigeria north-korea norway oman pakistan palau panama papua-new-guinea paraguay peru philippines poland portugal qatar reunion romania russia rwanda samoa san-marino sao-tome-and-principe saudi-arabia senegal serbia seychelles sierra-leone singapore slovakia slovenia solomon-islands somalia south-korea south-sudan spain sri-lanka st-kitts-and-nevis st-lucia st-maarten st-pierre-and-miquelon st-vincent-and-the-grenadines sudan suriname swaziland sweden switzerland syria taiwan tajikistan tanzania thailand the-occupied-palestinian-territories timor-leste togo tonga trinidad-and-tobago tunisia turkey turkmenistan tuvalu uganda ukraine united-arab-emirates uruguay usa uzbekistan vanuatu venezuela vietnam wallis-and-futuna western-sahara yemen zambia zimbabwe)

    ORU_TRANSITION_EXCEPTIONS = %w(north-korea)

    ORU_DOCUMENTS_VARIANT_COUNTRIES_BIRTH = %w(andorra belgium denmark finland france india israel italy japan monaco morocco nepal netherlands nigeria poland portugal russia sierra-leone south-korea spain sri-lanka sweden taiwan the-occupied-palestinian-territories turkey united-arab-emirates usa)

    ORU_DOCUMENTS_VARIANT_COUNTRIES_DEATH = %w(papua-new-guinea poland)

    ORU_COURIER_VARIANTS = %w(cambodia cameroon kenya nigeria north-korea papua-new-guinea uganda)

    ORU_COURIER_BY_HIGH_COMISSION = %w(cameroon kenya nigeria)

    HIGHER_RISK_COUNTRIES = %w(afghanistan algeria azerbaijan bangladesh bhutan colombia india iraq kenya lebanon libya nepal new-caledonia nigeria pakistan philippines russia sierra-leone somalia south-sudan sri-lanka sudan uganda)

    MAY_REQUIRE_DNA_TESTS = %w(libya somalia)

    ORU_REGISTRATION_DURATION = {
      "afghanistan" => "6 months",
      "algeria" => "12 weeks",
      "azerbaijan" => "10 weeks",
      "bangladesh" => "8 months",
      "bhutan" => "8 weeks",
      "colombia" => "8 weeks",
      "india" => "16 weeks",
      "iraq" => "12 weeks",
      "kenya" => "12 weeks",
      "lebanon" => "12 weeks",
      "libya" => "6 months",
      "nepal" => "10 weeks",
      "nigeria" => "14 weeks",
      "pakistan" => "6 months",
      "russia" => "10 weeks",
      "sierra-leone" => "12 weeks",
      "somalia" => "12 weeks",
      "south-sudan" => "12 weeks",
      "sri-lanka" => "12 weeks",
      "sudan" => "12 weeks",
      "philippines" => "16 weeks",
      "uganda" => "12 weeks",
    }

    attr_reader :data

    def initialize
      @data = self.class.registration_data
    end

    def has_birth_registration_exception?(country_slug)
      COUNTRIES_WITH_BIRTH_REGISTRATION_EXCEPTION.include?(country_slug)
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

    def may_require_dna_tests?(country_slug)
      MAY_REQUIRE_DNA_TESTS.include?(country_slug)
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

    def custom_registration_duration(country_slug)
      ORU_REGISTRATION_DURATION[country_slug]
    end

    def document_return_fees
      SmartAnswer::Calculators::RatesQuery.new('births_and_deaths_document_return_fees').rates
    end

    def self.registration_data
      @embassy_data ||= YAML.load_file(Rails.root.join("lib", "data", "registrations.yml"))
    end
  end
end
