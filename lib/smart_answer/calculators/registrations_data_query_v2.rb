module SmartAnswer::Calculators
  class RegistrationsDataQueryV2

    COMMONWEALTH_COUNTRIES = %w(anguilla australia bermuda british-indian-ocean-territory british-virgin-islands cayman-islands canada falkland-islands gibraltar ireland montserrat new-zealand pitcairn south-africa south-georgia-and-south-sandwich-islands st-helena-ascension-and-tristan-da-cunha turks-and-caicos-islands)

    COUNTRIES_WITH_HIGH_COMMISSIONS = %w(antigua-and-barbuda bangladesh barbados belize botswana brunei cameroon cyprus dominica fiji gambia ghana grenada guyana india jamaica kenya malawi malaysia maldives malta mauritius mozambique namibia nigeria pakistan papua-new-guinea seychelles sierra-leone singapore solomon-islands sri-lanka tanzania trinidad-and-tobago uganda)

    COUNTRIES_WITH_CONSULATES = %w(china colombia israel russia turkey)

    COUNTRIES_WITH_CONSULATE_GENERALS = %(brazil hong-kong turkey)

    CASH_ONLY_COUNTRIES = %w(armenia bosnia-and-herzegovina botswana brunei cambodia iceland kazakhstan laos latvia libya slovenia tunisia uganda)

    CHEQUE_ONLY_COUNTRIES = %w(taiwan)

    EASTERN_CARIBBEAN_COUNTRIES = %w(antigua-and-barbuda barbados dominica st-kitts-and-nevis st-vincent-and-the-grenadines)

    NO_POSTAL_COUNTRIES = %w(barbados costa-rica malaysia papua-new-guinea sweden tanzania thailand)

    POST_ONLY_COUNTRIES = %w(czech-republic hungary new-caledonia poland slovakia)

    COUNTRIES_WITH_TRADE_CULTURAL_OFFICES = %w(taiwan)

    MODIFIED_CARD_ONLY_COUNTRIES = %w(czech-republic slovakia hungary poland)
    
    CASH_AND_CARD_COUNTRIES = %w(estonia)
    
    ORU_TRANSITIONED_COUNTRIES = %w(american-samoa belgium france french-guiana french-polynesia germany greece guadeloupe italy liechtenstein luxembourg martinique mayotte monaco netherlands portugal reunion san-marino spain st-pierre-and-miquelon switzerland united-arab-emirates usa wallis-and-futuna)
    
    ORU_DOCUMENTS_VARIANT_COUNTRIES = %w(belgium france italy netherlands portugal spain united-arab-emirates)
    

    attr_reader :data

    def initialize
      @data = self.class.registration_data
    end

    def commonwealth_country?(country_slug)
      COMMONWEALTH_COUNTRIES.include?(country_slug) 
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
