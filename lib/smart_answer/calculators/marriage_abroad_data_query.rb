module SmartAnswer::Calculators
  class MarriageAbroadDataQuery
    BRITISH_OVERSEAS_TERRITORIES = %w[
      anguilla
      bermuda
      british-antarctic-territory
      british-indian-ocean-territory
      british-virgin-islands
      cayman-islands
      falkland-islands
      gibraltar
      montserrat
      pitcairn-island
      south-georgia-and-the-south-sandwich-islands
      st-helena-ascension-and-tristan-da-cunha
      turks-and-caicos-islands
    ].freeze

    FRENCH_OVERSEAS_TERRITORIES = %w[
      french-guiana
      french-polynesia
      guadeloupe
      martinique
      mayotte
      new-caledonia
      reunion
      st-pierre-and-miquelon
      wallis-and-futuna
    ].freeze

    CEREMONY_COUNTRIES_OFFERING_PACS = %w[
      monaco
    ].freeze

    DUTCH_CARIBBEAN_ISLANDS = %w[
      aruba
      bonaire-st-eustatius-saba
      curacao
      st-maarten
    ].freeze

    COUNTRIES_WITHOUT_CONSULAR_FACILITIES = %w[
      argentina
      aruba
      bonaire-st-eustatius-saba
      burundi
      cote-d-ivoire
      curacao
      czech-republic
      saint-barthelemy
      slovakia
      st-maarten
      st-martin
      taiwan
    ].freeze

    SS_MARRIAGE_COUNTRIES = %w[
      bolivia
      dominican-republic
      estonia
      kosovo
      mongolia
      montenegro
      russia
      san-marino
      serbia
    ].freeze

    SS_MARRIAGE_COUNTRIES_WHEN_COUPLE_BRITISH = %w[lithuania].freeze

    SS_MARRIAGE_AND_PARTNERSHIP_COUNTRIES = %w[
      albania
      peru
      vietnam
    ].freeze

    CONSULAR_OPPOSITE_SEX_CIVIL_PARTNERSHIP = %w[
      bolivia
      japan
      panama
      vietnam
    ].freeze

    def offers_consular_opposite_sex_civil_partnership?(country_slug)
      CONSULAR_OPPOSITE_SEX_CIVIL_PARTNERSHIP.include?(country_slug)
    end

    def ss_marriage_countries?(country_slug)
      SS_MARRIAGE_COUNTRIES.include?(country_slug)
    end

    def ss_marriage_countries_when_couple_british?(country_slug)
      SS_MARRIAGE_COUNTRIES_WHEN_COUPLE_BRITISH.include?(country_slug)
    end

    def ss_marriage_and_partnership?(country_slug)
      SS_MARRIAGE_AND_PARTNERSHIP_COUNTRIES.include?(country_slug)
    end

    def commonwealth_country?(country_slug)
      MARRIAGE_ABROAD_COMMONWEALTH_COUNTRIES.include?(country_slug)
    end

    def british_overseas_territories?(country_slug)
      BRITISH_OVERSEAS_TERRITORIES.include?(country_slug)
    end

    def french_overseas_territories?(country_slug)
      FRENCH_OVERSEAS_TERRITORIES.include?(country_slug)
    end

    def dutch_caribbean_islands?(country_slug)
      DUTCH_CARIBBEAN_ISLANDS.include?(country_slug)
    end

    def countries_without_consular_facilities?(country_slug)
      COUNTRIES_WITHOUT_CONSULAR_FACILITIES.include?(country_slug)
    end

    def outcome_per_path_countries
      (countries_with_18_outcomes +
      countries_with_19_outcomes +
      countries_with_6_outcomes +
      countries_with_2_outcomes +
      countries_with_3_outcomes +
      countries_with_2_outcomes_marriage_or_pacs +
      countries_with_ceremony_location_outcomes +
      countries_with_9_outcomes +
      countries_with_1_outcome).sort
    end

    def countries_with_1_outcome
      country_outcomes(:countries_with_1_outcome)
    end

    def countries_with_2_outcomes
      country_outcomes(:countries_with_2_outcomes)
    end

    def countries_with_3_outcomes
      country_outcomes(:countries_with_3_outcomes)
    end

    def countries_with_2_outcomes_marriage_or_pacs
      country_outcomes(:countries_with_2_outcomes_marriage_or_pacs)
    end

    def countries_with_6_outcomes
      country_outcomes(:countries_with_6_outcomes)
    end

    def countries_with_9_outcomes
      country_outcomes(:countries_with_9_outcomes)
    end

    def countries_with_18_outcomes
      country_outcomes(:countries_with_18_outcomes)
    end

    def countries_with_19_outcomes
      country_outcomes(:countries_with_19_outcomes)
    end

    def countries_with_ceremony_location_outcomes
      country_outcomes(:countries_with_ceremony_location_outcomes)
    end

    def marriage_data
      @marriage_data ||= YAML.load_file(path_to_data_file).with_indifferent_access
    end

  private

    def valid_outcomes_country_data_structure?(countries)
      countries.nil? || (countries.is_a?(Array) && countries.all? { |country| country.is_a?(String) })
    end

    def country_outcomes(key)
      countries = marriage_data.fetch(key)
      if valid_outcomes_country_data_structure?(countries)
        countries || []
      else
        raise "Country list must be an array of strings"
      end
    end

    def path_to_data_file
      Rails.root.join("config/smart_answers/marriage_abroad_data.yml")
    end
  end
end
