module SmartAnswer::Calculators
  class RegistrationsDataQuery

    COMMONWEALTH_COUNTRIES = %w(anguilla ascension-island australia
      bermuda british-indian-ocean-territory british-virgin-islands cayman-islands
      canada falkland-islands gibraltar ireland montserrat new-zealand pitcairn
      south-africa south-georgia-and-south-sandwich-islands st-helena tristan-da-cunha
      turks-and-caicos-islands)

    COUNTRIES_WITH_HIGH_COMMISSIONS = %w(
      antigua-and-barbuda bangladesh barbados belize botswana brunei cameroon cyprus
      dominica,-commonwealth-of fiji gambia ghana grenada guyana india jamaica kenya
      malawi malaysia maldives malta mauritius mozambique namibia nigeria pakistan
      papua-new-guinea seychelles sierra-leone singapore solomon-islands sri-lanka
      tanzania trinidad-and-tobago uganda
    )
    COUNTRIES_WITH_CONSULATES = %w(china colombia israel russian-federation turkey)

    COUNTRIES_WITH_CONSULATE_GENERALS = %(belgium brazil germany hong-kong-(sar-of-china) indonesia netherlands turkey)

    CASH_ONLY_COUNTRIES = %w(armenia bosnia-and-herzegovina botswana brunei cambodia iceland kazakhstan latvia libya luxembourg poland slovenia tunisia uganda)

    EASTERN_CARIBBEAN_COUNTRIES = %w(antigua-and-barbuda barbados dominica,-commonwealth-of st-kitts-and-nevis st-vincent-and-the-grenadines)

    NO_POSTAL_COUNTRIES = %w(barbados belgium costa-rica malaysia papua-new-guinea 
                             sweden tanzania thailand united-states)

    POST_ONLY_COUNTRIES = %w(united-arab-emirates)

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

    def post_only_countries?(country_slug)
      POST_ONLY_COUNTRIES.include?(country_slug)
    end

    def eastern_caribbean_countries?(country_slug)
      EASTERN_CARIBBEAN_COUNTRIES.include?(country_slug)
    end

    def cash_only?(country_slug)
      CASH_ONLY_COUNTRIES.include?(country_slug)
    end

    def death_postal_form(country_slug)
      data['death']['postal_form'][country_slug]
    end

    def birth_postal_form(country_slug)
      data['birth']['postal_form'][country_slug]
    end

    def death_postal_return_form(country_slug)
      data['death']['postal_return'][country_slug]
    end

    def register_death_by_post?(country_slug)
      death_postal_form(country_slug) or NO_POSTAL_COUNTRIES.include?(country_slug)
    end

    def registration_country_slug(country_slug)
      data['registration_country'][country_slug] || country_slug
    end

    def self.registration_data
      @embassy_data ||= YAML.load_file(Rails.root.join("lib", "data", "registrations.yml"))
    end
  end
end
