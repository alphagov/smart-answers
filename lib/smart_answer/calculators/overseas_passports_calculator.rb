module SmartAnswer::Calculators
  class OverseasPassportsCalculator
    APPLY_IN_NEIGHBOURING_COUNTRIES = %w(
      british-indian-ocean-territory north-korea south-georgia-and-south-sandwich-islands
    )

    BOOK_APPOINTMENT_ONLINE_COUNTRIES = %w(
      kyrgyzstan tajikistan turkmenistan uzbekistan
    )

    EXCLUDE_COUNTRIES = %w(
      holy-see british-antarctic-territory
    )

    INELIGIBLE_COUNTRIES = %w(
      iran libya syria yemen
    )

    UK_VISA_APPLICATION_CENTRE_COUNTRIES = %w(
      afghanistan algeria azerbaijan bangladesh belarus burundi burma cambodia
      china gaza georgia india indonesia kazakhstan kyrgyzstan laos lebanon
      mauritania morocco nepal pakistan russia tajikistan thailand turkmenistan
      ukraine uzbekistan western-sahara vietnam venezuela
    )

    UK_VISA_APPLICATION_WITH_COLOUR_PICTURES_COUNTRIES = %w(
      afghanistan azerbaijan algeria bangladesh belarus burma cambodia china
      georgia india indonesia kazakhstan laos lebanon mauritania morocco nepal
      pakistan tajikistan thailand turkmenistan ukraine uzbekistan russia
      vietnam venezuela western-sahara
    )

    NON_UK_VISA_APPLICATION_WITH_COLOUR_PICTURES_COUNTRIES = %w(
      burma cuba sudan tajikistan turkmenistan uzbekistan
    )

    attr_accessor :current_location

    def book_appointment_online?
      BOOK_APPOINTMENT_ONLINE_COUNTRIES.include?(current_location)
    end

    def uk_visa_application_centre?
      UK_VISA_APPLICATION_CENTRE_COUNTRIES.include?(current_location)
    end

    def uk_visa_application_with_colour_pictures?
      UK_VISA_APPLICATION_WITH_COLOUR_PICTURES_COUNTRIES.include?(current_location)
    end

    def non_uk_visa_application_with_colour_pictures?
      NON_UK_VISA_APPLICATION_WITH_COLOUR_PICTURES_COUNTRIES.include?(current_location)
    end

    def ineligible_country?
      INELIGIBLE_COUNTRIES.include?(current_location)
    end

    def apply_in_neighbouring_countries?
      APPLY_IN_NEIGHBOURING_COUNTRIES.include?(current_location)
    end

    def alternate_embassy_location
      PassportAndEmbassyDataQuery::ALT_EMBASSIES[current_location]
    end

    def world_location
      search_location = alternate_embassy_location || current_location

      WorldLocation.find(search_location) || raise(SmartAnswer::InvalidResponse)
    end

    def world_location_name
      world_location.name
    end
  end
end
